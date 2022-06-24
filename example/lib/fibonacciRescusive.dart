// ignore_for_file: avoid_web_libraries_in_flutter, file_names
import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

import 'package:js/js.dart' as pjs;
import 'package:js/js_util.dart' as js_util;

@pjs.JS('self')
external dynamic get globalScopeSelf;

// dart compile js fibonacciRescusive.dart -o fibonacciRescusive.js

main() {
  callbackToStream('onmessage', (html.MessageEvent e) {
    return js_util.getProperty(e, 'data');
  }).listen((message) async {
    // TODO: Function for computation here
    final result = fibonacciRescusive(message);

    jsSendMessage(result);
  });
}

/// This must be a static or top-level function
int fibonacciRescusive(dynamic n) {
  if (n == 0) return 0;
  if (n <= 2) return 1;

  return fibonacciRescusive(n - 1) + fibonacciRescusive(n - 2);
}

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
