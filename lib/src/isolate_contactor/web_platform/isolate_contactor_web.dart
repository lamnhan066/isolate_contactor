import 'dart:async';

import 'package:isolate_contactor/src/isolate_contactor_controller/isolate_contactor_controller_web.dart';

import '../../../isolate_contactor.dart';
import '../../utils/utils.dart';
import '../isolate_contactor_web.dart';

class IsolateContactorInternalFuture<R, P>
    implements IsolateContactorInternal<R, P> {
  /// For debugging
  bool _debugMode = false;

  /// Check for current isolate in bool
  bool _isComputing = false;

  /// Check for current cumputing state in enum with listener
  final StreamController<ComputeState> _computeStateStreamController =
      StreamController.broadcast();

  /// Check for current cumputing state in enum with listener
  final StreamController<R> _mainStreamController =
      StreamController.broadcast();

  /// Listener for result
  IsolateContactorController<R, P>? _isolateContactorController;

  /// Control the function of isolate
  late void Function(dynamic) _isolateFunction;

  /// Control the parameters of isolate
  late dynamic _isolateParam;

  // ignore: unused_field
  late String _workerName;

  late IsolateConverter<R> _converter;
  late IsolateConverter<R> _workerConverter;
  late bool _autoMarkAsInitialized;

  /// Create an instance
  IsolateContactorInternalFuture._({
    required CustomIsolateFunction isolateFunction,
    required String workerName,
    required Object? isolateParam,
    required IsolateConverter<R> converter,
    required IsolateConverter<R> workerConverter,
    required bool autoMarkAsInitialized,
    bool debugMode = false,
  }) {
    _debugMode = debugMode;
    _isolateFunction = isolateFunction;
    _workerName = workerName;
    _converter = converter;
    _workerConverter = workerConverter;
    _isolateParam = isolateParam;
    _autoMarkAsInitialized = autoMarkAsInitialized;
  }

  /// Create an instance
  static Future<IsolateContactorInternalFuture<R, P>> create<R, P>({
    required IsolateFunction<R, P> function,
    required String functionName,
    required IsolateConverter<R> converter,
    required IsolateConverter<R> workerConverter,
    required bool autoMarkAsInitialized,
    bool debugMode = true,
  }) async {
    IsolateContactorInternalFuture<R, P> isolateContactor =
        IsolateContactorInternalFuture._(
      isolateFunction: internalIsolateFunction,
      workerName: functionName,
      isolateParam: function,
      converter: converter,
      workerConverter: workerConverter,
      autoMarkAsInitialized: autoMarkAsInitialized,
      debugMode: debugMode,
    );

    await isolateContactor._initial();

    return isolateContactor;
  }

  /// Create modified isolate function
  static Future<IsolateContactorInternalFuture<R, P>> createOwnIsolate<R, P>({
    required void Function(dynamic) isolateFunction,
    required String isolateFunctionName,
    required dynamic initialParams,
    required IsolateConverter<R> converter,
    required IsolateConverter<R> workerConverter,
    required bool autoMarkAsInitialized,
    bool debugMode = false,
  }) async {
    IsolateContactorInternalFuture<R, P> isolateContactor =
        IsolateContactorInternalFuture._(
      isolateFunction: isolateFunction,
      workerName: isolateFunctionName,
      isolateParam: initialParams ?? [],
      converter: converter,
      workerConverter: workerConverter,
      autoMarkAsInitialized: autoMarkAsInitialized,
      debugMode: debugMode,
    );

    await isolateContactor._initial();

    return isolateContactor;
  }

  /// Initialize
  Future<void> _initial() async {
    _isolateContactorController = IsolateContactorControllerImpl(
      StreamController.broadcast(),
      converter: _converter,
      workerConverter: _workerConverter,
      onDispose: null,
      autoMarkAsInitialized: _autoMarkAsInitialized,
    );
    _isolateContactorController!.onMessage.listen((message) {
      _printDebug('[Main Stream] Message received from Future: $message');
      _computeStateStreamController.sink.add(ComputeState.computed);
      _mainStreamController.sink.add(message);
      _isComputing = false;
    }).onError((err, stack) {
      _printDebug('[Main Stream] Error message received from Future: $err');
      _computeStateStreamController.sink.add(ComputeState.computed);
      _mainStreamController.sink.addError(err, stack);
      _isComputing = false;
    });

    _isolateFunction([_isolateParam, _isolateContactorController]);

    await _isolateContactorController!.ensureInitialized.future;

    _isComputing = false;
    _computeStateStreamController.sink.add(ComputeState.computed);
    _printDebug('Initialized');
  }

  /// Get current message as stream
  @override
  Stream<R> get onMessage => _mainStreamController.stream;

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
    _isolateContactorController?.sendIsolateState(IsolateState.dispose);
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
  Future<R> sendMessage(P message) {
    if (_isolateContactorController == null) {
      _printDebug('! This isolate has been terminated');
      return throw IsolateException(
        'This isolate was terminated',
        StackTrace.empty,
      );
    }

    if (_isComputing) {
      _printDebug(
          '! This isolate is still being computed, so the current request has been revoked!');

      return throw IsolateException(
        'This isolate is still being computed, so the current request has been revoked',
        StackTrace.empty,
      );
    }

    _isComputing = true;
    _computeStateStreamController.sink.add(ComputeState.computing);

    final Completer<R> completer = Completer();
    StreamSubscription? sub;
    sub = _isolateContactorController!.onMessage.listen((result) async {
      if (!completer.isCompleted) {
        completer.complete(result);
        await sub?.cancel();
      }
    })
      ..onError((err, stack) async {
        completer.completeError(err, stack);
        await sub?.cancel();
      });

    _printDebug('Message send to isolate: $message');

    _isolateContactorController!.sendIsolate(message);

    return completer.future;
  }

  /// Print if [debugMode] is true
  void _printDebug(Object? object, [bool force = false]) {
    // ignore: avoid_print
    if (_debugMode && !force) {
      print('[${IsolateContactor.debugLogPrefix}]: $object');
    }
  }
}
