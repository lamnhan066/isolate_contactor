import 'dart:async';

import 'package:flutter/foundation.dart';
import 'enum.dart';
import 'isolate_contactor_stub.dart'
    if (dart.library.html) 'isolate_contactor_web.dart';

abstract class IsolateContactor {
  /// The easy way to create isolate function
  ///
  /// [function] must be static or top-level function.
  /// [debugMode] use for printing the status of the plugin,
  /// default is true in Debug and Profile modes.
  static Future<IsolateContactor> create([
    dynamic Function(dynamic)? function,
    bool debugMode = !kReleaseMode,
  ]) async {
    return IsolateContactorInternal.create(
        function: function, debugMode: debugMode);
  }

  /// Create an instance with your own isolate function
  ///
  /// [isolateFunction] You can take a look at the example to see what you need to do
  /// to make it works.
  /// [isolateParams] is the list of parameters that you want to add to your [isolateFunction]
  static Future<IsolateContactor> createOwnIsolate(
    dynamic Function(dynamic) isolateFunction, [
    dynamic isolateParams,
    bool debugMode = !kReleaseMode,
  ]) async {
    return IsolateContactorInternal.createOwnIsolate(
        isolateFunction: isolateFunction,
        isolateParams: isolateParams,
        debugMode: debugMode);
  }

  /// Send message to the [function] for computing
  void sendMessage(dynamic message) => throw UnimplementedError();

  /// Listen to the result of the isolate
  Stream get onMessage => throw UnimplementedError();

  /// Listen to the current state of isolate.
  /// Includes [ComputeState.computed] and [ComputeState.computing]
  Stream<ComputeState> get onComputeState => throw UnimplementedError();

  /// Get current computing state of the isolate
  bool get isComputing => throw UnimplementedError();

  /// Pause the isolate
  void pause() => throw UnimplementedError();

  /// Resume the isolate
  void resume() => throw UnimplementedError();

  /// Restart the paused isolate
  Future<void> restart() async => throw UnimplementedError();

  /// Close current isolate, the same behavior with [dispose]
  void close() => throw UnimplementedError();

  /// Close current isolate, the same behavior with [dispose]
  void terminate() => throw UnimplementedError();

  /// Dispose current isolate
  void dispose() => throw UnimplementedError();
}
