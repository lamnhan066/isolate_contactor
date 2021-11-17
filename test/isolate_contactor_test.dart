import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_contactor/isolate_contactor.dart';

void main() {
  test('Create 2 IsolateContactors and listen to its result', () async {
    bool value1Exit = false;
    bool value2Exit = false;

    IsolateContactor isolateContactor1 =
        await IsolateContactor.create(fibonancci);
    IsolateContactor isolateContactor2 =
        await IsolateContactor.create(fibonancci);

    // Listen to f10
    isolateContactor1.onMessage.listen((event) {
      expect(event, 55);

      value1Exit = true;
    });

    // Listen to f20
    isolateContactor2.onMessage.listen((event) {
      expect(event, 6765);

      value2Exit = true;
    });

    isolateContactor1.sendMessage(10);
    isolateContactor2.sendMessage(20);

    while (!value1Exit && !value2Exit) {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    isolateContactor1.dispose();
    isolateContactor2.dispose();
  });
}

dynamic fibonancci(dynamic n) {
  if (n == 0) return 0;
  if (n == 1 || n == 2) return 1;

  return fibonancci(n - 2) + fibonancci(n - 1);
}
