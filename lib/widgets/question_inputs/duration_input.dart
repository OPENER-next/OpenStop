import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

import '/models/answer.dart';
import '/models/question_catalog/answer_definition.dart';
import 'question_input_widget.dart';

class DurationInput extends QuestionInputWidget<DurationAnswerDefinition, DurationAnswer> {
  late final int _maxDays, _maxHours, _maxMinutes, _maxSeconds;

  Duration get _currentDuration => controller.answer?.value ?? Duration.zero;

  int get _remainingDays => _currentDuration.inDays % _maxDays;
  int get _remainingHours => _currentDuration.inHours % _maxHours;
  int get _remainingMinutes => _currentDuration.inMinutes % _maxMinutes;
  int get _remainingSeconds => _currentDuration.inSeconds % _maxSeconds;

  DurationInput({
    required super.definition,
    required super.controller,
    super.key,
  }) {
    final maxValue = definition.input.max != null ? definition.input.max! + 1 : null;
    int? maxDays, maxHours, maxMinutes, maxSeconds;

    // set max values to 1 so the "_remainingUnit" functions return 0 for all unused units
    // this is necessary because the biggest unit will contain the left over duration
    if (maxValue != null) {
      if (definition.input.days.display) {
        maxDays = maxValue;
      }
      else if (definition.input.hours.display) {
        maxDays = 1;
        maxHours = maxValue;
      }
      else if (definition.input.minutes.display) {
        maxDays = 1;
        maxHours = 1;
        maxMinutes = maxValue;
      }
      else if (definition.input.seconds.display) {
        maxDays = 1;
        maxHours = 1;
        maxMinutes = 1;
        maxSeconds = maxValue;
      }
    }

    _maxDays = maxDays ?? 365;
    _maxHours = maxHours ?? Duration.hoursPerDay;
    _maxMinutes = maxMinutes ?? Duration.minutesPerHour;
    _maxSeconds = maxSeconds ?? Duration.secondsPerMinute;
  }

