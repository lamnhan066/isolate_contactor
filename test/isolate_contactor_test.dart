import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_contactor/isolate_contactor.dart';
import 'package:stream_channel/isolate_channel.dart';

void main() {
  test('Create 2 IsolateContactors and listen to its result', () async {
    bool value1Exit = false;
    bool value2Exit = false;
    bool value3Exit = false;

    IsolateContactor isolateContactor1 =
        await IsolateContactor.create(fibonacci);
    IsolateContactor isolateContactor2 =
        await IsolateContactor.createOwnIsolate(isolateFunction);
    IsolateContactor isolateContactor3 =
        await IsolateContactor.create(subtract);

    // Listen to f10
    isolateContactor1.onMessage.listen((event) {
      print('isolate 1: $event');
      expect(event, 55);

      value1Exit = true;
    });

    // Listen to f20
    isolateContactor2.onMessage.listen((event) {
      print('isolate 2: $event');

      expect(event, 30);

      value2Exit = true;
    });

    // Listen to f20
    isolateContactor3.onMessage.listen((event) {
      print('isolate 3: $event');

      expect(event, 10);

      value3Exit = true;
    });

    // Send 10 to [fibonacci]
    isolateContactor1.sendMessage(10);

    // Send 10 and 20 to [isolateFunction]
    isolateContactor2.sendMessage([10, 20]);

    // Send 20 and 10 to [subtract]
    isolateContactor3.sendMessage([10, 20]);

    while (!value1Exit && !value2Exit && !value3Exit) {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    isolateContactor1.dispose();
    isolateContactor2.dispose();
  });
}

dynamic fibonacci(dynamic n) {
  if (n == 0) return 0;
  if (n == 1 || n == 2) return 1;

  return fibonacci(n - 2) + fibonacci(n - 1);
}

dynamic subtract(dynamic n) => n[1] - n[0];

dynamic add(dynamic a, dynamic b) => a + b;

// Create your own function here
void isolateFunction(List<dynamic> params) {
  final channel = IsolateChannel.connectSend(params.last);
  channel.stream.listen((rawMessage) {
    final message = IsolateContactor.getMessage(rawMessage);
    if (message != null) {
      // Do more stuff here

      channel.sendResult(add(message[0], message[1]));
    }
  });
}
