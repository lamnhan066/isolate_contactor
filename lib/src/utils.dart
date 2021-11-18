import 'isolate_contactor_controller.dart';

/// States of current isolate
enum ComputeState { computing, computed }

/// Port for sending message
enum IsolatePort { main, child, debug }

/// Get data with port
dynamic getIsolatePortMessage(IsolatePort toPort, dynamic rawMessage) {
  try {
    return rawMessage[toPort];
  } catch (_) {}
  return null;
}

/// Create a static function to compunicate with main [Isolate]
void internalIsolateFunction(dynamic params) {
  var channel = IsolateContactorController(params);
  channel.onIsolateMessage.listen((message) {
    try {
      (params[0](message) as Future).then((value) {
        channel.sendResult(value);
      });
    } catch (_) {
      try {
        channel.sendResult(params[0](message));
      } catch (_) {}
    }
  });
}
