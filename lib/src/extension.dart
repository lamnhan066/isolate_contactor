part of isolate_contactor;

extension Send on IsolateChannel {
  void sendChild(dynamic message) {
    sink.add(<_IsolatePort, dynamic>{_IsolatePort.child: message});
  }

  void sendMain(dynamic message) {
    sink.add(<_IsolatePort, dynamic>{_IsolatePort.main: message});
  }

  void sendDebug(dynamic message) {
    sink.add(<_IsolatePort, dynamic>{_IsolatePort.debug: message});
  }
}
