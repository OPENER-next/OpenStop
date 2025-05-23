import 'package:flutter/material.dart';

/// Adapter class to turn a [ChangeNotifier] into an [Animation].
///
/// This forwards the notifications of the [ChangeNotifier] and derives
/// the [Animation.value] using the provided [transformer] callback.
///
/// This is almost identical to https://api.flutter.dev/flutter/animation/Animation/Animation.fromValueListenable.html

class DerivedAnimation<T extends ChangeNotifier, V> extends Animation<V> {
  final T _notifier;
  final V Function(T) _transformer;

  DerivedAnimation({
    required T notifier,
    required V Function(T) transformer,
  }) : _notifier = notifier,
       _transformer = transformer;

  @override
  void addListener(VoidCallback listener) {
    _notifier.addListener(listener);
  }

  @override
  void addStatusListener(AnimationStatusListener listener) {
    // status will never change.
  }

  @override
  void removeListener(VoidCallback listener) {
    _notifier.removeListener(listener);
  }

  @override
  void removeStatusListener(AnimationStatusListener listener) {
    // status will never change.
  }

  @override
  AnimationStatus get status => AnimationStatus.forward;

  @override
  V get value => _transformer.call(_notifier);
}
