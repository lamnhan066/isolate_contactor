part of isolate_contactor;

class IsolateContactor {
  /// Deledate
  late _IsolateContactor _delegate;

  /// Create a temporary instance.
  IsolateContactor._();

  /// Create instance for the plugin
  ///
  /// [function] must be static or top-level function
  /// [debugMode] use for printing the status of the plugin
  ///
  /// Example:
  /// ``` dart
  ///
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

  /// Send message to the [function] for computing
  void sendMessage(dynamic message) => _delegate.sendMessage(message);

  /// Listen to the result of the [function]
  Stream get onMessage => _delegate.onMessage;

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
