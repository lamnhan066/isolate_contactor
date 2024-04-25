// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as js_util;

import 'package:isolate_contactor/src/utils/exception.dart';

// dart compile js error_function.dart -o error_function.js -O4

main() {
  callbackToStream('onmessage', (html.MessageEvent e) {
    return js_util.getProperty(e, 'data');
  }).listen((message) async {
    final Completer completer = Completer();
    completer.future.then(
      (value) => jsSendMessage(value),
      onError: (err, stack) =>
          jsSendMessage(IsolateException(err, stack).toJson()),
    );
    try {
      completer.complete(errorFunction(message));
    } catch (err, stack) {
      jsSendMessage(IsolateException(err, stack).toJson());
    }
  });
}

/// Modify your function here
int errorFunction(dynamic value) {
  if (value == 10) {
    // You should only throw the `message` instead of a whole Object because it may
    // not show as expected when sending back to the main app.
    return throw 'This is an error function, error value is $value';
  }

  return value;
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
