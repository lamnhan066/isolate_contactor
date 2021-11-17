part of isolate_contactor;

class _IsolateContactor {
  bool _debugMode = !kReleaseMode;
  bool _isComputing = false;
  late ReceivePort _receivePort;
  late IsolateChannel _isolateChannel;
  Isolate? _isolate;
  Capability? _pauseCapability;
  final StreamController _mainStreamController = StreamController.broadcast();
  StreamSubscription<dynamic>? _mainStream;
  final StreamController<ComputeState> _computeStreamController =
      StreamController.broadcast();
  dynamic Function(dynamic)? _function;

  _IsolateContactor._create(
      {dynamic Function(dynamic)? function, bool debugMode = true}) {
    _function = function;
    _debugMode = debugMode;
  }

  /// Create an instance
  static Future<_IsolateContactor> create(
      {dynamic Function(dynamic)? function, bool debugMode = true}) async {
    _IsolateContactor _isolateContactor =
        _IsolateContactor._create(function: function, debugMode: debugMode);
    await _isolateContactor._initial();

    return _isolateContactor;
  }

  /// Initialize
  Future<void> _initial() async {
    _receivePort = ReceivePort();
    _isolateChannel = IsolateChannel.connectReceive(_receivePort);
    _mainStream = _isolateChannel.stream.listen((event) {
      final message = _get(_IsolatePort.main, event);
      if (message != null) {
        _printDebug('Message received from isolate: $message');

        _mainStreamController.add(message);
        _isComputing = false;
        _computeStreamController.add(ComputeState.computed);
      }
    });

    _isolate =
        await Isolate.spawn(_childFunction, [_receivePort.sendPort, _function]);

    _printDebug('Initialized');
  }

  /// Get current message as stream
  Stream get onMessage => _mainStreamController.stream;

  /// Get current state
  Stream<ComputeState> get onComputeState => _computeStreamController.stream;

  /// Is current isolate computing
  bool get isComputing => _isComputing;

  /// Add function to current [IsolateContactor]
  Future<void> addFunction(dynamic Function(dynamic) function) async {
    _function = function;
    await restart();
  }

  /// Pause current [Isolate]
  void pause() {
    if (_pauseCapability == null && _isolate != null) {
      _isolate!.pause(_pauseCapability);
      _printDebug('Paused');
    } else {
      _printDebug('Pause Error');
    }
  }

  /// Resume current [Isolate]
  void resume() {
    if (_pauseCapability != null && _isolate != null) {
      _isolate!.resume(_pauseCapability!);
      _pauseCapability = null;
      _printDebug('Resumed');
    } else {
      _printDebug('Resume Error');
    }
  }

  /// Restart current [Isolate]
  Future<void> restart() async {
    if (_isolate != null) {
      _isolate!.kill(priority: Isolate.immediate);
      _isolate = await Isolate.spawn(
          _childFunction, [_receivePort.sendPort, _function]);
      _printDebug('Restarted');
    } else {
      _printDebug('Restart Error');
    }
    _isComputing = false;
    _computeStreamController.add(ComputeState.computed);
  }

  /// Dispose current [Isolate]
  void dispose() {
    _mainStream?.cancel();
    _receivePort.close();
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _isComputing = false;
    _computeStreamController.add(ComputeState.computed);
    _printDebug('Disposed');
  }

  /// Create a static function to compunicate with main [Isolate]
  static void _childFunction(List<dynamic> sendPort) {
    final channel = IsolateChannel.connectSend(sendPort[0]);
    channel.stream.listen((event) {
      final message = _get(_IsolatePort.child, event);
      if (message != null) {
        if (sendPort[1] != null) channel.sendMain(sendPort[1](message));
      }
    });
  }

  /// Send message to child isolate [_function]
  void sendMessage(dynamic message) {
    if (_isolate == null) {
      _printDebug('! This isolate has been terminated');
      return;
    }

    if (_isComputing) {
      _printDebug(
          '! This isolate is still computing, so the current request may be revoked!');
    }

    _printDebug('Message send to isolate: $message');
    _isComputing = true;
    _computeStreamController.add(ComputeState.computing);
    _isolateChannel.sendChild(message);
  }

  /// Get data with port
  static dynamic _get(_IsolatePort toPort, dynamic rawMessage) {
    try {
      return rawMessage[toPort];
    } catch (_) {}
    return null;
  }

  /// Print if [debugMode] is true
  void _printDebug(Object? object) {
    // ignore: avoid_print
    if (_debugMode) print('[Isolate Contactor]: $object');
  }
}
