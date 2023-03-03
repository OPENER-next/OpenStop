import 'dart:async';

import 'package:flutter/foundation.dart';

/// Simple class to debounce callbacks by a given duration.
///
/// The first callback will immediately fire, while subsequent callbacks are throttled.
///
/// It may also immediately emit the incoming event if the time between the
/// last callback and the new callback exceeds the interval/duration.

class Debouncer {
  final Duration duration;

  Timer? _timer;

  late VoidCallback _callback;

  DateTime _lastTimestamp = DateTime.fromMillisecondsSinceEpoch(0);

  Debouncer(this.duration);

  /// Transforms a given callback into a debounced callback.

  VoidCallback debounce(VoidCallback callback) {
    _callback = callback;
    return _debounce;
  }

  /// Runs the given callback debounced.

  void callDebounced(VoidCallback callback) {
    _callback = callback;
    _debounce();
  }

  void _debounce() {
    final currentTimestamp = DateTime.now();
    if (_timer?.isActive != true) {
      final timeDifference = currentTimestamp.difference(_lastTimestamp);
      // if the time span between the previous and current event is greater than the debounce duration fire immediately
      if (timeDifference > duration) {
        _callback();
      }
      // otherwise set a timer that will fire with the most up to date event after the remaining time
      else {
        _timer = Timer(duration - timeDifference, _timerCallback);
      }
    }
    _lastTimestamp = currentTimestamp;
  }

  void _timerCallback() {
    _callback();
    _lastTimestamp = DateTime.now();
  }

  /// Discards any queued/debounced callbacks.
  ///
  /// Should be called on disposal to prevent unwanted delayed callbacks.

  void cancel() {
    _timer?.cancel();
  }
}
