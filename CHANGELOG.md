## 4.2.0-rc.3

* **BREADKING CHANGE** Change from `jsSendMessage(IsolateState.initialized.serialization)` to `jsSendMessage(IsolateState.initialized.toJson())`. All the `rc`'s `Worker`s need to be recompiled.
  * Before:

    ```dart
    main() {
      callbackToStream('onmessage', (html.MessageEvent e) {
        return js_util.getProperty(e, 'data');
      }).listen((message) async {
        jsSendMessage(add(message));
      });

      jsSendMessage(IsolateState.initialized.serialization); // <--
    }    
    ```

  * After:

    ```dart
    main() async {
      // Do something sync or async here
      
      callbackToStream('onmessage', (html.MessageEvent e) {
        return js_util.getProperty(e, 'data');
      }).listen((message) async {
        jsSendMessage(add(message));
      });

      jsSendMessage(IsolateState.initialized.toJson()); // <--
    }
    ```

## 4.2.0-rc.2

* **[Experiment]** Able to send an `initialized` signal from the Isolate to the main app:
  * **Step 1:** Advanced method:

    * Before:

    ```dart
    final channel = IsolateContactorController<double, List<double>>(params);
    channel.onIsolateMessage.listen((message) {
      channel.sendResult(add(message));
    });
    ```

    * After:

    ```dart
    final channel = IsolateContactorController<double, List<double>>(params);
    channel.onIsolateMessage.listen((message) {
      channel.sendResult(add(message));
    });

    channel.initialized(); // <--
    ```

  * Worker on the Web:

    * Before:

    ```dart
    main() {
      callbackToStream('onmessage', (html.MessageEvent e) {
        return js_util.getProperty(e, 'data');
      }).listen((message) async {
        jsSendMessage(add(message));
      });
    }    
    ```

    * After:

    ```dart
    main() async {
      // Do something sync or async here
      
      callbackToStream('onmessage', (html.MessageEvent e) {
        return js_util.getProperty(e, 'data');
      }).listen((message) async {
        jsSendMessage(add(message));
      });

      jsSendMessage(IsolateState.initialized.serialization); // <--
    }
    ```

  * **Step 2:** Update the `create` and `createOwnIsolate` method:

    * Before:

    ```dart
    final isolate = await IsolateContactor.create(
      function, 
      workerName: 'function',
    );
    ```

    * After:

    ```dart
    final isolate = await IsolateContactor.create(
      function, 
      workerName: 'function',
      autoMarkAsInitialized: false, // <--
    );
    ```

## 4.2.0-rc.1

* **[Experiment]** Able to send an `initialized` signal from the Isolate to the main app:

  * Advanced method:

    * Before:

    ```dart
    final channel =
    IsolateContactorController<double, List<double>>(params, onDispose: () {
      print('Dispose isolateFunction');
    });
    channel.onIsolateMessage.listen((message) {
      // Do your stuff here

      // Send value back to your main process in stream [onMessage]
      channel.sendResult(add(message));
    });
    ```

    * After:

    ```dart
    final channel = IsolateContactorController<double, List<double>>(
      params, 
      // New parameter
      onInitial: () async {
        /* Accept both sync and async action here */
      },
      onDispose: () {
        print('Dispose isolateFunction');
      });

    await channel.intial(); // or `channel.initial()`

    channel.onIsolateMessage.listen((message) {
      // Do your stuff here

      // Send value back to your main process in stream [onMessage]
      channel.sendResult(add(message));
    });
    ```

  * Worker on the Web:

    * Before:

    ```dart
    main() {
      callbackToStream('onmessage', (html.MessageEvent e) {
        return js_util.getProperty(e, 'data');
      }).listen((message) async {
        // TODO: Function for computation here
        final result = add(message);

        jsSendMessage(result);
      });
    }    
    ```

    * After:

    ```dart
    main() async {
      // Do something sync or async here
      
      callbackToStream('onmessage', (html.MessageEvent e) {
        return js_util.getProperty(e, 'data');
      }).listen((message) async {
        // TODO: Function for computation here
        final result = add(message);

        jsSendMessage(result);
      });

      // Call this
      jsSendMessage(IsolateState.initialized.serialization);
    }
    ```

## 4.1.0

* Use `if (dart.library.io)` instead of `if (dart.library.html)` for more compatible.
* Deprecate the `createOwnIsolate` in favor of the `createCustom`.
* Add typedefs: `IsolateFunction`, `CustomIsolateFunction`, `IsolateConverter`.
* Remove `worker` folder.
* The `README` is cleared and isn't maintained anymore. Read in the [isolate_manager](https://pub.dev/packages/isolate_manager) instead.

