import 'dart:async';

import 'package:isolate_contactor/src/utils/exception.dart';
import 'package:isolate_contactor/src/utils/utils.dart';

import 'isolate_contactor_controller/isolate_contactor_controller_web.dart'
    if (dart.library.io) 'isolate_contactor_controller/isolate_contactor_controller_stub.dart';

abstract class IsolateContactorController<R, P> {
  /// Create controller for current `IsolateContactor`
  ///
  /// `params` is the default parameters of the isolate function.
  ///
  /// `onDispose` is called when the controller is disposed.
  factory IsolateContactorController(
    /// `params` is the default parameters of the isolate function.
    dynamic params, {
    /// `onDispose` is called when the controller is disposed.
    Function()? onDispose,
  }) =>
      IsolateContactorControllerImpl<R, P>(
        params,
        autoMarkAsInitialized: true,
        onDispose: onDispose,
        converter: null,
        workerConverter: null,
      );

  /// Mark as initialized.
  void initialized() => throw UnimplementedError();

  /// Get current controller. This method only needs for internal use only
  ///
  /// `StreamController` on Web platform
  /// `IsolateChannel` on other platforms
  dynamic get controller => throw UnimplementedError();

  /// Get initial params for `createOwnIsolate`
  dynamic get initialParams => throw UnimplementedError();

  /// Listen to result from the isolate
  Stream<R> get onMessage => throw UnimplementedError();

  /// Listen to the message is sent to isolate
  Stream<P> get onIsolateMessage => throw UnimplementedError();

  /// Ensure the `Isolate`/`Worker` has been initialized
  Completer<void> get ensureInitialized => throw UnimplementedError();

  /// Send `message` to the isolate for computation
  void sendIsolate(P message) => throw UnimplementedError();

  /// Send an `IsolateState` message to the isolate
  void sendIsolateState(IsolateState state) => throw UnimplementedError();

  /// Send the `result` of computation to `onIsolateMessage` stream
  void sendResult(R result) => throw UnimplementedError();

  /// Send the `Exception` to the main app
  void sendResultError(IsolateException exception) =>
      throw UnimplementedError();

  /// Close this controller
  Future<void> close() => throw UnimplementedError();
}
