import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

// ignore: depend_on_referenced_packages
import 'package:js/js.dart' as pjs;
// ignore: depend_on_referenced_packages
import 'package:js/js_util.dart' as js_util;

@pjs.JS('self')
external dynamic get globalScopeSelf;

Stream<T> callbackToStream<J, T>(
    String name, T Function(J jsValue) unwrapValue) {
  var controller = StreamController<T>.broadcast(sync: true);
  js_util.setProperty(js.context['self'], name, js.allowInterop((J event) {
    controller.add(unwrapValue(event));
  }));
  return controller.stream;
}

void jsSendMessage(dynamic object, dynamic m) {
  js.context.callMethod('postMessage', [m]);
}

main() {
  callbackToStream('onmessage', (html.MessageEvent e) {
    return js_util.getProperty(e, 'data');
  }).listen((message) {
    print('>>> $message');

    jsSendMessage(js.context, message[0] + message[1]);
  });
}
