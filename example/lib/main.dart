import 'dart:math';

import 'package:flutter/material.dart';
import 'package:isolate_contactor/isolate_contactor.dart';
import 'package:stream_channel/isolate_channel.dart';

void main() {
  runApp(const MyApp());
}

/// This must be a static or top-level function
dynamic fibonacci(dynamic n) {
  if (n == 0) return 0;
  if (n == 1 || n == 2) return 1;

  return fibonacci(n - 1) + fibonacci(n - 2);
}

void isolateFunction(List<dynamic> params) {
  final channel = IsolateChannel.connectSend(params.last);
  channel.stream.listen((rawMessage) {
    final message = IsolateContactor.getMessage(rawMessage);
    if (message != null) {
      // Do more stuff here

      channel.sendResult(fibonacci(message));
    }
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late IsolateContactor isolateContactor1;
  late IsolateContactor isolateContactor2;
  int value1 = 2;
  int value2 = 3;

  bool isLoading = true;
  Random rad = Random();

  @override
  void initState() {
    initial();
    super.initState();
  }

  @override
  void dispose() {
    isolateContactor1.dispose();
    isolateContactor2.dispose();
    super.dispose();
  }

  Future<void> initial() async {
    isolateContactor1 = await IsolateContactor.create(fibonacci);
    isolateContactor2 =
        await IsolateContactor.createOwnIsolate(isolateFunction);
    setState(() => isLoading = false);
  }

  void calculateValue1([int max = 50]) {
    value1 = rad.nextInt(max);
    print('Isolate 1: Calculate fibonancci at F$value1');
    isolateContactor1.sendMessage(value1);
  }

  void calculateValue2([int max = 50]) {
    value2 = rad.nextInt(max);
    print('Isolate 2: Calculate fibonancci at F$value2');
    isolateContactor2.sendMessage(value2);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: isLoading
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      StreamBuilder(
                        stream: isolateContactor1.onMessage,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            isolateContactor1.sendMessage(value1);
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return Text(
                              'Isolate1: Fibonacci at F$value1 = ${snapshot.data}');
                        },
                      ),
                      StreamBuilder(
                          stream: isolateContactor1.onComputeState,
                          builder: (context, snapshot) {
                            return ListTile(
                              title: ElevatedButton(
                                onPressed: () => calculateValue1(),
                                child: Text(snapshot.data != null &&
                                        snapshot.data == ComputeState.computing
                                    ? 'Computing F$value1..'
                                    : 'Calculate new Fibonacci'),
                              ),
                            );
                          }),
                      ListTile(
                        title: ElevatedButton(
                          onPressed: () {
                            isolateContactor1.restart();
                          },
                          child: const Text('Restart isolate 1'),
                        ),
                      ),
                      StreamBuilder(
                        stream: isolateContactor2.onMessage,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            isolateContactor2.sendMessage(value2);
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return Text(
                              'Isolate2: Fibonacci at F$value2 = ${snapshot.data}');
                        },
                      ),
                      StreamBuilder(
                          stream: isolateContactor2.onComputeState,
                          builder: (context, snapshot) {
                            return ListTile(
                              title: ElevatedButton(
                                onPressed: () => calculateValue2(),
                                child: Text(snapshot.data != null &&
                                        snapshot.data == ComputeState.computing
                                    ? 'Computing F$value2..'
                                    : 'Calculate new Fibonacci'),
                              ),
                            );
                          }),
                      ListTile(
                        title: ElevatedButton(
                          onPressed: () {
                            isolateContactor2.terminate();
                          },
                          child: const Text('Terminate isolate 2'),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
