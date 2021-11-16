import 'dart:math';

import 'package:flutter/material.dart';
import 'package:isolate_contactor/isolate_contactor.dart';

void main() {
  runApp(const MyApp());
}

IsolateContactor? isolateContactor1 = IsolateContactor(fibo);
IsolateContactor? isolateContactor2 = IsolateContactor(fibo);

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
  int value1 = 0;
  int value2 = 0;

  @override
  void initState() {
    isolateContactor1?.sendMessage(value1);
    isolateContactor2?.sendMessage(value2);
    super.initState();
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                StreamBuilder(
                  stream: isolateContactor1?.onMessage,
                  builder: (context, snapshot) {
                    print(snapshot.connectionState);
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Text(
                        'Isolate1: Fibonacci at F$value1 = ${snapshot.data}');
                  },
                ),
                ListTile(
                  title: ElevatedButton(
                    onPressed: () {
                      Random rad = Random();
                      value1 = rad.nextInt(60);
                      print('Isolate 1: Calculate fibonancci at F$value1');
                      isolateContactor1?.sendMessage(value1);
                    },
                    child: Text('Tap'),
                  ),
                ),
                ListTile(
                  title: ElevatedButton(
                    onPressed: () {
                      isolateContactor2?.restart();
                    },
                    child: Text('Restart isolate 1'),
                  ),
                ),
                StreamBuilder(
                  stream: isolateContactor2?.onMessage,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Text(
                        'Isolate2: Fibonacci at F$value2 = ${snapshot.data}');
                  },
                ),
                ListTile(
                  title: ElevatedButton(
                    onPressed: () {
                      Random rad = Random();
                      value2 = rad.nextInt(60);
                      print('Isolate 2: Calculate fibonancci at F$value2');
                      isolateContactor2?.sendMessage(value2);
                    },
                    child: Text('Tap'),
                  ),
                ),
                ListTile(
                  title: ElevatedButton(
                    onPressed: () {
                      isolateContactor2?.close();
                    },
                    child: Text('Terminate isolate 2'),
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
