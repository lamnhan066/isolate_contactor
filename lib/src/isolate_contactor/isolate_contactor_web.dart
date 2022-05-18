import 'dart:async';

import '../isolate_contactor.dart';
import '../isolate_contactor_controller.dart';
import '../utils/utils.dart';

class IsolateContactorInternal implements IsolateContactor {
  /// For debugging
  bool _debugMode = false;

  /// Check for current isolate in bool
  bool _isComputing = false;

  /// Check for current cumputing state in enum with listener
  final StreamController<ComputeState> _computeStateStreamController =
      StreamController.broadcast();

  /// Check for current cumputing state in enum with listener
  final StreamController<dynamic> _mainStreamController =
      StreamController.broadcast();

  /// Listener for result
  IsolateContactorController? _isolateContactorController;

  /// Control the function of isolate
  late void Function(dynamic) _isolateFunction;

  /// Control the parameters of isolate
  late dynamic _isolateParam;

  /// Create an instance
  IsolateContactorInternal._(
      {required void Function(dynamic) isolateFunction,
      required dynamic isolateParam,
      bool debugMode = false}) {
    _debugMode = debugMode;
    _isolateFunction = isolateFunction;
    _isolateParam = isolateParam;
  }

  /// Create an instance
  static Future<IsolateContactorInternal> create(
      {dynamic Function(dynamic)? function, bool debugMode = true}) async {
    IsolateContactorInternal isolateContactor = IsolateContactorInternal._(
      isolateFunction: internalIsolateFunction,
      isolateParam: function,
      debugMode: debugMode,
    );

    await isolateContactor._initial();

    return isolateContactor;
  }

  /// Create modified isolate function
  static Future<IsolateContactorInternal> createOwnIsolate(
      {required void Function(dynamic) isolateFunction,
      required dynamic isolateParams,
      bool debugMode = false}) async {
    IsolateContactorInternal isolateContactor = IsolateContactorInternal._(
      isolateFunction: isolateFunction,
      isolateParam: isolateParams ?? [],
      debugMode: debugMode,
    );

    await isolateContactor._initial();

    return isolateContactor;
  }

  /// Initialize
  Future<void> _initial() async {
    _isolateContactorController =
        IsolateContactorController(StreamController.broadcast());
    _isolateContactorController!.onMessage.listen((message) {
      _printDebug('[Main Stream] rawMessage = $message');
      _isComputing = false;
      _computeStateStreamController.sink.add(ComputeState.computed);
      _mainStreamController.sink.add(message);
    });

    _isolateFunction([_isolateParam, _isolateContactorController]);

    _isComputing = false;
    _computeStateStreamController.sink.add(ComputeState.computed);
    _printDebug('Initialized');
  }

  /// Get current message as stream
  @override
  Stream get onMessage => _mainStreamController.stream;

  /// Get current state
  @override
  Stream<ComputeState> get onComputeState =>
      _computeStateStreamController.stream;

  /// Is current isolate computing
  @override
  bool get isComputing => _isComputing;

  /// Restart current [Isolate]
  ///
  /// Umplemented in web platform at the moment.
  @override
  Future<void> restart() async {
    if (_isolateContactorController == null) {
      _printDebug('! This isolate has been terminated');
      return;
    }

    _isolateContactorController!.close();

    _initial();
  }

  @override
  void close() => dispose();

  @override
  void terminate() => dispose();

  /// Dispose current [Isolate]
  @override
  void dispose() {
    _isComputing = false;
    _computeStateStreamController.sink.add(ComputeState.computed);
    _computeStateStreamController.close;
    _isolateContactorController?.close();
    _isolateContactorController = null;
    _mainStreamController.close();
    _printDebug('Disposed');
  }

  /// Send message to child isolate [function]
  @override
  void sendMessage(dynamic message) {
    if (_isolateContactorController == null) {
      _printDebug('! This isolate has been terminated');
      return;
    }

    if (_isComputing) {
      _printDebug(
          '! This isolate is still computing, so the current request may be revoked!');
    }

    _printDebug('Message send to isolate: $message');
    _isComputing = true;
    _computeStateStreamController.sink.add(ComputeState.computing);
    _isolateContactorController!.sendIsolate(message);
  }

  /// Print if [debugMode] is true
  void _printDebug(Object? object, [bool force = false]) {
    // ignore: avoid_print
    if (_debugMode && !force) print('[Isolate Contactor]: $object');
  }
}
