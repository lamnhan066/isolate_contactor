import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

import 'utils.dart';
import 'isolate_contactor_controller.dart';
import 'isolate_contactor.dart';

class IsolateContactorInternal implements IsolateContactor {
  /// For debugging
  bool _debugMode = !kReleaseMode;

  /// Create receive port
  late ReceivePort _receivePort;

  /// Create isolate channel
  late IsolateContactorController _isolateContactorController;

  /// Create isolate
  Isolate? _isolate;

  /// For pausing isolate
  Capability? _pauseCapability;

  /// Listener for main isolate
  final StreamController _mainStreamController = StreamController.broadcast();

  /// For release current main listener
  StreamSubscription<dynamic>? _mainStream;

  /// Check for current computing state in bool
  bool _isComputing = false;

  /// Check for current computing state in enum with listener
  final StreamController<ComputeState> _computeStreamController =
      StreamController.broadcast();

  /// Control the function of isolate
  late void Function(dynamic) _isolateFunction;

  /// Control the parameters of isolate
  late dynamic _isolateParam;

  /// Internal instance
  IsolateContactorInternal._(
      {required dynamic Function(dynamic) isolateFunction,
      required dynamic isolateParam,
      bool debugMode = kReleaseMode}) {
    _debugMode = debugMode;
    _isolateFunction = isolateFunction;
    _isolateParam = isolateParam;
  }

  /// Create an instance with build-in function
  static Future<IsolateContactorInternal> create(
      {dynamic Function(dynamic)? function, bool debugMode = true}) async {
    IsolateContactorInternal _isolateContactor = IsolateContactorInternal._(
        isolateFunction: internalIsolateFunction, isolateParam: function);

    await _isolateContactor._initial();

    return _isolateContactor;
  }

  /// Create an instance with your own function
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
    _receivePort = ReceivePort();
    _isolateContactorController = IsolateContactorController(_receivePort);
    _isolateParam = [_isolateParam, _receivePort.sendPort];
    _mainStream = _isolateContactorController.onMessage.listen((message) {
      _printDebug('Message received from isolate: $message');
      _isComputing = false;
      _computeStreamController.sink.add(ComputeState.computed);
    });

    _isolate = await Isolate.spawn(_isolateFunction, _isolateParam);

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
  @override
  void pause() {
    if (_pauseCapability == null && _isolate != null) {
      _isolate!.pause(_pauseCapability);
      _printDebug('Paused');
    } else {
      _printDebug('Pause Error');
    }
  }

  /// Resume current [Isolate]
  @override
  void resume() {
    if (_pauseCapability != null && _isolate != null) {
      _isolate!.resume(_pauseCapability!);
      _pauseCapability = null;
      _printDebug('Resumed');
    } else {
      _printDebug('Resume Error');
    }
  }

  /// Restart current [Isolate]
  @override
  Future<void> restart() async {
    if (_isolate != null) {
      _isolate!.kill(priority: Isolate.immediate);
      _isolate = await Isolate.spawn(_isolateFunction, _isolateParam);
      _printDebug('Restarted');
    } else {
      _printDebug('Restart Error');
    }
    _isComputing = false;
    _computeStreamController.sink.add(ComputeState.computed);
  }

  @override
  void close() => dispose();

  @override
  void terminate() => dispose();

  /// Dispose current [Isolate]
  @override
  void dispose() {
    _mainStream?.cancel();
    _receivePort.close();
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _isComputing = false;
    _computeStreamController.sink.add(ComputeState.computed);
    _printDebug('Disposed');
  }

  /// Send message to child isolate [function]
  @override
  void sendMessage(dynamic message) {
    if (_isolate == null) {
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
  void _printDebug(Object? object) {
    // ignore: avoid_print
    if (_debugMode) print('[Isolate Contactor]: $object');
  }
}
