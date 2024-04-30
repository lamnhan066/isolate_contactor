import 'dart:async';
import 'dart:convert';

import '../isolate_contactor_controller.dart';
import 'exception.dart';

/// States of current isolate
enum ComputeState { computing, computed }

/// Port for sending message
enum IsolatePort { main, isolate }

/// Isolate state
enum IsolateState {
  /// A dispose state
  dispose,

  /// An initialized state
  initialized;

  /// {
  ///   type: '$IsolateState',
  ///   value: '<name>',
  /// }
  String toJson() => jsonEncode({'type': r'$IsolateState', 'value': name});

  /// Check if the [object] is a valid enum.
  bool isValidJson(Object? object) {
    try {
      final decoded = jsonDecode(object.toString()) as Map;
      return decoded['type'] == r'$IsolateState' && decoded['value'] == name;
    } catch (_) {}
    return false;
  }
}

/// Create a static function to compunicate with main `Isolate`
@pragma('vm:entry-point')
void internalIsolateFunction(dynamic params) {
  final controller = IsolateContactorController(params, onDispose: () {});
  final function = controller.initialParams;
  controller.onIsolateMessage.listen((message) {
    Completer completer = Completer();
    completer.future.then(
      (value) => controller.sendResult(value),
      onError: (err, stack) =>
          controller.sendResultError(IsolateException(err, stack)),
    );

    try {
      completer.complete(function(message));
    } catch (err, stack) {
      controller.sendResultError(IsolateException(err, stack));
    }
  });
  controller.initialized();
}