  @override
  Widget build(BuildContext context) {
    final showStopWatch =
      !definition.input.days.display &&
      !definition.input.hours.display &&
      !definition.input.minutes.display &&
      definition.input.seconds.display &&
      definition.input.seconds.step == 1;

    return Column(
      children: [
        SizedBox(
          height: 130,
          child: showStopWatch
          ? StopWatchScroller(
            limit: _maxSeconds,
            value: _remainingSeconds,
            onChange: (value) => _handleChange(seconds: value),
          )
          : Row(
            children: _intersperse(
              _timeScrollerWidgets().map(
                (child) => Flexible(child: child),
              ),
              Text(':',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ).toList(),
          ),
        ),
        Row(
          children: _timeLabels(context)
            .map<Widget>((label) => Expanded(
              child: Text(label,
                textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            )
            .toList(),
        ),
      ],
    );
  }

  Iterable<String> _timeLabels(BuildContext context) sync* {
    final appLocale = AppLocalizations.of(context)!;
    if (definition.input.days.display) {
      yield appLocale.durationInputDaysLabel;
    }
    if (definition.input.hours.display) {
      yield appLocale.durationInputHoursLabel;
    }
    if (definition.input.minutes.display) {
      yield appLocale.durationInputMinutesLabel;
    }
    if (definition.input.seconds.display) {
      yield appLocale.durationInputSecondsLabel;
    }
  }

  Iterable<Widget> _timeScrollerWidgets() sync* {
    if (definition.input.days.display) {
      yield TimeScroller(
        step: definition.input.days.step,
        limit: _maxDays,
        value: _remainingDays,
        onChange: (value) => _handleChange(days: value),
      );
    }
    if (definition.input.hours.display) {
      yield TimeScroller(
        step: definition.input.hours.step,
        limit: _maxHours,
        value: _remainingHours,
        onChange: (value) => _handleChange(hours: value),
      );
    }
    if (definition.input.minutes.display) {
      yield TimeScroller(
        step: definition.input.minutes.step,
        limit: _maxMinutes,
        value: _remainingMinutes,
        onChange: (value) => _handleChange(minutes: value),
      );
    }
    if (definition.input.seconds.display) {
      yield TimeScroller(
        step: definition.input.seconds.step,
        limit: _maxSeconds,
        value: _remainingSeconds,
        onChange: (value) => _handleChange(seconds: value),
      );
    }
  }

  Iterable<T> _intersperse<T>(Iterable<T> iterable, T element) sync* {
    final iterator = iterable.iterator;
    if (iterator.moveNext()) {
      yield iterator.current;
      while (iterator.moveNext()) {
        yield element;
        yield iterator.current;
      }
    }
  }

  void _handleChange({
    int? days,
    int? hours,
    int? minutes,
    int? seconds,
  }) {
    final newDuration = Duration(
      days: days ?? _remainingDays,
      hours: hours ?? _remainingHours,
      minutes: minutes ?? _remainingMinutes,
      seconds: seconds ?? _remainingSeconds,
    );

    // if all values are zero return null
    controller.answer = newDuration != Duration.zero
      ? DurationAnswer(
        definition: definition,
        value: newDuration
      )
      : null;
  }
}


class TimeScroller extends StatefulWidget {
  final int step;

  final int limit;

  final int value;

  final void Function(int duration) onChange;

  const TimeScroller({
    required this.step,
    required this.limit,
    required this.onChange,
    required this.value,
    super.key,
  });

  @override
  State<TimeScroller> createState() => _TimeScrollerState();
}

class _TimeScrollerState extends State<TimeScroller> {
  late final _scrollController = FixedExtentScrollController(
    initialItem: _clampIndex(_valueToIndex(widget.value))
  );

  @override
  void didUpdateWidget(covariant TimeScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final newIndex = _valueToIndex(widget.value);
      // update scroll controller on answer controller changes
      // but only update if index differs to avoid endless regressions
      if (_clampIndex(_scrollController.selectedItem) != newIndex) {
        _scrollController.jumpToItem(newIndex);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.0),
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.0),
            Theme.of(context).colorScheme.surface
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.07, 0.2, 0.8, 0.93],
        ),
      ),
      child: ListWheelScrollView.useDelegate(
        itemExtent: 30,
        controller: _scrollController,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) => widget.onChange(_indexToValue(index)),
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (BuildContext context, int index) {
            final value = _indexToValue(index);
            // safety check required because selected item cannot be retrieved on initial build
            final isActive = index == (_scrollController.position.hasContentDimensions
              ? _scrollController.selectedItem
              : _scrollController.initialItem
            );
            return AnimatedOpacity(
              opacity: isActive ? 1 : 0.3,
              duration: const Duration(milliseconds: 200),
              child: AnimatedScale(
                scale: isActive ? 1 : 0.7,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  value.toString().padLeft(2, '0'),
                  style: Theme.of(context).textTheme.headlineSmall
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  int _clampIndex(int index) => (-index) % (widget.limit / widget.step).ceil();

  int _indexToValue(int index) => _clampIndex(index) * widget.step;

  int _valueToIndex(int value) => value ~/ widget.step;


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}


class StopWatchScroller extends TimeScroller {
  const StopWatchScroller({
    required super.limit,
    required super.onChange,
    required super.value,
    super.key
  }) : super(step: 1);

  @override
  State<TimeScroller> createState() => _StopWatchScrollerState();
}

class _StopWatchScrollerState extends _TimeScrollerState {
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.outlined(
          onPressed: widget.value != 0 ? reset : null,
          icon: const Icon(MdiIcons.timerRefreshOutline),
        ),
        Expanded(
          child: NotificationListener<UserScrollNotification>(
            child: super.build(context),
            onNotification: (notification) {
              if (notification.direction != ScrollDirection.idle) {
                pause();
              }
              return true;
            },
          ),
        ),
        IconButton.outlined(
          isSelected: isActive,
          onPressed: isActive ? pause : start,
          selectedIcon: const Icon(MdiIcons.timerPauseOutline),
          icon: const Icon(MdiIcons.timerPlayOutline),
        ),
      ],
    );
  }

  bool get isActive => _timer?.isActive == true;

  void start() {
    setState(() {
      _clearTimer();
      _timer = Timer.periodic(const Duration(seconds: 1), _handleTick);
    });
  }

  void pause() {
    setState(_clearTimer);
  }

  void reset() {
    setState(() {
      _clearTimer();
      _tick(0);
    });
  }

  void _tick(int index) {
    _scrollController.animateToItem(index,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  void _clearTimer() {
    if (_timer != null){
      _timer!.cancel();
      _timer = null;
    }
  }

  void _handleTick(Timer timer) {
    final nextSecond = _scrollController.selectedItem - 1;
    _tick(nextSecond);
    // stop timer when reaching 0
    if (_indexToValue(nextSecond) == 0) {
      pause();
    }
  }

  @override
  void dispose() {
    _clearTimer();
    super.dispose();
  }
}
