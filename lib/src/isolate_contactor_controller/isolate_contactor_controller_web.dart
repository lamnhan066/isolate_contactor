import 'dart:async';

import '../isolate_contactor_controller.dart';
import '../utils/utils.dart';

class IsolateContactorControllerIpl<T>
    implements IsolateContactorController<T> {
  late StreamController _delegate;

  final StreamController<T> _mainStreamController =
      StreamController.broadcast();
  final StreamController _isolateStreamController =
      StreamController.broadcast();
  final StreamController<bool> _isolateOnDisposeStreamController =
      StreamController.broadcast();

  IsolateContactorControllerIpl(dynamic params) {
    if (params is List) {
      _delegate = params.last.controller;
    } else {
      _delegate = params;
    }

    _delegate.stream.listen((event) {
      dynamic message1 = getPortMessage(IsolatePort.main, event);
      if (message1 != null) {
        _mainStreamController.add(message1);
      }

      dynamic message2 = getPortMessage(IsolatePort.isolate, event);
      if (message2 != null) {
        _isolateStreamController.add(message2);
      }
    });
  }

  @override
  StreamController get controller => _delegate;

  @override
  Stream<T> get onMessage => _mainStreamController.stream;

  @override
  Stream get onIsolateMessage => _isolateStreamController.stream;

  @override
  Stream<bool> get onDispose => _isolateOnDisposeStreamController.stream;

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
    _isolateOnDisposeStreamController.add(true);
    _delegate.close();
    _mainStreamController.close();
    _isolateStreamController.close();
  }
}
