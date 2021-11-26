import 'dart:async';
import 'utils.dart';
import 'isolate_contactor_controller.dart';

class IsolateContactorControllerIpl implements IsolateContactorController {
  late StreamController _delegate;

  final StreamController _mainStreamController = StreamController.broadcast();
  final StreamController _isolateStreamController =
      StreamController.broadcast();

  IsolateContactorControllerIpl(dynamic params) {
    if (params is List) {
      _delegate = params.last.controller;
    } else {
      _delegate = params;
    }

    _delegate.stream.listen((event) {
      dynamic _message1 = getPortMessage(IsolatePort.main, event);
      if (_message1 != null) {
        _mainStreamController.add(_message1);
      }

      dynamic _message2 = getPortMessage(IsolatePort.isolate, event);
      if (_message2 != null) {
        _isolateStreamController.add(_message2);
      }
    });
  }

  @override
  StreamController get controller => _delegate;

  @override
  Stream get onMessage => _mainStreamController.stream;

  @override
  Stream get onIsolateMessage => _isolateStreamController.stream;

  @override
  void sendIsolate(dynamic message) {
    try {
      _delegate.sink.add({IsolatePort.isolate: message});
    } catch (_) {
      // The delegate may be closed
    }
  }

  @override
  void sendResult(dynamic message) {
    try {
      _delegate.sink.add({IsolatePort.main: message});
    } catch (_) {
      // The delegate may be closed
    }
  }

  @override
  void close() {
    _delegate.close();
    _mainStreamController.close();
    _isolateStreamController.close();
  }
}