## 4.0.1

* Better way to check valid IsolateException.
* Improve tests.

## 4.0.0

* Add `sendResultError` to `IsolateContactorController` to make it easier to send the Exception from the Isolate to main app.
* `IsolateException` parameters are now `Object` and `StackTrace`.
* Add parameter type as `P` and change return type to `R`.
* Add return type as `void` to `onDispose` method.
* Change `isolateParams` from dynamic to `Object?`.

## 3.0.0

* Bumped Dart sdk to `>=2.18.0 <4.0.0`.
* Update `error_function.js` name in test.

## 2.1.0

* Support `try-catch` block for all platforms including Worker on Web.
* Update `worker.dart` to support `try-catch` block.
* Increase min SDK to 2.15.0.

## 2.0.2+1

* Improve pub scores.

## 2.0.2

* On Flutter >3.3.0 - `@pragma('vm:entry-point')` anotation must be added to all methods that you want to use for isolation. Read README for more information.
* Add `@pragma('vm:entry-point')` to internal method.
* Use `stream_channel: ^2.1.0` to avoid conflicts with `flutter_test`.

## 2.0.1

* Update `worker.dart` script for the `Worker`.
* Update README.

## 2.0.0+1

* Improve function & parameter headers
* Update dependencies

## 2.0.0

* **NO BREAKING CHANGE**
* Add `Worker` for Web platform (real Isolate on Web). Read README for more details.

## 1.7.0

* **BREAKING CHANGE:** Change parameter name from `isolateParams` to `initialParams` for `createOwnIsolate`.
* Now you can get the `initialParams` when creating an own isolate:

``` dart
void isolateFunction(dynamic params) {
  var controller = IsolateContactorController(params, onDispose: () {});
  var initialParams = controller.initialParams;
  controller.onIsolateMessage.listen((message) {
    // Do your stuff here
  });
}
```

## 1.6.1

* Added `IsolateContactorException`, throw it when error occurs on `sendMessage` method.
* Return `Future` for `dispose` method.

## 1.6.0

* Now you can `await` for the result when using `isolateContactor.sendMessage`.
* Improved README and Test.

## 1.5.1+1

* Improved result parser.
* Improved README for allowed return type version, Improved Test and Example.

## 1.5.0+1

* Now you can add return type for the stream listener. Example:

``` dart
// `fibonacci` have `int` return type
IsolateContactor<int> isolateContactor = await IsolateContactor.create(fibonacci);

// `intEvent` will be `int` type
isolateContactorFuture.onMessage.listen((intEvent) {
  // intEvent
});

// `fibonacci` have `int` return type
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
```

* Add `onDispose` parameter to `IsolateContactorController`, this parameter allows you to add your own dispose method inside `isolateFunction` for `.createOwnIsolate`.

## 1.4.0

* Fixed issue in `internalIsolateFunction` makes this function run twice.

## 1.3.0

* Updated dependencies.
* Improved function headers.

## 1.2.1

* Update dependencies
* Update homepage
* Cleanup

## 1.2.0+2

* Update homepage

## 1.2.0+1

* Update README

## 1.2.0

* Fixed issue with the `restart` method.
* Cleanup and reformat internal code.
* **BREAKING CHANGE:**  
  * Temporarily removed the `pause` and `resume` methods.
  * The `debugMode` in the `create()` and `createOwnIsolate()` methods was refactored to **named optional parameters**.

## 1.1.0+1

* Remove flutter dependencies to support dart native
* Add a better description

## 1.0.0

* Support web platform with limited features. The package use `Future` to provide the same features to `Isolate` but it doesn't have `pause`, `resume`, `restart` methods. I'll try to bring the same action with `Isolate` as much as possible.
* Support `Future` when creating build-in method. More information please read Readme.
* **BREAKING CHANGE**:
  * Create your own isolate:

    Before:

    ``` dart
    void isolateFunction(List<dynamic> params) {
      final channel = IsolateChannel.connectSend(params.last);
      channel.stream.listen((rawMessage) {
        final message = IsolateContactor.getMessage(rawMessage);
        if (message != null) {
          // Do more stuff here

          // Send the result to your [onMessage] stream
          channel.sendResult(add(message[0], message[1]));
        }
    }
    ```

    Now:

    ``` dart
    void isolateFunction(dynamic params) {
      final channel = IsolateContactorController(params);
      channel.onIsolateMessage.listen((message) {
        // Do more stuff here

        // Send the result to your [onMessage] stream
        channel.sendResult(add(message[0], message[1]));
      });
    }
    ```

## 0.0.1+2

* Update flutter version

## 0.0.1+1

* Update description

## 0.0.1

* Initial release
