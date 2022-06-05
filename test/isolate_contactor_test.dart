// ignore_for_file: avoid_print

import 'dart:async';

import 'package:isolate_contactor/isolate_contactor.dart';
import 'package:test/test.dart';

void main() {
  test('Test', () async {
    StreamController streamController = StreamController.broadcast();

    final stream1 = streamController.stream.listen((event) {
      print('1: $event');
    });

    final stream2 = streamController.stream.listen((event) {
      print('2: $event');
    });

    streamController.add('adb');

    await Future.delayed(const Duration(seconds: 3));
    stream1.cancel();
    stream2.cancel();
  });
  test('Basic use', () async {
    // Just for waiting till the result has come
    bool valueExit = false;

    // Create IsolateContactor
    IsolateContactor<int> isolateContactor =
        await IsolateContactor.create(fibonacci);

    // Listen to the result
    isolateContactor.onMessage.listen((event) {
      print('isolate 1: $event');
      expect(event, 55);

      valueExit = true;
    });

    // Send 10 to fibonacci isolate function
    isolateContactor.sendMessage(10);

    // Only for waiting the result in Console app. Don't need to use in your real app
    while (!valueExit) {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    // Dispose
    isolateContactor.dispose();
  });

  test('Create isolate with build-in function', () async {
    bool value1Exit = false;
    bool value2Exit = false;

    IsolateContactor<int> isolateContactor1 =
        await IsolateContactor.create(fibonacci);
    IsolateContactor<int> isolateContactor2 =
        await IsolateContactor.create(subtract);
    IsolateContactor<int> isolateContactor3 =
        await IsolateContactor.create(fibonacciFuture);

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

    // Listen to f13
    isolateContactor3.onMessage.listen((event) {
      print('isolate 3: $event');
      expect(event, 233);

      value1Exit = true;
    });

    // Send 10 to [fibonacci]
    isolateContactor1.sendMessage(10);

    // Send 20 and 10 to [subtract]
    isolateContactor2.sendMessage([10, 20]);

    // Send 13 to [fibonacciFuture]
    isolateContactor3.sendMessage(13);

    // Only for waiting the result in Console app. Don't need to use in your real app
    while (!value1Exit && !value2Exit) {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    isolateContactor1.dispose();
    isolateContactor2.dispose();
    isolateContactor3.dispose();
  });
  test('Create isolate with your own function', () async {
    bool valueExit = false;

    IsolateContactor isolateContactor =
        await IsolateContactor.createOwnIsolate(isolateFunction);
    // Listen to f20
    isolateContactor.onMessage.listen((event) {
      print('isolate: $event');

      expect(event, 30);

      valueExit = true;
    });

    // Send 10 and 20 to [isolateFunction]
    isolateContactor.sendMessage([10, 20]);

    // Only for waiting the result in Console app. Don't need to use in your real app
    while (!valueExit) {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    isolateContactor.dispose();
  });
}

int fibonacci(dynamic n) {
  if (n <= 2) return 1;

  int n1 = 0, n2 = 1, n3 = 1;

  for (int i = 2; i <= n; i++) {
    n3 = n1 + n2;
    n1 = n2;
    n2 = n3;
  }

  return n3.round();
}

Future<int> fibonacciFuture(dynamic n) async {
  if (n == 0) return 0;
  if (n <= 2) return 1;

  double n1 = 0, n2 = 1, n3 = 1;

  for (int i = 2; i <= n; i++) {
    n3 = n1 + n2;
    n1 = n2;
    n2 = n3;

    // Magic code: This is only for non-blocking UI in Web platform
    await Future.delayed(Duration.zero);
  }

  return n3.round();
}

// single parameter
int subtract(dynamic n) => n[1] - n[0];

// multi parameters as an dynamic
int add(dynamic a, dynamic b) => a + b;

// Create your own function here
void isolateFunction(dynamic params) {
  final channel = IsolateContactorController(params);
  channel.onIsolateMessage.listen((message) {
    channel.sendResult(add(message[0], message[1]));
  });
}
