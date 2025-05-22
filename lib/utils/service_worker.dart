import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

typedef ServiceWorkerInit<M> = ServiceWorker<M> Function(SendPort sendPort);

/// Helper class to spawn a custom [ServiceWorker] and communicate with it.
///
/// ```
/// final controller = await ServiceWorkerController.spawn(YourCustomWorker.new);
/// controller.send(...);
/// controller.subscribe(...);
///
/// class YourCustomWorker extends ServiceWorker {
///   YourCustomWorker(super.sendPort);
///
///   Future<dynamic> messageHandler(message) {
///     ...
///   }
///
///   Stream<dynamic> subscriptionHandler(message) {
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

  Future<T> send<T>(M data) async {
    final responsePort = ReceivePort();
    _sendPort.send(
      _Message(responsePort.sendPort, data),
    );
    // use completer to rethrow error
    final completer = Completer<T>();

    final _Response response = await responsePort.first;
    if (response.type == _ResponseType.error) {
      final (Object error, StackTrace stackTrace) = response.data;
      completer.completeError(error, stackTrace);
    } else {
      completer.complete(response.data);
    }
    return completer.future;
  }

  // TODO
  Stream<T> subscribe<T>(M data) {
    final responsePort = ReceivePort();
    _sendPort.send(
      _Message(responsePort.sendPort, data, subscribe: true),
    );
    // used to send cancel, pause, and resume notifications
    final sendPortCompleter = Completer<SendPort>();

    final streamController = StreamController<T>(
      onCancel: () async {
        (await sendPortCompleter.future).send(_StreamSubscriptionChange.cancel);
        responsePort.close();
      },
      onPause: () async {
        (await sendPortCompleter.future).send(_StreamSubscriptionChange.pause);
      },
      onResume: () async {
        (await sendPortCompleter.future).send(_StreamSubscriptionChange.resume);
      },
    );

    // late final required due to self reference
    // see: https://stackoverflow.com/questions/44450758/cancel-stream-ondata

    // can be ignored because the subscription depends on responsePort which we close
    // ignore: cancel_subscriptions
    late final StreamSubscription subscription;
    subscription = responsePort.listen(
      (message) {
        // expect SendPort as first message and store it
        sendPortCompleter.complete(message);
        // rewrite response handler after initial response
        subscription.onData((message) {
          message as _Response;
          switch (message.type) {
            case _ResponseType.message:
              streamController.add(message.data);
            case _ResponseType.error:
              final (Object error, StackTrace stackTrace) = message.data;
              streamController.addError(error, stackTrace);
            case _ResponseType.done:
              responsePort.close();
          }
        });
      },
      onError: streamController.addError,
      onDone: streamController.close,
    );

    return streamController.stream;
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
    _receivePort.cast<_Message<M>>().listen((message) {
      if (message.subscribe) {
        _subscriptionHandler(message);
      } else {
        _messageHandler(message);
      }
    });
  }

  @mustCallSuper
  void exit() => _receivePort.close();

  Future<void> _messageHandler(_Message<M> message) async {
    try {
      message.responsePort.send(
        _Response(
          _ResponseType.message,
          await messageHandler(message.data),
        ),
      );
    } catch (error, stackTrace) {
      message.responsePort.send(
        _Response(
          _ResponseType.error,
          (error, stackTrace),
        ),
      );
    }
  }

  Future<void> _subscriptionHandler(_Message<M> message) async {
    final receivePort = ReceivePort();
    // initially send a SendPort to receive stream state changes
    message.responsePort.send(receivePort.sendPort);

    final stream = subscriptionHandler(message.data);
    final subscription = stream.listen(
      (event) {
        message.responsePort.send(_Response(_ResponseType.message, event));
      },
      onError: (Object error, StackTrace stackTrace) {
        message.responsePort.send(_Response(_ResponseType.error, (error, stackTrace)));
      },
      onDone: () {
        message.responsePort.send(const _Response(_ResponseType.done, null));
      },
    );

    receivePort.listen((event) {
      switch (event) {
        case _StreamSubscriptionChange.cancel:
          subscription.cancel();
        case _StreamSubscriptionChange.pause:
          subscription.pause();
        case _StreamSubscriptionChange.resume:
          subscription.resume();
      }
    });
  }

  Future<dynamic> messageHandler(M message);

  Stream<dynamic> subscriptionHandler(M subscription);
}

class _Message<T> {
  final SendPort responsePort;
  final bool subscribe;
  final T data;

  const _Message(this.responsePort, this.data, {this.subscribe = false});
}

enum _StreamSubscriptionChange { cancel, pause, resume }

class _Response<T> {
  final _ResponseType type;
  final T data;
  const _Response(this.type, this.data);
}

enum _ResponseType { message, error, done }
