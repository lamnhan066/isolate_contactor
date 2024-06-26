// ignore_for_file: avoid_web_libraries_in_flutter, depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as js_util;

// dart compile js map_result.dart -o map_result.js -O4

main() {
  callbackToStream('onmessage', (html.MessageEvent e) {
    return js_util.getProperty(e, 'data');
  }).listen((message) async {
    // TODO: Function for computation here
    final Map<String, String> result = {};

    convertToMap(message).forEach(
        (key, value) => result.addAll({key.toString(): value.toString()}));

    jsSendMessage(jsonEncode(result));
  });
}

/// This must be a static or top-level function
Map<int, double> convertToMap(dynamic n) => {1: n * 1.112, 2: n * 1.112};

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
