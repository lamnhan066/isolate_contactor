import 'dart:async';
import 'enum.dart';
import 'isolate_contactor.dart';

class IsolateContactorController {
  late StreamController _delegate;

  final StreamController _mainStreamController = StreamController.broadcast();
  final StreamController _messageStreamController =
      StreamController.broadcast();

  IsolateContactorController(dynamic params) {
    print('params.runtimeType = ${params.runtimeType}');
    if (params is List) {
      _delegate = params.last.controller;
    } else {
      _delegate = params;
    }

    _delegate.stream.listen((event) {
      print(event);
      dynamic message = IsolateContactor.getRawMessage(IsolatePort.main, event);
      if (message != null) {
        _mainStreamController.add(message);
      }

      message = IsolateContactor.getRawMessage(IsolatePort.child, event);
      if (message != null) {
        _messageStreamController.add(message);
      }
    });
  }

  StreamController get controller => _delegate;

  Stream get onMainMessage => _mainStreamController.stream;

  Stream get onMessage => _messageStreamController.stream;

  void sendIsolate(dynamic message) {
    _delegate.sink.add(<IsolatePort, dynamic>{IsolatePort.child: message});
  }

  void sendResult(dynamic message) {
    _delegate.sink.add(<IsolatePort, dynamic>{IsolatePort.main: message});
  }
}
