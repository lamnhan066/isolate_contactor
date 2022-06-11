import 'dart:async';
import 'dart:isolate';

import '../isolate_contactor.dart';
import '../isolate_contactor_controller.dart';
import '../utils/utils.dart';

class IsolateContactorInternal<T> implements IsolateContactor<T> {
  /// For debugging
  bool _debugMode = false;

  /// Create receive port
  late ReceivePort _receivePort;

  /// Create isolate channel
  late IsolateContactorController _isolateContactorController;

  /// Create isolate
  Isolate? _isolate;

  /// Check for current computing state in bool
  bool _isComputing = false;

  /// Check for current computing state in enum with listener
  final StreamController<ComputeState> _computeStateStreamController =
      StreamController.broadcast();

  /// Check for current computing state in enum with listener
  final StreamController<T> _mainStreamController =
      StreamController.broadcast();

  /// Control the function of isolate
  late void Function(dynamic) _isolateFunction;

  /// Control the parameters of isolate
  late dynamic _isolateParam;

  /// Internal instance
  IsolateContactorInternal._(
      {required FutureOr<void> Function(dynamic) isolateFunction,
      required dynamic isolateParam,
      bool debugMode = false}) {
    _debugMode = debugMode;
    _isolateFunction = isolateFunction;
    _isolateParam = isolateParam;
  }

  /// Create an instance with build-in function
  static Future<IsolateContactorInternal<T>> create<T>(
      {FutureOr<T> Function(dynamic)? function, bool debugMode = true}) async {
    IsolateContactorInternal<T> isolateContactor = IsolateContactorInternal._(
      isolateFunction: internalIsolateFunction,
      isolateParam: function,
      debugMode: debugMode,
    );

    await isolateContactor._initial();

    return isolateContactor;
  }

  /// Create an instance with your own function
  static Future<IsolateContactorInternal<T>> createOwnIsolate<T>(
      {required void Function(dynamic) isolateFunction,
      required dynamic isolateParams,
      bool debugMode = false}) async {
    IsolateContactorInternal<T> isolateContactor = IsolateContactorInternal._(
      isolateFunction: isolateFunction,
      isolateParam: isolateParams ?? [],
      debugMode: debugMode,
    );

    await isolateContactor._initial();

    return isolateContactor;
  }

  /// Initialize
  Future<void> _initial() async {
    _receivePort = ReceivePort();
    _isolateContactorController = IsolateContactorController(_receivePort);
    _isolateContactorController.onMessage.listen((message) {
      _printDebug('Message received from isolate: $message');
      _isComputing = false;
      _computeStateStreamController.sink.add(ComputeState.computed);
      _mainStreamController.sink.add(message);
    });

    _isolate = await Isolate.spawn(
        _isolateFunction, [_isolateParam, _receivePort.sendPort]);

    _isComputing = false;
    _computeStateStreamController.sink.add(ComputeState.computed);

    _printDebug('Initialized');
  }

  void _dispose() {
    _isolateContactorController.sendIsolate(IsolateState.dispose);
    _isolateContactorController.close();
    _receivePort.close();
    _isolate!.kill(priority: Isolate.beforeNextEvent);
    _isolate = null;
    _isComputing = false;
    _computeStateStreamController.sink.add(ComputeState.computed);
  }

  /// Get current message as stream
  @override
  Stream<T> get onMessage => _mainStreamController.stream;

  /// Get current state
  @override
  Stream<ComputeState> get onComputeState =>
      _computeStateStreamController.stream;

  /// Is current isolate computing
  @override
  bool get isComputing => _isComputing;

  /// Restart current [Isolate]
  @override
  Future<void> restart() async {
    if (_isolate == null) {
      _printDebug('! This isolate was terminated');
      return;
    }
    _dispose();
    _initial();
    _printDebug('Restarted');
  }

  @override
  void close() => dispose();

  @override
  void terminate() => dispose();

  /// Dispose current [Isolate]
  @override
  void dispose() {
    if (_isolate == null) {
      _printDebug('! This isolate was terminated');
      return;
    }

    _dispose();
    _computeStateStreamController.close();
    _mainStreamController.close();
    _printDebug('Disposed');
  }

  /// Send message to child isolate [function]
  @override
  void sendMessage(dynamic message) {
    if (_isolate == null) {
      _printDebug('! This isolate was terminated');
      return;
    }

    if (_isComputing) {
      _printDebug(
          '! This isolate is still computing, so the current request may be revoked!');
    }

    _printDebug('Message send to isolate: $message');
    _isComputing = true;
    _computeStateStreamController.sink.add(ComputeState.computing);
    _isolateContactorController.sendIsolate(message);
  }

  /// Print if [debugMode] is true
  void _printDebug(Object? object) {
    // ignore: avoid_print
    if (_debugMode) print('[Isolate Contactor]: $object');
  }
}
