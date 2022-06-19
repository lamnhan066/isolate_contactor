# Isolate Contactor

An easy way to create a new isolate, keep it running and comunicate with it. It supports sending values between main and child isolate multiple times via `stream`, so you can build your `widget` with `StreamBuilder` and always listen to the new value from your `isolate`.

This package is different from the `compute` method, IsolateContactor allows the isolate to run, send, receive data from creating until you terminate it. It'll  save a lot of starting time.

## How to use it

There are multiple ways to use this package, the only thing to notice that the `function` have to be a `static` or `top-level` function to make it works.

### Create IsolateContactor instance

``` dart
IsolateContactor isolateContactor = await IsolateContactor.create(<function>);
```

### Listen to the result of the isolate

Like the above example, the result will be passed into `stream` listener, so you need to make sure that the `stream` has been called before sending message to the isolate for computing.

``` dart
isolateContactor.onMessage.listen((message) {
  print('Result from isolate: $message');
});
```

### Send data to isolate for computing

``` dart
isolateContactor.sendMessage(value);
```

## Basic example

``` dart
main() async {
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
}

int fibonacci(dynamic n) {
  if (n == 0) return 0;
  if (n == 1 || n == 2) return 1;

  return fibonacci(n - 2) + fibonacci(n - 1);
}
```

## Easy build-in function

I have implemented a build-in static function to make you easier to create an isolate as fast as possible.
You just need to create a function of this form:

``` dart
dynamic function(dynamic param) {
  // do something
  return something; // <-- This result will be sent back to your `onMessage` in main isolate.
}

// Or specify the return type. Ex:
int function(dynamic param) {
  // do something
  return something; // <-- This result will be sent back to your `onMessage` in main isolate.
}
```

or a `Future` function:

``` dart
Future<dynamic> function(dynamic param) async {
  // do something
  return something; // <-- This result will be sent back to your `onMessage` in main isolate.
}

// Or specify the return type. Ex:
Future<int> function(dynamic param) async {
  // do something
  return something; // <-- This result will be sent back to your `onMessage` in main isolate.
}
```

The `param` can be anything even a `List` of variable like this (but its type must be `dynamic`):

``` dart
dynamic subtract(dynamic n) => n[1] - n[0];

// Or specify the return type. Ex:
double subtract(dynamic n) => n[1] - n[0];
```

And create the instance with `IsolateContactor.create(function)` or `IsolateContactor.create(subtract)`.

This is a test example:

``` dart
void main() {
    bool value2Exit = false;

    IsolateContactor<double> isolateContactor2 =
        await IsolateContactor.create(subtract);

    // Listen to f20
    isolateContactor2.onMessage.listen((event) {
      print('isolate 2: $event');

      expect(event, 10.0);

      value2Exit = true;
    });

    // Send 20 and 10 to [subtract]
    isolateContactor2.sendMessage([10.0, 20.0]);

    // Only for waiting the result in Console app. Don't need to use in your real app
    while (!value1Exit && !value2Exit) {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    isolateContactor2.dispose();
}

// multi parameters as a dynamic
double subtract(dynamic n) => n[1] - n[0];
```

## Create your own function

This is also not too complicated to use, you're completely control your isolate function with this method.
You just need to create a function of this form:

``` dart
// Create your own function here
void isolateFunction(dynamic params) {
  final channel = IsolateContactorController<double>(params, onDispose: () {
    print('Dispose isolateFunction');
  });
  channel.onIsolateMessage.listen((message) {
    // Do your stuff here
    
    // Send value back to your main process in stream [onMessage]
    channel.sendResult(add(message[0], message[1]));
  });
}
```

And use `IsolateContactor.createOwnIsolate(isolateFunction)` and the package will do anything else for you. Please remember that you need to create exactly the same form of the function to make it works.
This is an example:

``` dart
main() async {
  IsolateContactor<double> isolateContactor = await IsolateContactor.createOwnIsolate(isolateFunction, debugMode: true);
  
  // Listen to the results
  isolateContactor.onMessage.listen((event) {
    print('isolate 2: $event');

    expect(event, 30.0);
  });

  // Send 10 and 20 to [isolateFunction]
  isolateContactor.sendMessage([10.0, 20.0]);
}

// Create your own function here
void isolateFunction(dynamic params) {
  final channel = IsolateContactorController<double>(params, onDispose: () {
    print('Dispose isolateFunction');
  });
  channel.onIsolateMessage.listen((message) {
    // Do your stuff here
    
    // Send value back to your main process in stream [onMessage]
    channel.sendResult(add(message[0], message[1]));
  });
}

// multi parameters as an dynamic
double add(dynamic a, dynamic b) => a + b;
```

## Flutter Example

Create an expensive to calculate function:

``` dart
/// This must be a static or top-level function
///
/// This function is very expensive to calculate, so I can test for un-blocking UI feature
Future<double> fibonacciRescusiveFuture(dynamic n) async {
  if (n == 0) return 0;
  if (n <= 2) return 1;

  // Magic code: This is only for non-blocking UI on Web platform
  await Future.delayed(Duration.zero);

  return await fibonacciRescusiveFuture(n - 1) +
      await fibonacciRescusiveFuture(n - 2);
}
```

Create IsolateContactor instance:

``` dart
IsolateContactor<double> isolateContactor3 = await IsolateContactor.create(fibonacciRescusiveFuture, debugMode: true);
```

Use `StreamBuilder` to rebuild the `Widget`:

``` dart
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Multi Isolate Fibonacci'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                
                /// Rebuild the widget when isolateContactor3 receives data
                StreamBuilder(
                  stream: isolateContactor3.onMessage,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      isolateContactor3.sendMessage(value3);
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return Text(
                        'Isolate3: Fibonacci at F$value3 = ${snapshot.data}');
                  },
                ),

                /// You can also listen to the state of this isolate
                StreamBuilder(
                    stream: isolateContactor3.onComputeState,
                    builder: (context, snapshot) {
                      return ListTile(
                        title: ElevatedButton(
                          onPressed: () => calculateValue3(),
                          child: Text(snapshot.data != null &&
                                  snapshot.data == ComputeState.computing
                              ? 'Computing F$value3..'
                              : 'Calculate new Fibonacci'),
                        ),
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
```

## Limitation

Support web platform with limited features. The package use `Future` to provide the same features to Isolate.

## Contributions

If you encounter any problems or feel the library is missing a feature, please feel free to open an issue. Pull request are also welcome.
