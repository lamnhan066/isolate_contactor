import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_contactor/isolate_contactor.dart';
import 'package:stream_channel/isolate_channel.dart';

void main() {
  test('Basic use', () async {
    // Just for waiting till the result has come
    bool valueExit = false;

    // Create IsolateContactor
    IsolateContactor isolateContactor =
        await IsolateContactor.create(fibonacci);

    // Listen to the result
    isolateContactor.onMessage.listen((event) {
      print('isolate 1: $event');
      expect(event, 55);

      valueExit = true;
    });

    // Send 10 to fibonacci isolate function
    isolateContactor.sendMessage(10);

    // Only for waiting the result. Don't need to use in your real app
    while (!valueExit) {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    // Dispose
    isolateContactor.dispose();
  });

  test('Create isolate with build-in function', () async {
    bool value1Exit = false;
    bool value2Exit = false;

    IsolateContactor isolateContactor1 =
        await IsolateContactor.create(fibonacci);
    IsolateContactor isolateContactor2 =
        await IsolateContactor.create(subtract);

    // Listen to f10
    isolateContactor1.onMessage.listen((event) {
      print('isolate 1: $event');
      expect(event, 55);

      value1Exit = true;
    });

    // Listen to f20
    isolateContactor2.onMessage.listen((event) {
      print('isolate 3: $event');

      expect(event, 10);

      value2Exit = true;
    });

    // Send 10 to [fibonacci]
    isolateContactor1.sendMessage(10);

    // Send 20 and 10 to [subtract]
    isolateContactor2.sendMessage([10, 20]);

    while (!value1Exit && !value2Exit) {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    isolateContactor1.dispose();
    isolateContactor2.dispose();
  });
  test('Create isolate with your own function', () async {
    bool valueExit = false;

    IsolateContactor isolateContactor =
        await IsolateContactor.createOwnIsolate(isolateFunction);
    // Listen to f20
    isolateContactor.onMessage.listen((event) {
      print('isolate 2: $event');

      expect(event, 30);

      valueExit = true;
    });

    // Send 10 and 20 to [isolateFunction]
    isolateContactor.sendMessage([10, 20]);

    while (!valueExit) {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    isolateContactor.dispose();
  });
}

dynamic fibonacci(dynamic n) {
  if (n == 0) return 0;
  if (n == 1 || n == 2) return 1;

  return fibonacci(n - 2) + fibonacci(n - 1);
}

// single parameter
dynamic subtract(dynamic n) => n[1] - n[0];

// multi parameters as an dynamic
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
