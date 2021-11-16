part of isolate_contactor;

class IsolateContactor {
  /// Deledate
  late _IsolateContactor _delegate;

  /// Create instance for the plugin
  ///
  /// [function] must be static or top-level function
  /// [debugMode] use for printing the status of the plugin
  IsolateContactor(Function(dynamic) function, {bool debugMode = true}) {
    _delegate = _IsolateContactor(function, debugMode: debugMode);
  }

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
