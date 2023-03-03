import 'dart:async';
import 'dart:isolate';

typedef ServiceWorkerInit<M> = ServiceWorker<M> Function(SendPort sendPort);


/// Helper class to spawn a custom [ServiceWorker] and communicate with it.
///
/// ```
/// final controller = await ServiceWorkerController.spawn(YourCustomWorker.new);
/// controller.send(...);
///
/// class YourCustomWorker extends ServiceWorker {
///   YourCustomWorker(super.sendPort);
///
///   Future<dynamic> messageHandler(message) {
///     ...
///   }
/// }
/// ```
///
/// `M` specifies the type of messages that will be send to the created service worker.
/// If omitted this will be `dynamic`.

class ServiceWorkerController<M> {
  final SendPort _sendPort;

  ServiceWorkerController._(this._sendPort);

  static Future<ServiceWorkerController<M>> spawn<M>(ServiceWorkerInit<M> main) async {
    final receivePort = ReceivePort();
    // create ServiceWorker in isolate
    // since this listens to a stream the isolate will be kept alive until the stream closes
    await Isolate.spawn(main, receivePort.sendPort);
    final sendPort = await receivePort.first;
    return ServiceWorkerController<M>._(sendPort);
  }

  /// Sends a message to the isolate with its own response port and returns the response.
  ///
  /// Errors and Exceptions in the service worker are forwarded to the main isolate.

  Future<dynamic> send(M data) async {
    final responsePort = ReceivePort();

    _sendPort.send(
      _Message(responsePort.sendPort, data)
    );
    // use completer to rethrow error
    final completer = Completer();

    final response = await responsePort.first;
    if (response is _Error) {
      completer.completeError(response.error);
    }
    else {
      completer.complete(response.data);
    }
    return completer.future;
  }
}


/// A service worker is meant to run in an isolate and kept alive as long as it has a connection to the [ServiceWorkerController].
/// This means the class with all its data will persist until the isolates gets closed.
///
/// Extend this class to write your own service worker.
///
/// Use the [ServiceWorkerController] to spawn your custom service worker and communicate with it.
///
/// `M` specifies the type of messages that will be send to this service worker.
/// If omitted this will be `dynamic`.

abstract class ServiceWorker<M> {
  final ReceivePort _receivePort;

  ServiceWorker(SendPort sendPort) : _receivePort = ReceivePort() {
    sendPort.send(_receivePort.sendPort);
    // listening to this stream will keep the isolate alive
    _receivePort
      .cast<_Message<M>>()
      .listen(_messageHandler);
  }

  void exit() => _receivePort.close();

  void _messageHandler(_Message<M> message) async {
    try {
      message.responsePort.send(_Response(
        await messageHandler(message.data),
      ));
    }
    catch(error) {
      message.responsePort.send(_Error(error));
    }
  }

  Future<dynamic> messageHandler(M message);
}


class _Message<T> {
  final SendPort responsePort;
  final T data;

  const _Message(this.responsePort, this.data);
}

class _Response<T> {
  final T data;
  const _Response(this.data);
}

class _Error<T> {
  final T error;
  const _Error(this.error);
}
