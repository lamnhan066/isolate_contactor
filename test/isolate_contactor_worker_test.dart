import 'package:isolate_contactor/isolate_contactor.dart';
import 'package:test/test.dart';

void main() {
  // if (args != null && args.isEmpty) {
  //   print(args);

  //   IsolateContactor.register(fibonacci);
  // }

  group('Test new Worker', () {
    test('Test for Worker (Web only with flag --platform=chrome)', () async {
      // Create IsolateContactor
      IsolateContactor<int> isolateContactor = await IsolateContactor.create(
        fibonacci,
        workerName: 'isolate_contactor_worker_test.dart',
        // converter: (result) => int.parse(result.toString()),
      );

      IsolateContactor<double> isolateContactor1 =
          await IsolateContactor.create(
        add,
        workerName: 'add',
      );

      // Listen to the result
      isolateContactor.onMessage.listen((event) {
        print('isolate 1: $event');
        expect(event, 55);
      });

      // Send 10 to fibonacci isolate function
      final result = await isolateContactor.sendMessage(10);
      print('Result from fibonacci.js: $result');
      expect(result, 55);

      final result1 = await isolateContactor1.sendMessage([10.0, 15.0]);
      print('Result from add.js: $result1');
      expect(result1, 25);

      // Dispose
      isolateContactor.dispose();
    });
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

// multi parameters as an dynamic
double add(dynamic message) => message[0] + message[1];
