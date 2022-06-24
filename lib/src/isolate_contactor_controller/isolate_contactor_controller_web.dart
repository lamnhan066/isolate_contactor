import 'dart:html';

import '../isolate_contactor_controller.dart';
import 'web_platform/isolate_contactor_controller_web.dart';
import 'web_platform/isolate_contactor_controller_web_worker.dart';

abstract class IsolateContactorControllerImpl<T>
    implements IsolateContactorController<T> {
  factory IsolateContactorControllerImpl(dynamic params,
      {Function()? onDispose, T Function(dynamic)? converter}) {
    if (params is Worker ||
        (params is List && params.last.controller is Worker)) {
      return IsolateContactorControllerImplWorker(params,
          onDispose: onDispose, converter: converter ?? (value) => value as T);
    }

    return IsolateContactorControllerImplFuture(params,
        onDispose: onDispose, converter: converter ?? (value) => value as T);
  }
}
