
import 'dart:async';


extension Where<T> on Stream<T> {

  /// A helper method that only emits events when they are of a certain type.

  Stream<S> whereType<S>() => transform(StreamTransformer.fromHandlers(
    handleData: (event, sink) {
      if (event is S) sink.add(event);
    }
  ));
}


/// A stream transformer to debounce stream events by a given duration.
///
/// This will only emit events when the given time between the previously emitted
/// event to the current event exceeds the given duration.
/// Therefore it always buffers the latest event and emits it after the time
/// difference has passed.
///
/// It may also immediately emit the incoming event if the time between the
/// last emitted event and the new event exceeds the interval/duration.

class DebounceTransformer<S> implements StreamTransformer<S, S> {
  bool cancelOnError;

  Duration duration;

  late final StreamController<S> _controller;

  StreamSubscription? _subscription;

  Stream<S>? _stream;

  Timer? _timer;

  DateTime _lastTimestamp = DateTime.fromMillisecondsSinceEpoch(0);

  S? _lastEvent;

  DebounceTransformer(this.duration, { bool sync = false, this.cancelOnError = false }) {
    _controller = StreamController<S>(
      onListen: _onListen,
      onCancel: _onCancel,
      // wrap in arrow functions because initially the subscription will always be null
      onPause: () => _subscription?.pause(),
      onResume: () => _subscription?.resume(),
      sync: sync
    );
  }

  void _onListen() {
    _subscription = _stream?.listen(_onData,
      onError: _controller.addError,
      onDone: _controller.close,
      cancelOnError: cancelOnError
    );
  }

  void _onCancel() {
    _subscription?.cancel();
    _timer?.cancel();
    _subscription = null;
  }

  void _onData(S event) {
    final currentTimestamp = DateTime.now();

    if (_timer?.isActive != true) {
      final timeDifference = currentTimestamp.difference(_lastTimestamp);
      // if the time span between the previous and current event is greater than the debounce duration fire immediately
      if (timeDifference > duration) {
        _controller.add(event);
      }
      // otherwise set a timer that will fire with the most up to date event after the remaining time
      else {
        _timer = Timer(duration - timeDifference, _timerCallback);
      }
    }

    _lastEvent = event;
    _lastTimestamp = currentTimestamp;
  }

  void _timerCallback() {
    if (_lastEvent is S) {
      _controller.add(_lastEvent as S);
      _lastTimestamp = DateTime.now();
    }
  }

  @override
  Stream<S> bind(Stream<S> stream) {
    _stream = stream;
    return _controller.stream;
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    return StreamTransformer.castFrom(this);
  }
}
