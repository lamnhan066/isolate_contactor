import 'dart:async';

import 'package:flutter/foundation.dart';

import 'enum.dart';
import 'isolate_contactor.dart';
import 'extension_web.dart';

class IsolateContactorInternal implements IsolateContactor {
  /// For debugging
  bool _debugMode = !kReleaseMode;

  /// Listener for main isolate
  final StreamController _mainStreamController = StreamController.broadcast();

  /// For releasing current main listener
  StreamSubscription<dynamic>? _mainStream;

  /// Check for current isolate in bool
  bool _isComputing = false;

  /// Check for current cumputing state in enum with listener
  final StreamController<ComputeState> _computeStreamController =
      StreamController.broadcast();

  /// Listener for isolate
  // final StreamController _isolateStreamController =
  //     StreamController.broadcast();

  /// Listener for result
  final IsolateContactorController _channelStreamController =
      IsolateContactorController(StreamController.broadcast());

  /// Control the function of isolate
  late void Function(dynamic) _isolateFunction;

  /// Control the parameters of isolate
  late dynamic _isolateParam;

  /// Current excuting function
  Function? _function;

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
        isolateFunction: _internalIsolateFunction, isolateParam: function);

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
    _isolateParam = [_isolateParam, _channelStreamController];
    _mainStream = _channelStreamController.onMainMessage.listen((message) {
      _printDebug('[Main Stream] rawMessage = $message');

      _printDebug('Message received from isolate: $message');

      _mainStreamController.sink.add(message);
      _isComputing = false;
      _computeStreamController.sink.add(ComputeState.computed);
    });

    _isolateFunction(_isolateParam);

    _printDebug('Initialized');
  }

  /// Get current message as stream
  @override
  Stream get onMessage => _channelStreamController.onMessage;

  /// Get current state
  @override
  Stream<ComputeState> get onComputeState => _computeStreamController.stream;

  /// Is current isolate computing
  @override
  bool get isComputing => _isComputing;

  /// Pause current [Isolate]
  @override
  void pause() {
//     if (_future != null) {
// _completer.
//     } else {
//       _printDebug('Pause Error');
//     }
  }

  /// Resume current [Isolate]
  @override
  void resume() {
    // if (_pauseCapability != null && _isolate != null) {
    //   _isolate!.resume(_pauseCapability!);
    //   _pauseCapability = null;
    //   _printDebug('Resumed');
    // } else {
    //   _printDebug('Resume Error');
    // }
  }

  /// Restart current [Isolate]
  @override
  Future<void> restart() async {
    // if (_isolate != null) {
    //   _isolate!.kill(priority: Isolate.immediate);
    //   _isolate = await Isolate.spawn(_isolateFunction, _isolateParam);
    //   _printDebug('Restarted');
    // } else {
    //   _printDebug('Restart Error');
    // }
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
    _function = null;
    _isComputing = false;
    _computeStreamController.sink.add(ComputeState.computed);
    _printDebug('Disposed');
  }

  /// Send message to child isolate [function]
  @override
  void sendMessage(dynamic message) {
    // if (_function == null) {
    //   _printDebug('! This isolate has been terminated');
    //   return;
    // }

    if (_isComputing) {
      _printDebug(
          '! This isolate is still computing, so the current request may be revoked!');
    }

    _printDebug('Message send to isolate: $message');
    _isComputing = true;
    _computeStreamController.sink.add(ComputeState.computing);
    _channelStreamController.sendIsolate(message);
  }

  /// Print if [debugMode] is true
  void _printDebug(Object? object) {
    // ignore: avoid_print
    if (_debugMode) print('[Isolate Contactor]: $object');
  }

  /// Create a static function to compunicate with main [Isolate]
  static void _internalIsolateFunction(dynamic params) {
    var channel = IsolateContactorController(params);
    channel.onMessage.listen((message) {
      if (message != null) {
        // Check if the params contains function or not
        try {
          (params[0](message) as Future).then((value) {
            channel.sendResult(value);
          });
        } catch (_) {
          try {
            channel.sendResult(params[0](message));
          } catch (_) {}
        }
      }
    });
  }
}
