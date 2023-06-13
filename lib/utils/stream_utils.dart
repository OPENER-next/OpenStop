import 'dart:async';

extension InitMultiStreamExtension<T> on Stream<T> {

  /// Create a MultiStream from this stream and run an initial asynchronous method before every new subscription.
  ///
  /// This can be useful if you want to add initial data to the stream.

  Stream<T> makeMultiStreamAsync(FutureOr<void> Function(MultiStreamController<T> controller) init) {
    final broadcastStream = asBroadcastStream();

    return Stream.multi((controller) async {
      // cache events that may occur while "init" is running
      final events = <T>[];
      final sub = broadcastStream.listen(events.add);
      // wait till init is done
      await init(controller);
      sub.cancel();
      events.forEach(controller.addSync);
      controller.addStream(broadcastStream);
    });
  }

  /// Create a MultiStream from this stream and run an initial method before every new subscription.
  ///
  /// This can be useful if you want to add initial data to the stream.

  Stream<T> makeMultiStream(void Function(MultiStreamController<T> controller) init) {
    final broadcastStream = asBroadcastStream();

    return Stream.multi((controller) {
      init(controller);
      controller.addStream(broadcastStream);
    });
  }
}
