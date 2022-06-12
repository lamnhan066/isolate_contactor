## 1.5.1

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
