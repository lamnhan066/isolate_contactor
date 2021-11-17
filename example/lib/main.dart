import 'dart:math';

import 'package:flutter/material.dart';
import 'package:isolate_contactor/isolate_contactor.dart';

void main() {
  runApp(const MyApp());
}

dynamic fibo(dynamic n) {
  if (n == 0) return 0;
  if (n == 1 || n == 2) return 1;

  return fibo(n - 1) + fibo(n - 2);
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoading = true;
  late IsolateContactor isolateContactor1;
  late IsolateContactor isolateContactor2;
  int value1 = 2;
  int value2 = 3;
  bool value1Computing = false;
  bool value2Computing = false;

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
    isolateContactor1 = await IsolateContactor.create(fibo);
    isolateContactor2 = await IsolateContactor.create(fibo);
    setState(() => isLoading = false);
  }

  void calculateValue1([int max = 50]) {
    value1 = rad.nextInt(max);
    print('Isolate 1: Calculate fibonancci at F$value1');
    isolateContactor1.sendMessage(value1);

    setState(() => value1Computing = true);
  }

  void calculateValue2([int max = 50]) {
    value2 = rad.nextInt(max);
    print('Isolate 2: Calculate fibonancci at F$value2');
    isolateContactor2.sendMessage(value2);

    setState(() => value2Computing = true);
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
                          // setState(() => value1Computing = false);

                          return Text(
                              'Isolate1: Fibonacci at F$value1 = ${snapshot.data}');
                        },
                      ),
                      ListTile(
                        title: ElevatedButton(
                          onPressed: () {
                            Random rad = Random();
                            value1 = rad.nextInt(60);
                            print(
                                'Isolate 1: Calculate fibonancci at F$value1');
                            isolateContactor1.sendMessage(value1);
                          },
                          child: Text(value1Computing
                              ? 'Computing F$value1..'
                              : 'Calculate new Fibonacci'),
                        ),
                      ),
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
                          // setState(() => value2Computing = false);

                          return Text(
                              'Isolate2: Fibonacci at F$value2 = ${snapshot.data}');
                        },
                      ),
                      ListTile(
                        title: ElevatedButton(
                          onPressed: () {
                            Random rad = Random();
                            value2 = rad.nextInt(60);
                            print(
                                'Isolate 2: Calculate fibonancci at F$value2');
                            isolateContactor2.sendMessage(value2);
                          },
                          child: Text(value2Computing
                              ? 'Computing F$value2..'
                              : 'Calculate new Fibonacci'),
                        ),
                      ),
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
