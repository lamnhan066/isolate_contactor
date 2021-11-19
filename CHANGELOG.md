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
