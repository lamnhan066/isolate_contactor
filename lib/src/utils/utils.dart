import 'dart:async';

import '../isolate_contactor_controller.dart';

/// States of current isolate
enum ComputeState { computing, computed }

/// Port for sending message
enum IsolatePort { main, isolate }

/// Isolate state
enum IsolateState { dispose }

/// Get data with port
dynamic getPortMessage(IsolatePort toPort, dynamic rawMessage) {
  try {
    return rawMessage[toPort];
  } catch (_) {}
  return null;
}

/// Create a static function to compunicate with main `Isolate`
void internalIsolateFunction(dynamic params) {
  var channel = IsolateContactorController(params, onDispose: () {});
  channel.onIsolateMessage.listen((message) {
    Completer completer = Completer();
    completer.future.then((value) => channel.sendResult(value));
    completer.complete(params[0](message));
  });
}
