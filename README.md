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

## This is a basic example of the package

``` dart
main() async {
    // Just for waiting until the results have arrived
    bool valueExit = false;

    // Create IsolateContactor instance
    IsolateContactor isolateContactor =
        await IsolateContactor.create(fibonacci);

    // Listen to the results
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

dynamic fibonacci(dynamic n) {
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
```

or

``` dart
Future<dynamic> function(dynamic param) async {
  // do something
  return something; // <-- This result will be sent back to your `onMessage` in main isolate.
}
```

The `param` can be anything even a `List` of variable like this (but its type must be `dynamic`):

``` dart
dynamic subtract(dynamic n) => n[1] - n[0];
```

And create the instance with `IsolateContactor.create(function)` or `IsolateContactor.create(subtract)`.

This is a test example:

``` dart
void main() {
  test('Create isolate with build-in function', () async {
    bool value1Exit = false;
    bool value2Exit = false;

    IsolateContactor isolateContactor1 = await IsolateContactor.create(fibonacci);
    IsolateContactor isolateContactor2 = await IsolateContactor.create(subtract);

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

    // Send 10 and 20 to [subtract]
    isolateContactor2.sendMessage([10, 20]);

    // Only for waiting the result in Console app. Don't need to use in your real app
    while (!value1Exit && !value2Exit) {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    isolateContactor1.dispose();
    isolateContactor2.dispose();
  });
}

// single parameter
dynamic fibonacci(dynamic n) {
  if (n == 0) return 0;
  if (n == 1 || n == 2) return 1;

  return fibonacci(n - 2) + fibonacci(n - 1);
}

// multi parameters as a dynamic
dynamic subtract(dynamic n) => n[1] - n[0];
```

## Create your own function

This is also not too complicated to use, you're completely control your isolate function with this method.
You just need to create a function of this form:

``` dart
void isolateFunction(dynamic params) {
  // Create IsolateContactor controller from params
  final channel = IsolateContactorController(params);

  // Listen to to the `message` sent from main process
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
  IsolateContactor isolateContactor = await IsolateContactor.createOwnIsolate(isolateFunction);

  // Listen to the results
  isolateContactor.onMessage.listen((event) {
    print('isolate 2: $event');

    expect(event, 30);
  });

  // Send 10 and 20 to [isolateFunction]
  isolateContactor.sendMessage([10, 20]);
}

// Create your own function here
void isolateFunction(dynamic params) {
  final channel = IsolateContactorController(params, onDispose: () {
    print('Disposing isolateFunction');
  });
  channel.onIsolateMessage.listen((message) {
    // Do your stuff here
    
    // Send value back to your main process in stream [onMessage]
    channel.sendResult(add(message[0], message[1]));
  });
}

// multi parameters as an dynamic
dynamic add(dynamic a, dynamic b) => a + b;
```

## Limitation

Support web platform with limited features. The package use `Future` to provide the same features to Isolate.

## Contributions

If you encounter any problems or feel the library is missing a feature, please feel free to open an issue. Pull request are also welcome.
