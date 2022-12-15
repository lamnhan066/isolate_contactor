# Isolate Contactor

* This package is different from the `compute` method, IsolateContactor allows the isolate to run, send, receive data until you terminate it. It'll  save a lot of starting time.

* If you want to manage multiple Isolates for a function at the same time, you can use `isolate_manager`: [pub](https://pub.dev/packages/isolate_manager) | [git](https://github.com/vursin/isolate_manager) which is based on this package with advanced features.

## Features

* Easy to create a new Isolate, keep it active, and communicate with it.
* Supports Web with `Future` and `Worker` (`Worker` is the real Isolate on the Web). Automatically switch to `Future` if the current Web browser doesn't support `Worker`.
* Supports sending and receiving values between the main and child Isolate multiple times via stream, so you can build your widget with StreamBuilder and always listen to the new value from your Isolate.

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

## Worker Configuration

* **Step 1:** Download [isolate_contactor/worker/worker.dart](https://raw.githubusercontent.com/vursin/isolate_contactor/main/worker/worker.dart) or copy the below code to the file named `worker.dart`:

  <details>
  
  <summary>worker.dart</summary>

  ``` dart
  // ignore_for_file: avoid_web_libraries_in_flutter, depend_on_referenced_packages

  import 'dart:async';
  import 'dart:convert';
  import 'dart:html' as html;
  import 'dart:js' as js;

  import 'package:js/js.dart' as pjs;
  import 'package:js/js_util.dart' as js_util;

  @pjs.JS('self')
  external dynamic get globalScopeSelf;

  /// dart compile js worker.dart -o worker.js -O4

  /// In most cases you don't need to modify this function
  main() {
    callbackToStream('onmessage', (html.MessageEvent e) {
      return js_util.getProperty(e, 'data');
    }).listen((message) async {
      final Completer completer = Completer();
      completer.future.then((value) => jsSendMessage(value));
      completer.complete(worker(message));
    });
  }

  /// TODO: Modify your function here
  FutureOr<dynamic> worker(dynamic message) {
    // Best way to use this method is encoding the result to JSON
    // before sending to the main app, then you can decode it back to
    // the return type you want with `workerConverter`.
    return jsonEncode(message);
  }

  /// Internal function
  Stream<T> callbackToStream<J, T>(
      String name, T Function(J jsValue) unwrapValue) {
    var controller = StreamController<T>.broadcast(sync: true);
    js_util.setProperty(js.context['self'], name, js.allowInterop((J event) {
      controller.add(unwrapValue(event));
    }));
    return controller.stream;
  }

  /// Internal function
  void jsSendMessage(dynamic m) {
    js.context.callMethod('postMessage', [m]);
  }
  ```

  </details>

* **Step 2:** Modify the function `FutureOr<dynamic> worker(dynamic message)` in the script to serves your purposes. You can also use the `top-level or static function` that you have created above.

 **You should copy that function to separated file or copy to `worker.dart` file to prevent the `dart compile js` error because some other functions depend on Flutter library.**

* **Step 3:** Run `dart compile js worker.dart -o worker.js -O4` to compile dart to js (-O0 to -O4 is the obfuscated level of `js`).
* **Step 4:** Copy `worker.js` to web folder (the same folder with `index.html`).
* **Step 5:** Now you can add `worker` to `workerName` like below:

  ``` dart
  final isolateContactor = await IsolateContactor.create(
      add,
      workerName: 'worker', // Don't need to add the extension
    );
  ```

  Now the plugin will handle all other action to make the real isolate works on Web.

## Additional

* If the `worker.dart` show errors for `js` package, you can add `js` to `dev_dependencies`:
  
  ``` dart
  dev_dependencies:
    js:
  ```

* The result that you get from the Isolate (or Worker) is sometimes different from the result that you want to get from the return type in the main app, you can use `converter` and `workerConverter` parameters to convert the result received from the `Isolate` (converter) and `Worker` (workerConverter). Example:

  ``` dart
  IsolateContactor<Map<int, double>> isolateContactor =
      await IsolateContactor.create(
    convertToMap,
    // Ex: 'map_result' if the name is 'map_result.js'
    workerName: 'worker',
    // Convert the data from worker to fix the issue related to the different data type between dart and js
    workerConverter: (result) {
      final Map<int, double> convert = {};

      // Convert Map<String, String> (received from Worker) to Map<int, double>
      final decodedMap = jsonDecode(result) as Map;
      decodedMap.forEach((key, value) => convert.addAll({int.parse(key): double.parse(value)}));

      return convert;
  );
  ```

## Contributions

If you encounter any problems or feel the library is missing a feature, feel free to open an issue. PRs are also welcome.
