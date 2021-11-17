part of isolate_contactor;

extension Send on IsolateChannel {
  void sendIsolate(dynamic message) {
    sink.add(<_IsolatePort, dynamic>{_IsolatePort.child: message});
  }

  void sendResult(dynamic message) {
    sink.add(<_IsolatePort, dynamic>{_IsolatePort.main: message});
  }

  void sendDebug(dynamic message) {
    sink.add(<_IsolatePort, dynamic>{_IsolatePort.debug: message});
  }
}
