import 'dart:async';

import 'package:flutter/foundation.dart';

import 'utils.dart';
import 'isolate_contactor.dart';
import 'isolate_contactor_controller.dart';

class IsolateContactorInternal implements IsolateContactor {
  /// For debugging
  bool _debugMode = !kReleaseMode;

  /// For releasing current main listener
  StreamSubscription<dynamic>? _mainStream;

  /// Check for current isolate in bool
  bool _isComputing = false;

  /// Check for current cumputing state in enum with listener
  final StreamController<ComputeState> _computeStreamController =
      StreamController.broadcast();

  /// Listener for result
  final IsolateContactorController _isolateContactorController =
      IsolateContactorController(StreamController.broadcast());

  /// Control the function of isolate
  late void Function(dynamic) _isolateFunction;

  /// Control the parameters of isolate
  late dynamic _isolateParam;

  /// Create an instance
  IsolateContactorInternal._(
      {required void Function(dynamic) isolateFunction,
      required dynamic isolateParam,
      bool debugMode = kReleaseMode}) {
    _debugMode = debugMode;
    _isolateFunction = isolateFunction;
    _isolateParam = isolateParam;
  }

  /// Create an instance
  static Future<IsolateContactorInternal> create(
      {dynamic Function(dynamic)? function, bool debugMode = true}) async {
    IsolateContactorInternal _isolateContactor = IsolateContactorInternal._(
        isolateFunction: internalIsolateFunction, isolateParam: function);

    await _isolateContactor._initial();

    return _isolateContactor;
  }

  /// Create modified isolate function
  static Future<IsolateContactorInternal> createOwnIsolate(
      {required void Function(dynamic) isolateFunction,
      required dynamic isolateParams,
      bool debugMode = kReleaseMode}) async {
    IsolateContactorInternal _isolateContactor = IsolateContactorInternal._(
        isolateFunction: isolateFunction,
        isolateParam: isolateParams ?? [],
        debugMode: debugMode);

    await _isolateContactor._initial();

    return _isolateContactor;
  }

  /// Initialize
  Future<void> _initial() async {
    _isolateParam = [_isolateParam, _isolateContactorController];
    _mainStream = _isolateContactorController.onMessage.listen((message) {
      _printDebug('[Main Stream] rawMessage = $message');
      _isComputing = false;
      _computeStreamController.sink.add(ComputeState.computed);
    });

    _isolateFunction(_isolateParam);

    _printDebug('Initialized');
  }

  /// Get current message as stream
  @override
  Stream get onMessage => _isolateContactorController.onMessage;

  /// Get current state
  @override
  Stream<ComputeState> get onComputeState => _computeStreamController.stream;

  /// Is current isolate computing
  @override
  bool get isComputing => _isComputing;

  /// Pause current [Isolate]
  ///
  /// Umplemented in web platform at the moment.
  @override
  void pause() {
    _printDebug(
        'This method still unimplemented in web platform at the moment!');
  }

  /// Resume current [Isolate]
  ///
  /// Umplemented in web platform at the moment.
  @override
  void resume() {
    _printDebug(
        'This method still unimplemented in web platform at the moment!');
  }

  /// Restart current [Isolate]
  @override
  Future<void> restart() async {
    _printDebug(
        'This method still unimplemented in web platform at the moment!');
  }

  @override
  void close() => dispose();

  @override
  void terminate() => dispose();

  /// Dispose current [Isolate]
  @override
  void dispose() {
    _mainStream?.cancel();
    _isComputing = false;
    _computeStreamController.sink.add(ComputeState.computed);
    _computeStreamController.close;
    _printDebug('Disposed');
  }

  /// Send message to child isolate [function]
  @override
  void sendMessage(dynamic message) {
    if (!_isolateContactorController.controller.hasListener) {
      _printDebug('! This isolate has been terminated');
      return;
    }

    if (_isComputing) {
      _printDebug(
          '! This isolate is still computing, so the current request may be revoked!');
    }

    _printDebug('Message send to isolate: $message');
    _isComputing = true;
    _computeStreamController.sink.add(ComputeState.computing);
    _isolateContactorController.sendIsolate(message);
  }

  /// Print if [debugMode] is true
  void _printDebug(Object? object, [bool force = false]) {
    // ignore: avoid_print
    if (_debugMode && !force) print('[Isolate Contactor]: $object');
  }
}
