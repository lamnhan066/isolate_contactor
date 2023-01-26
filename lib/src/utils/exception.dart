import 'dart:convert';

class IsolateException implements Exception {
  final dynamic error;
  final dynamic stack;

  IsolateException(this.error, this.stack);

  String toJson() => jsonEncode({
        r'$IsolateException': {
          'error': error.toString(),
          'stack': stack.toString(),
        }
      });

  factory IsolateException.fromJson(dynamic json) {
    assert(isValidObject(json),
        'json should be checked by `isValidObject` before using');

    final decoded = jsonDecode(json.toString());
    final values = decoded[r'$IsolateException'];

    return IsolateException(values['error'], values['stack']);
  }

  static isValidObject(dynamic json) =>
      json.toString().startsWith(r'{"$IsolateException":{') &&
      json.toString().endsWith('"}}');

  @override
  int get hashCode => error.hashCode ^ stack.hashCode;
}
