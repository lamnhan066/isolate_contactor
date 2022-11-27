# Isolate Contactor

* This package is different from the `compute` method, IsolateContactor allows the isolate to run, send, receive data until you terminate it. It'll  save a lot of starting time.

* This package will be moved to `isolate_manager`: [pub](https://pub.dev/packages/isolate_manager) | [git](https://github.com/vursin/isolate_manager) in the future.

## Features

* Easy to create a new isolate, keep it active and comunicate with it. You can use `isolate_manager`: [pub](https://pub.dev/packages/isolate_manager) | [git](https://github.com/vursin/isolate_manager) to create multiple isolate for a function at the same time which using this plugin as its core.
* Supports Web with `Future` and `Worker` (`Worker` is the real Isolate on Web). Automatically switch to `Future` if current Web browser doesn't support `Worker`.
* Supports sending and receiving values between main and child isolate multiple times via stream, so you can build your widget with StreamBuilder and always listen to the new value from your isolate.

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

## Configuration for Worker (Real Isolate on Web)

* **Step 1:** Download [isolate_contactor/worker/function_name.dart](https://raw.githubusercontent.com/vursin/isolate_contactor/main/worker/function_name.dart) and rename it to the `<function_name>.dart` that you want to create isolate.
* **Step 2:** Modify the function `dynamic functionName(dynamic message)` in the script to serves your purposes. Then rename it to the same as the above `<function_name>` (Just helping you easier to remember for later use). You can also use the `top-level or static function` that you have created above.

  ***You should copy that function to separated file or copy to `<function_name>.dart` file to prevent the `dart compile js` error because some other functions depend on flutter library.***

* **Step 3:** Run `dart compile js <function_name>.dart -o <function_name>.js -O4` to compile dart to js (-O0 to -O4 is the obfuscated level).
* **Step 4:** Copy `<function_name>.js` to web folder (the same folder with `index.html`).
* **Step 5:** Now you can add parameter `workerName` to your code like below:

  ``` dart
  IsolateContactor<double> isolateContactor = await IsolateContactor.create(
      add,
      workerName: 'add', // add.js
    );
  ```

  Now the plugin will handle all other action to make the real isolate works on Web.

## Additional

* If the `function_name.dart` show errors for `js` package, you can add `js` to `dev_dependencies`:
  
  ``` dart
  dev_dependencies:
    js:
  ```

* `IsolateContactor.create` and `createOwnIsolate` include `converter` and `workerConverter` parameters which helping you to convert the result received from the `Isolate` (converter) and `Worker` (workerConverter) and send it to the result. Example:

  ``` dart
  IsolateContactor<Map<int, double>> isolateContactor =
      await IsolateContactor.create(
    convertToMap,
    workerName: 'map_result',
    workerConverter: (result) {
      final Map<int, double> convert = {};

      // Convert Map<String, String> (received from Worker) to Map<int, double>
      (jsonDecode(result) as Map).forEach((key, value) => {
            convert.addAll({int.parse(key): double.parse(value)})
          });

      return convert;
    },
  );
  ```

## Contributions

If you encounter any problems or feel the library is missing a feature, feel free to open an issue. Pull request are also welcome.
