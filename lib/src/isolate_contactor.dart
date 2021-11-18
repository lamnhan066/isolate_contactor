import 'dart:async';

import 'package:flutter/foundation.dart';

import 'enum.dart';
// import 'internal.dart' if (dart.library.html) 'internal_web.dart';
import 'internal_web.dart';

abstract class IsolateContactor {
  /// The easy way to create isolate function
  ///
  /// - [function] must be static or top-level function.
  /// - [debugMode] use for printing the status of the plugin,
  /// default is true in Debug and Profile modes.
  ///
  /// Example of [function]:
  /// ``` dart
  /// dynamic fibonacci(dynamic n) {
  ///   if (n == 0) return 0;
  ///   if (n == 1 || n == 2) return 1;
  ///
  ///   return fibonacci(n - 1) + fibonacci(n - 2);
  /// }
  /// ```
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
  ///
  /// This is form of the [isolateFunction]:
  /// ``` dart
  /// void isolateFunction(dynamic params) {
  ///   final channel = IsolateChannel.connectSend(params.last);
  ///   channel.stream.listen((rawMessage) {
  ///     final message = IsolateContactor.getMessage(rawMessage);
  ///     if (message != null) {
  ///       // Do more stuff here, [message] is dynamic so you can pass any
  ///       // supported type
  ///
  ///       channel.sendResult(fibonacci(message));
  ///     }
  ///   });
  /// }
  /// ```
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

  /// Listen to the result of the [function]
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

  /// Use in isolate function
  // static dynamic getMessage(dynamic rawMessage) =>
  //     IsolateContactorInternal.getMessage(IsolatePort.child, rawMessage);

  /// Get data with port
  static dynamic getRawMessage(IsolatePort toPort, dynamic rawMessage) {
    try {
      return rawMessage[toPort];
    } catch (_) {}
    return null;
  }
}
