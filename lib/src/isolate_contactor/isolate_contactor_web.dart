import 'dart:async';

import 'package:isolate_contactor/src/utils/utils.dart';

import '../isolate_contactor.dart';
import 'web_platform/isolate_contactor_web.dart';
import 'web_platform/isolate_contactor_web_worker.dart';

abstract class IsolateContactorInternal<R, P>
    implements IsolateContactor<R, P> {
  /// Create an instance
  static Future<IsolateContactorInternal<R, P>> create<R, P>({
    required IsolateFunction<R, P> function,
    required String workerName,
    required IsolateConverter<R> converter,
    required IsolateConverter<R> workerConverter,
    required bool autoMarkAsInitialized,
    bool debugMode = true,
  }) async {
    /// If browser is not supported Worker then use Future
    if (workerName != '') {
      try {
        return IsolateContactorInternalWorker.create(
          function: function,
          workerName: workerName,
          converter: converter,
          workerConverter: workerConverter,
          autoMarkAsInitialized: autoMarkAsInitialized,
          debugMode: debugMode,
        );
      } catch (_) {
        print(
            '[Isolate Manager]: This browser doesn\'t support Worker, Future will be applied!');
      }
    }
    return IsolateContactorInternalFuture.create(
      function: function,
      functionName: workerName,
      converter: converter,
      workerConverter: workerConverter,
      autoMarkAsInitialized: autoMarkAsInitialized,
      debugMode: debugMode,
    );
  }

  /// Create modified isolate function
  static Future<IsolateContactorInternal<R, P>> createOwnIsolate<R, P>({
    required CustomIsolateFunction isolateFunction,
    required String workerName,
    required Object? initialParams,
    required IsolateConverter<R> converter,
    required IsolateConverter<R> workerConverter,
    required bool autoMarkAsInitialized,
    bool debugMode = false,
  }) async {
    /// If browser is not supported Worker then use Future
    if (workerName != '') {
      try {
        return IsolateContactorInternalWorker.createOwnIsolate(
          isolateFunction: isolateFunction,
          workerName: workerName,
          initialParams: initialParams,
          converter: converter,
          workerConverter: workerConverter,
          autoMarkAsInitialized: autoMarkAsInitialized,
          debugMode: debugMode,
        );
      } catch (_) {
        print(
            '[Isolate Manager]: This browser doesn\'t support Worker, Future will be applied!');
      }
    }
    return IsolateContactorInternalFuture.createOwnIsolate(
      isolateFunction: isolateFunction,
      isolateFunctionName: workerName,
      initialParams: initialParams,
      converter: converter,
      workerConverter: workerConverter,
      autoMarkAsInitialized: autoMarkAsInitialized,
      debugMode: debugMode,
    );
  }

  @override
  Future<void> close() {
    throw UnimplementedError();
  }

  @override
  Future<void> dispose() {
    throw UnimplementedError();
  }

  @override
  bool get isComputing => throw UnimplementedError();

  @override
  Stream<ComputeState> get onComputeState => throw UnimplementedError();

  @override
  Stream<R> get onMessage => throw UnimplementedError();

  @override
  Future<void> restart() {
    throw UnimplementedError();
  }

  @override
  Future<R> sendMessage(P message) {
    throw UnimplementedError();
  }

  @override
  Future<void> terminate() {
    throw UnimplementedError();
  }
}
