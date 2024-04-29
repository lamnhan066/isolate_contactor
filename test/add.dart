// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as js_util;

import 'package:isolate_contactor/isolate_contactor.dart';

// dart compile js add.dart -o add.js -O4

main() {
  callbackToStream('onmessage', (html.MessageEvent e) {
    return js_util.getProperty(e, 'data');
  }).listen((message) async {
    // TODO: Function for computation here
    final result = add(message);

    jsSendMessage(result);
  });
  jsSendMessage(IsolateState.initialized.serialization);
}

/// Modify your function here
double add(dynamic message) => message[0] + message[1];

Stream<T> callbackToStream<J, T>(
    String name, T Function(J jsValue) unwrapValue) {
  var controller = StreamController<T>.broadcast(sync: true);
  js_util.setProperty(js.context['self'], name, js.allowInterop((J event) {
    controller.add(unwrapValue(event));
  }));
  return controller.stream;
}

void jsSendMessage(dynamic m) {
  js.context.callMethod('postMessage', [m]);
}
