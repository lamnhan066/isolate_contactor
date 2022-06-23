import 'dart:async';
import 'dart:html' as html;

import '../isolate_contactor.dart';
import '../isolate_contactor_controller.dart';
import '../utils/utils.dart';

main() async {
  if (html.Worker.supported) {
    var myWorker = html.Worker("ww.dart.js");
    myWorker.onMessage.listen((event) {
      print("main:receive: ${event.data}");
    });
    myWorker.postMessage("Hello!!");
  } else {
    print('Your browser doesn\'t support web workers.');
  }
}

class IsolateContactorInternal<T> implements IsolateContactor<T> {
  /// For debugging
  bool _debugMode = false;

  /// Check for current isolate in bool
  bool _isComputing = false;

  /// Check for current cumputing state in enum with listener
  final StreamController<ComputeState> _computeStateStreamController =
      StreamController.broadcast();

  /// Check for current cumputing state in enum with listener
  final StreamController<T> _mainStreamController =
      StreamController.broadcast();

  /// Listener for result
  IsolateContactorController<T>? _isolateContactorController;

  /// Control the function of isolate
  late void Function(dynamic) _isolateFunction;

  /// Control the parameters of isolate
  late dynamic _isolateParam;

  late html.Worker worker;

  /// Create an instance
  IsolateContactorInternal._({
    required FutureOr<void> Function(dynamic) isolateFunction,
    required dynamic isolateParam,
    bool debugMode = false,
  }) {
    _debugMode = debugMode;
    _isolateFunction = isolateFunction;
    _isolateParam = isolateParam;
  }

  /// Create an instance
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

  /// Create modified isolate function
  static Future<IsolateContactorInternal<T>> createOwnIsolate<T>({
    required void Function(dynamic) isolateFunction,
    required dynamic initialParams,
    bool debugMode = false,
  }) async {
    IsolateContactorInternal<T> isolateContactor = IsolateContactorInternal._(
      isolateFunction: isolateFunction,
      isolateParam: initialParams ?? [],
      debugMode: debugMode,
    );

    await isolateContactor._initial();

    return isolateContactor;
  }

  /// Initialize
  Future<void> _initial() async {
    _isolateContactorController =
        IsolateContactorController(StreamController.broadcast());
    // _isolateContactorController!.onMessage.listen((message) {
    //   _printDebug('[Main Stream] rawMessage = $message');
    //   _computeStateStreamController.sink.add(ComputeState.computed);
    //   _mainStreamController.sink.add(message);
    //   _isComputing = false;
    // });

    worker = html.Worker("web_child.dart.js");
    worker.onMessage.listen((event) {
      final message = event.data;
      _printDebug('[Main Stream] rawMessage = $message');
      _computeStateStreamController.sink.add(ComputeState.computed);
      _mainStreamController.sink.add(message);
      _isComputing = false;
    });

    // _isolateFunction([_isolateParam, _isolateContactorController]);
    // myWorker.postMessage([_isolateParam, _isolateContactorController]);

    _isComputing = false;
    _computeStateStreamController.sink.add(ComputeState.computed);
    _printDebug('Initialized');
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
  Future<void> close() => dispose();

  @override
  Future<void> terminate() => dispose();

  /// Dispose current [Isolate]
  @override
  Future<void> dispose() async {
    _isComputing = false;
    _isolateContactorController?.sendIsolate(IsolateState.dispose);
    _computeStateStreamController.sink.add(ComputeState.computed);

    _computeStateStreamController.close;
    await _isolateContactorController?.close();
    await _mainStreamController.close();

    _isolateContactorController = null;

    _printDebug('Disposed');
  }

  /// Send message to child isolate [function].
  ///
  /// Throw IsolateContactorException if error occurs.
  @override
  Future<T> sendMessage(dynamic message) {
    worker.postMessage([10, 20]);

    if (_isolateContactorController == null) {
      _printDebug('! This isolate has been terminated');
      return throw IsolateContactorException('This isolate was terminated');
    }

    if (_isComputing) {
      _printDebug(
          '! This isolate is still being computed, so the current request has been revoked!');

      return throw IsolateContactorException(
          'This isolate is still being computed, so the current request has been revoked');
    }

    _isComputing = true;
    _computeStateStreamController.sink.add(ComputeState.computing);

    final Completer<T> completer = Completer();
    _isolateContactorController!.onMessage.listen((result) {
      if (!completer.isCompleted) completer.complete(result);
    });

    _printDebug('Message send to isolate: $message');

    _isolateContactorController!.sendIsolate(message);

    return completer.future;
  }

  /// Print if [debugMode] is true
  void _printDebug(Object? object, [bool force = false]) {
    // ignore: avoid_print
    if (_debugMode && !force) print('[Isolate Contactor]: $object');
  }
}
