part of isolate_contactor;

class IsolateContactor {
  /// Delegate
  late _IsolateContactor _delegate;

  /// Create a temporary instance.
  IsolateContactor._();

  /// The easy way to create isolate function
  ///
  /// - [function] must be static or top-level function.
  /// - [debugMode] use for printing the status of the plugin,
  /// default is true in Debug and Profile modes.
  ///
  /// Example of [function]:
  /// ``` dart
  /// dynamic fibonacci(dynamic n) {
  ///   if (n == 0) return 0;
  ///   if (n == 1 || n == 2) return 1;
  ///
  ///   return fibonacci(n - 1) + fibonacci(n - 2);
  /// }
  /// ```
  static Future<IsolateContactor> create([
    void Function(dynamic)? function,
    bool debugMode = !kReleaseMode,
  ]) async {
    IsolateContactor _isolateContactor = IsolateContactor._();

    _isolateContactor._delegate = await _IsolateContactor.create(
        function: function, debugMode: debugMode);
    return _isolateContactor;
  }

  /// Create an instance with your own isolate function
  ///
  /// [isolateFunction] You can take a look at the example to see what you need to do
  /// to make it works.
  /// [isolateParams] is the list of parameters that you want to add to your [isolateFunction]
  ///
  /// This is form of the [isolateFunction]:
  /// ``` dart
  /// void isolateFunction(List<dynamic> params) {
  ///   final channel = IsolateChannel.connectSend(params.last);
  ///   channel.stream.listen((rawMessage) {
  ///     final message = IsolateContactor.getMessage(rawMessage);
  ///     if (message != null) {
  ///       // Do more stuff here, [message] is dynamic so you can pass any
  ///       // supported type
  ///
  ///       channel.sendResult(fibonacci(message));
  ///     }
  ///   });
  /// }
  /// ```
  static Future<IsolateContactor> createOwnIsolate(
    dynamic Function(List<dynamic>) isolateFunction, [
    List<dynamic>? isolateParams,
    bool debugMode = !kReleaseMode,
  ]) async {
    IsolateContactor _isolateContactor = IsolateContactor._();

    _isolateContactor._delegate = await _IsolateContactor.createOwnIsolate(
      isolateFunction: isolateFunction,
      isolateParams: isolateParams,
    );
    return _isolateContactor;
  }

  /// Send message to the [function] for computing
  void sendMessage(dynamic message) => _delegate.sendMessage(message);

  /// Listen to the result of the [function]
  Stream get onMessage => _delegate.onMessage;

  /// Listen to the current state of isolate.
  /// Includes [ComputeState.computed] and [ComputeState.computing]
  Stream<ComputeState> get onComputeState => _delegate.onComputeState;

  /// Get current computing state of the isolate
  bool get isConputing => _delegate.isComputing;

  /// Pause the isolate
  void pause() => _delegate.pause();

  /// Resume the isolate
  void resume() => _delegate.resume();

  /// Restart the paused isolate
  Future<void> restart() async => await _delegate.restart();

  /// Close current isolate, the same behavior with [dispose]
  void close() => _delegate.dispose();

  /// Close current isolate, the same behavior with [dispose]
  void terminate() => _delegate.dispose();

  /// Dispose current isolate
  void dispose() => _delegate.dispose();

  /// Use in isolate function
  static dynamic getMessage(dynamic rawMessage) =>
      _IsolateContactor.getMessage(_IsolatePort.child, rawMessage);
}
