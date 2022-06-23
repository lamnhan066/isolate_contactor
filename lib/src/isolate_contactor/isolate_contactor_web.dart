import 'dart:async';

import 'package:isolate_contactor/src/utils/utils.dart';

import '../isolate_contactor.dart';
import 'web_platform/isolate_contactor_web.dart';
import 'web_platform/isolate_contactor_web_worker.dart';

abstract class IsolateContactorInternal<T> implements IsolateContactor<T> {
  /// Create an instance
  static Future<IsolateContactorInternal<T>> create<T>({
    required FutureOr<T> Function(dynamic) function,
    required String workerName,
    bool debugMode = true,
  }) async {
    if (workerName == '') {
      return IsolateContactorInternalFuture.create(
        function: function,
        functionName: workerName,
        debugMode: debugMode,
      );
    } else {
      return IsolateContactorInternalWorker.create(
        function: function,
        workerName: workerName,
        debugMode: debugMode,
      );
    }
  }

  /// Create modified isolate function
  static Future<IsolateContactorInternal<T>> createOwnIsolate<T>({
    required void Function(dynamic) isolateFunction,
    required String workerName,
    required dynamic initialParams,
    bool debugMode = false,
  }) async {
    if (workerName == '') {
      return IsolateContactorInternalFuture.createOwnIsolate(
        isolateFunction: isolateFunction,
        isolateFunctionName: workerName,
        initialParams: initialParams,
        debugMode: debugMode,
      );
    } else {
      return IsolateContactorInternalWorker.createOwnIsolate(
        isolateFunction: isolateFunction,
        isolateFunctionName: workerName,
        initialParams: initialParams,
        debugMode: debugMode,
      );
    }
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
  Stream<T> get onMessage => throw UnimplementedError();

  @override
  Future<void> restart() {
    throw UnimplementedError();
  }

  @override
  Future<T> sendMessage(message) {
    throw UnimplementedError();
  }

  @override
  Future<void> terminate() {
    throw UnimplementedError();
  }
}
