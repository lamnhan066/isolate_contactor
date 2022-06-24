// ignore_for_file: avoid_web_libraries_in_flutter, depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;

import 'package:js/js.dart' as pjs;
import 'package:js/js_util.dart' as js_util;

@pjs.JS('self')
external dynamic get globalScopeSelf;

/// You should rename the <function_name> to its name for later use.
///
/// dart compile js <function_name>.dart -o <function_name>.js

/// Modify your function here, you can use your top-level or static method that
/// you have been created for you IsolateManager.
///
/// Just make sure that the function does not depend or import any libraries related
/// to Flutter.
dynamic functionName(dynamic message) => message;

main() {
  callbackToStream('onmessage', (html.MessageEvent e) {
    return js_util.getProperty(e, 'data');
  }).listen((message) async {
    // Compute the inputed data
    final result = await functionName(message);

    // Send the result to main isolate
    jsSendMessage(result);
  });
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
  js.context.callMethod('postMessage', [jsonEncode(m)]);
}
