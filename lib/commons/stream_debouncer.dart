import 'dart:async';

/// Simple extension to debounce streams.
/// This will return a new stream that listens to the given stream and emits events debounced by the given duration.

extension Debouncer on Stream {
  Stream<T> debounce<T> ([duration = const Duration(milliseconds: 300)]) {
    final streamController = StreamController<T>();

    Timer? timer;

    DateTime lastTimestamp = DateTime.fromMillisecondsSinceEpoch(0);

    var lastEvent;

    this.listen((event) {
      final currentTimestamp = DateTime.now();

      // store latest event
      if (timer != null && timer!.isActive) {
        lastEvent = event;
      }
      else {
        final timeDifference = currentTimestamp.difference(lastTimestamp);
        // if the time span between the previous and current event is greater than the debounce duration fire immediately
        if (timeDifference > duration) {
          streamController.add(event);
        }
        // otherwise set a timer that will fire with the most up to date event after the remaining time
        else {
          timer = Timer(duration - timeDifference, () {
            if (lastEvent != null) streamController.add(lastEvent);
          });
        }
      }

      lastTimestamp = currentTimestamp;
    });

    return streamController.stream;
  }
}
