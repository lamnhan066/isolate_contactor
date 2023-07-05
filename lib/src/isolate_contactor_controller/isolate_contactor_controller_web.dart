import 'dart:html';

import '../isolate_contactor_controller.dart';
import 'web_platform/isolate_contactor_controller_web.dart';
import 'web_platform/isolate_contactor_controller_web_worker.dart';

abstract class IsolateContactorControllerImpl<R, P>
    implements IsolateContactorController<R, P> {
  factory IsolateContactorControllerImpl(
    dynamic params, {
    Function()? onDispose,
    R Function(dynamic)? converter, // Converter for native
    R Function(dynamic)? workerConverter, // Converter for Worker (Web Only)
  }) {
    if (params is Worker ||
        (params is List && params.last.controller is Worker)) {
      return IsolateContactorControllerImplWorker(
        params,
        onDispose: onDispose,
        converter: converter ?? (value) => value as R,
        workerConverter: workerConverter ?? (value) => value as R,
      );
    }

    return IsolateContactorControllerImplFuture(
      params,
      onDispose: onDispose,
      converter: converter ?? (value) => value as R,
      workerConverter: workerConverter ?? (value) => value as R,
    );
  }
}
