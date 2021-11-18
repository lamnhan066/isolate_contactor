enum IsolatePort { main, child, debug }
enum ComputeState { computing, computed }

/// Get data with port
dynamic getRawMessage(IsolatePort toPort, dynamic rawMessage) {
  try {
    return rawMessage[toPort];
  } catch (_) {}
  return null;
}
