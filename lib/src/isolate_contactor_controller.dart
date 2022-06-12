import 'dart:async';

import 'isolate_contactor_controller/isolate_contactor_controller_stub.dart'
    if (dart.library.html) 'isolate_contactor_controller/isolate_contactor_controller_web.dart';

abstract class IsolateContactorController<T> {
  /// Create controller for current `IsolateContactor`
  factory IsolateContactorController(dynamic params, {Function()? onDispose}) =
      IsolateContactorControllerIpl<T>;

  /// Get current controller. This method only needs for internal use only
  ///
  /// `StreamController` on Web platform
  /// `IsolateChannel` on other platforms
  dynamic get controller => throw UnimplementedError();

  /// Listen to result of the isolate
  Stream<T> get onMessage => throw UnimplementedError();

  /// Listen to the message is sent to isolate
  Stream get onIsolateMessage => throw UnimplementedError();

  /// Send `message` to the isolate for computation
  void sendIsolate(dynamic message) => throw UnimplementedError();

  /// Send the `result` of computation to `onIsolateMessage` stream
  void sendResult(T result) => throw UnimplementedError();

  /// Close this controller
  void close() => throw UnimplementedError();
}
