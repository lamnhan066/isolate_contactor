import 'dart:async';

import 'package:stream_channel/isolate_channel.dart';

import '../isolate_contactor_controller.dart';
import '../utils/utils.dart';

class IsolateContactorControllerIpl implements IsolateContactorController {
  late IsolateChannel _delegate;
  late StreamSubscription _delegateSubscription;

  final StreamController _mainStreamController = StreamController.broadcast();
  final StreamController _isolateStreamController =
      StreamController.broadcast();

  IsolateContactorControllerIpl(dynamic params) {
    if (params is List) {
      _delegate = IsolateChannel.connectSend(params.last);
    } else {
      _delegate = IsolateChannel.connectReceive(params);
    }

    _delegateSubscription = _delegate.stream.listen((event) {
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

  /// Only need for web platform
  @override
  IsolateChannel get controller => _delegate;

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
    _delegateSubscription.cancel();
    _mainStreamController.close();
    _isolateStreamController.close();
  }
}
