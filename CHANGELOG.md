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
