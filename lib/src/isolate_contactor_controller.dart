import 'dart:async';

import 'isolate_contactor_controller_stub.dart'
    if (dart.library.html) 'isolate_contactor_controller_web.dart';

abstract class IsolateContactorController {
  /// Create controller for current [IsolateContactor]
  factory IsolateContactorController(dynamic params) =
      IsolateContactorControllerIpl;

  StreamController get controller => throw UnimplementedError();

  /// Listen to result of the isolate
  Stream get onMessage => throw UnimplementedError();

  /// Listen to the message is sent to isolate
  Stream get onIsolateMessage => throw UnimplementedError();

  /// Send [message] to the isolate for computation
  void sendIsolate(dynamic message) => throw UnimplementedError();

  /// Send the [result] of computation to [onIsolateMessage] stream
  void sendResult(dynamic result) => throw UnimplementedError();

  /// Close this controller
  void close() => throw UnimplementedError();
}
