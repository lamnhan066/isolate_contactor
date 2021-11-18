import 'dart:async';
import 'utils.dart';
import 'isolate_contactor_controller.dart';

class IsolateContactorControllerIpl implements IsolateContactorController {
  late StreamController _delegate;

  final StreamController _mainStreamController = StreamController.broadcast();
  final StreamController _messageStreamController =
      StreamController.broadcast();

  IsolateContactorControllerIpl(dynamic params) {
    if (params is List) {
      _delegate = params.last.controller;
    } else {
      _delegate = params;
    }

    _delegate.stream.listen((event) {
      dynamic message1 = getIsolatePortMessage(IsolatePort.main, event);
      if (message1 != null) {
        _mainStreamController.add(message1);
      }

      dynamic message2 = getIsolatePortMessage(IsolatePort.child, event);
      if (message2 != null) {
        _messageStreamController.add(message2);
      }
    });
  }

  @override
  StreamController get controller => _delegate;

  @override
  Stream get onMessage => _mainStreamController.stream;

  @override
  Stream get onIsolateMessage => _messageStreamController.stream;

  @override
  void sendIsolate(dynamic message) {
    _delegate.sink.add(<IsolatePort, dynamic>{IsolatePort.child: message});
  }

  @override
  void sendResult(dynamic message) {
    _delegate.sink.add(<IsolatePort, dynamic>{IsolatePort.main: message});
  }
}
