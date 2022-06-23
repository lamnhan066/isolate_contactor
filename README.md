# Isolate Contactor

An easy way to create a new isolate, keep it running and comunicate with it. It supports sending and receiving values between main and child isolate multiple times via `stream`, so you can build your `widget` with `StreamBuilder` and always listen to the new value from your `isolate`.

This package is different from the `compute` method, IsolateContactor allows the isolate to run, send, receive data until you terminate it. It'll  save a lot of starting time.

## Basic Usage (with build-in function)

There are multiple ways to use this package, the only thing to notice that the `function` have to be a `static` or `top-level` function to make it works.

### Create a top-level or static function

``` dart
double add(dynamic value) => value[0] + value[1];
```

### Create IsolateContactor instance for that function

``` dart
IsolateContactor<double> isolateContactor = await IsolateContactor.create(add);
```

### Listen to the result of the isolate

The result will be passed into `stream` listener, so you need to make sure that the `stream` has been called before sending message to the isolate for computing.

In Dart native:

``` dart
isolateContactor.onMessage.listen((message) {
  print('Result of the `add` function: $message');
});
```

In Flutter:

``` dart
StreamBuilder(
  stream: isolateContactor.onMessage,
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Text(
        'Result of the `add` function: ${snapshot.data}');
  },
),
```

### Send data to isolate for computing

``` dart
isolateContactor.sendMessage([10.0, 20.0]);
```

### You can also `await` for the result

``` dart
final result = await isolateContactor.sendMessage([10.0, 20.0]);
```

## Create your own isolate function

This is also not too complicated to use, you're completely control your isolate function with this method.
You just need to create a function of this form:

``` dart
// Create your own function here
void isolateFunction(dynamic params) {
  // Initial the controller for child isolate
  final controller = IsolateContactorController<double>(
    params, 
    onDispose: () {
      print('Dispose isolateFunction');
    }
  );

  // Get your initialParams.
  // Notice that this `initialParams` different from the `params` above.
  final initialParams = controller.initialParams;
  print(initialParams);

  // Listen to the message receiving from main isolate
  controller.onIsolateMessage.listen((message) {
    // Do your stuff here
    final result = add(message[0], message[1]);
    
    // Send value back to your main process in stream [onMessage]
    controller.sendResult(result);
  });
}
```

### Then create IsolateContactor for that function

``` dart
IsolateContactor<double> isolateContactor =  await IsolateContactor.createOwnIsolate(
      isolateFunction,
      initialParams: 'This is initialParams',
      debugMode: true,
    );
```

### Then you can use `isolateContactor` like above example

## Limitation

Support web platform with limited features. The package use `Future` to provide the same features to Isolate.

## Contributions

If you encounter any problems or feel the library is missing a feature, please feel free to open an issue. Pull request are also welcome.

## To-do list

- [x] Await for the result from isolate when using `isolateContactor.sendMessage`.
- [x] Allow creating multiple child isolates at the same time to solve multiple inputs sent from main isolate. Move this feature to `isolate_manager`: [pub](https://pub.dev/packages/isolate_manager) | [git](https://github.com/vursin/isolate_manager)
- [ ] Add real isolate for web platform with service-worker.js.
