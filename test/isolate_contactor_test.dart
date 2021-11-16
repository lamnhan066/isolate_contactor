import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_contactor/isolate_contactor.dart';

void main() {
  const MethodChannel channel = MethodChannel('isolate_contactor');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
