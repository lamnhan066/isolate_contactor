import 'dart:async';

import 'package:stream_channel/isolate_channel.dart';

import '../isolate_contactor_controller.dart';
import '../utils/utils.dart';

class IsolateContactorControllerIpl<T>
    implements IsolateContactorController<T> {
  late IsolateChannel _delegate;
  late StreamSubscription _delegateSubscription;

  final StreamController<T> _mainStreamController =
      StreamController.broadcast();
  final StreamController _isolateStreamController =
      StreamController.broadcast();
  final Function()? onDispose;

  IsolateContactorControllerIpl(dynamic params, {this.onDispose}) {
    if (params is List) {
      _delegate = IsolateChannel<T>.connectSend(params.last);
    } else {
      _delegate = IsolateChannel<T>.connectReceive(params);
    }

    _delegateSubscription = _delegate.stream.listen((event) {
      T message1 = getPortMessage(IsolatePort.main, event);
      if (message1 != null) {
        _mainStreamController.add(message1);
      }

      dynamic message2 = getPortMessage(IsolatePort.isolate, event);
      if (message2 != null) {
        if (message2 == IsolateState.dispose) {
          if (onDispose != null) onDispose!();
          close();
        } else {
          _isolateStreamController.add(message2);
        }
      }
    });
  }

  /// Only need for web platform
  @override
  IsolateChannel get controller => _delegate;

  @override
  Stream<T> get onMessage => _mainStreamController.stream;

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
  void sendResult(T message) {
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
