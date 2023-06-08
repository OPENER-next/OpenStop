import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/models/answer.dart';
import '/models/question_catalog/answer_definition.dart';
import 'question_input_widget.dart';

class DurationInput extends QuestionInputWidget<DurationAnswerDefinition, DurationAnswer> {
  late final int _maxDays, _maxHours, _maxMinutes, _maxSeconds;

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
      if (definition.input.daysStepSize > 0) {
        maxDays = maxValue;
      }
      else if (definition.input.hoursStepSize > 0) {
        maxDays = 1;
        maxHours = maxValue;
      }
      else if (definition.input.minutesStepSize > 0) {
        maxDays = 1;
        maxHours = 1;
        maxMinutes = maxValue;
      }
      else if (definition.input.secondsStepSize > 0) {
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
    return SizedBox(
      height: 150,
      child: Row(
        children: _intersperse(
          _children (context),
          const VerticalDivider(color: Colors.transparent),
        ).toList(),
      ),
    );
  }

  Iterable<Widget> _children (BuildContext context) sync* {
    if (definition.input.daysStepSize > 0) {
      yield Flexible(
        child: TimeScroller(
          name: 'Tage',
          step: definition.input.daysStepSize,
          limit: _maxDays,
          value: _remainingDays,
          onChange: (value) => _handleChange(days: value),
        ),
      );
    }
    if (definition.input.hoursStepSize > 0) {
      yield Flexible(
        child: TimeScroller(
          name: 'Stunden',
          step: definition.input.hoursStepSize,
          limit: _maxHours,
          value: _remainingHours,
          onChange: (value) => _handleChange(hours: value),
        ),
      );
    }
    if (definition.input.minutesStepSize > 0) {
      yield Flexible(
        child: TimeScroller(
          name: 'Minuten',
          step: definition.input.minutesStepSize,
          limit: _maxMinutes,
          value: _remainingMinutes,
          onChange: (value) => _handleChange(minutes: value),
        ),
      );
    }
    if (definition.input.secondsStepSize > 0) {
      yield Flexible(
        child: TimeScroller(
          name: 'Sekunden',
          step: definition.input.secondsStepSize,
          limit: _maxSeconds,
          value: _remainingSeconds,
          onChange: (value) => _handleChange(seconds: value),
        ),
      );
    }
  }

  Duration get _currentDuration => controller.answer?.value ?? Duration.zero;

  int get _remainingDays => _currentDuration.inDays % _maxDays;

  int get _remainingHours => _currentDuration.inHours % _maxHours;

  int get _remainingMinutes => _currentDuration.inMinutes % _maxMinutes;

  int get _remainingSeconds => _currentDuration.inSeconds % _maxSeconds;

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
  final String name;

  final int step;

  final int limit;

  final int value;

  final void Function(int duration) onChange;

  const TimeScroller({
    required this.name,
    required this.step,
    required this.limit,
    required this.onChange,
    required this.value,
    Key? key,
  }) : super(key: key);

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
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6.0),
          foregroundDecoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.background,
                Theme.of(context).colorScheme.background.withOpacity(0.0),
                Theme.of(context).colorScheme.background.withOpacity(0.0),
                Theme.of(context).colorScheme.background
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.07, 0.2, 0.8, 0.93],
            ),
            border: Border.all(color: Theme.of(context).colorScheme.primary),
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          ),
          child: ListWheelScrollView.useDelegate(
            itemExtent: 30,
            controller: _scrollController,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) => widget.onChange(_indexToValue(index)),
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (BuildContext context, int index) {
                final value = _indexToValue(index);
                return Center(
                  child: AnimatedOpacity(
                    opacity: value == widget.value ? 1 : 0.3,
                    duration: const Duration(milliseconds: 200),
                    child: AnimatedScale(
                      scale: value == widget.value ? 1 : 0.7,
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        value.toString().padLeft(2, '0'),
                        style: Theme.of(context).textTheme.headlineSmall
                      ),
                    ),
                  ),
                );
              }
            ),
          ),
        ),
        Positioned(
          left: 8,
          child: Container(
            color: Theme.of(context).colorScheme.background,
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(widget.name,
              style: Theme.of(context).textTheme.bodySmall
            )
          ),
        )
      ]
    );
  }

  int _clampIndex(int index) => (-index) % (widget.limit ~/ widget.step);

  int _indexToValue(int index) => _clampIndex(index) * widget.step;

  int _valueToIndex(int value) => value ~/ widget.step;


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
