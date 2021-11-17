part of isolate_contactor;

class IsolateContactor {
  /// Deledate
  late _IsolateContactor _delegate;

  /// Create a temporary instance.
  IsolateContactor._();

  /// Create instance for the plugin
  ///
  /// [function] must be static or top-level function.
  /// [debugMode] use for printing the status of the plugin. Default is true in Debug and Profile modes.
  ///
  /// Example:
  /// ``` dart
  /// void main() {
  ///     bool value1Exit = false;
  ///     bool value2Exit = false;
  ///
  ///     IsolateContactor isolateContactor1 =
  ///         await IsolateContactor.create(fibonacci);
  ///     IsolateContactor isolateContactor2 =
  ///         await IsolateContactor.create(fibonacci);
  ///
  ///     // Listen to f10
  ///     isolateContactor1.onMessage.listen((event) {
  ///       expect(event, 55);
  ///
  ///       value1Exit = true;
  ///     });
  ///
  ///     // Listen to f20
  ///     isolateContactor2.onMessage.listen((event) {
  ///       expect(event, 6765);
  ///
  ///       value2Exit = true;
  ///     });
  ///
  ///     isolateContactor1.sendMessage(10);
  ///     isolateContactor2.sendMessage(20);
  ///
  ///     while (!value1Exit && !value2Exit) {
  ///       await Future.delayed(const Duration(milliseconds: 10));
  ///     }
  ///
  ///     isolateContactor1.dispose();
  ///     isolateContactor2.dispose();
  /// }
  ///
  /// dynamic fibonacci(dynamic n) {
  ///   if (n == 0) return 0;
  ///   if (n == 1 || n == 2) return 1;
  ///
  ///   return fibonacci(n - 2) + fibonacci(n - 1);
  /// }
  /// ```
  static Future<IsolateContactor> create(
      [Function(dynamic)? function, bool debugMode = true]) async {
    IsolateContactor _isolateContactor = IsolateContactor._();

    _isolateContactor._delegate = await _IsolateContactor.create(
        function: function, debugMode: debugMode);
    return _isolateContactor;
  }

  /// Add a static or top-level function to current isolate contactor.
  ///
  /// You can reuse current isolate contactor for a new function,
  /// it will create new isolate for the new function without changing
  /// current [IsolateContactor]
  void addFunction(dynamic Function(dynamic) function) =>
      _delegate.addFunction(function);

  /// Send message to the [_function] for computing
  void sendMessage(dynamic message) => _delegate.sendMessage(message);

  /// Listen to the result of the [_function]
  Stream get onMessage => _delegate.onMessage;

  /// Listen to the current state
  Stream get onComputeState => _delegate.onComputeState;

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
}
