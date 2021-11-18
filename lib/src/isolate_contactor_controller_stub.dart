import 'dart:async';

import 'package:stream_channel/isolate_channel.dart';
import 'utils.dart';
import 'isolate_contactor_controller.dart';

class IsolateContactorControllerIpl implements IsolateContactorController {
  late IsolateChannel _delegate;
  late StreamSubscription _delegateSubscription;

  final StreamController _mainStreamController = StreamController.broadcast();
  final StreamController _messageStreamController =
      StreamController.broadcast();

  IsolateContactorControllerIpl(dynamic params) {
    if (params is List) {
      _delegate = IsolateChannel.connectSend(params.last);
    } else {
      _delegate = IsolateChannel.connectReceive(params);
    }

    _delegateSubscription = _delegate.stream.listen((event) {
      dynamic message = getIsolatePortMessage(IsolatePort.main, event);
      if (message != null) {
        _mainStreamController.add(message);
      }

      message = getIsolatePortMessage(IsolatePort.child, event);
      if (message != null) {
        _messageStreamController.add(message);
      }
    });
  }

  /// Only need for web platform
  @override
  StreamController get controller => throw UnimplementedError();

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

  @override
  void close() {
    _delegateSubscription.cancel();
    _mainStreamController.close();
    _messageStreamController.close();
  }
}
