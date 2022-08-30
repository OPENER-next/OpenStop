import 'package:flutter/material.dart';

import '/models/answer.dart';
import '/models/question_input.dart';
import 'question_input_widget.dart';

class DurationInput extends QuestionInputWidget<DurationAnswer> {
   DurationInput({
    required QuestionInput definition,
    required AnswerController<DurationAnswer> controller,
    Key? key
  }) : super(definition: definition, controller: controller, key: key);

  // build time units from unit string
  late final _unitValueMap = _initUnits();

  List<TimeUnit> _initUnits() {
    final unitStrings = definition.values.values.first.unit?.split(',') ?? [];
    return unitStrings
      .map(TimeUnit.fromString)
      .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Row(
        children: _buildChildren(),
      ),
    );
  }

  List<Widget> _buildChildren() {
    final List<Widget> widgets = [];

    final entry = _unitValueMap.first;
    widgets.add(Flexible(
      child: TimeScroller(
        definition: definition,
        controller: controller,
        timeUnit: entry,
      ),
    ));

    for (final entry in _unitValueMap.skip(1)) {
      widgets.add(const VerticalDivider(color: Colors.transparent));

      widgets.add(Flexible(
        child: TimeScroller(
          definition: definition,
          controller: controller,
          timeUnit: entry,
        ),
      ));
    }

    return widgets;
  }
}


class TimeScroller extends StatefulWidget {
  final QuestionInput definition;

  final TimeUnit timeUnit;

  final AnswerController<DurationAnswer> controller;

  const TimeScroller({
    required this.definition,
    required this.controller,
    required this.timeUnit,
    Key? key,
  }) : super(key: key);

  @override
  State<TimeScroller> createState() => _TimeScrollerState();
}

class _TimeScrollerState extends State<TimeScroller> {
  late final _scrollController = FixedExtentScrollController(
    initialItem: _clampIndex(_valueToIndex(_currentValue))
  );

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_answerControllerChange);
  }

  @override
  void didUpdateWidget(covariant TimeScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      widget.controller.addListener(_answerControllerChange);
      oldWidget.controller.removeListener(_answerControllerChange);
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
            onSelectedItemChanged: _handleChange,
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (BuildContext context, int index) {
                final value = _indexToValue(index);
                return Center(
                  child: AnimatedOpacity(
                    opacity: value == _currentValue ? 1 : 0.3,
                    duration: const Duration(milliseconds: 200),
                    child: AnimatedScale(
                      scale: value == _currentValue ? 1 : 0.7,
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        value.toString().padLeft(2, '0'),
                        style: Theme.of(context).textTheme.headline5
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
            child: Text(widget.timeUnit.label,
              style: Theme.of(context).textTheme.caption
            )
          ),
        )
      ]
    );
  }

  Duration get _currentDuration => widget.controller.answer?.value ?? Duration.zero;

  int get _currentValue => _extractFromDuration(widget.timeUnit.key, _currentDuration);

  int _clampIndex(int index) => (-index) % (widget.timeUnit.max ~/ widget.timeUnit.steps);

  int _indexToValue(int index) => _clampIndex(index) * widget.timeUnit.steps;

  int _valueToIndex(int value) => value ~/ widget.timeUnit.steps;


  /// Returns the value of this unit of a given [Duration]

  int _extractFromDuration(String unitKey, Duration duration) {
    switch (unitKey) {
      case 'd': return duration.inDays;
      case 'h': return duration.inHours % 24;
      case 'm': return duration.inMinutes % 60;
      case 's': return duration.inSeconds % 60;
      default: return 0;
    }
  }

  /// Update scroll controller on answer controller changes.

  void _answerControllerChange() {
    final newIndex = _valueToIndex(_currentValue);
    // only update scroll controller if index differs to avoid endless regressions
    if (_clampIndex(_scrollController.selectedItem) != newIndex) {
      _scrollController.jumpToItem(newIndex);
    }
  }

  void _handleChange(int index) {
    final value = _indexToValue(index);
    final newDuration = Duration(
      days: widget.timeUnit.key == 'd' ? value : _extractFromDuration('d', _currentDuration),
      hours: widget.timeUnit.key == 'h' ? value : _extractFromDuration('h', _currentDuration),
      minutes: widget.timeUnit.key == 'm' ? value : _extractFromDuration('m', _currentDuration),
      seconds: widget.timeUnit.key == 's' ? value : _extractFromDuration('s', _currentDuration),
    );

    // if all values are zero return null
    widget.controller.answer = newDuration != Duration.zero
      ? DurationAnswer(
        questionValues: widget.definition.values,
        value: newDuration
      )
      : null;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    widget.controller.removeListener(_answerControllerChange);
    super.dispose();
  }
}


class TimeUnit {
  final String key;
  final String label;
  final int max;
  final int steps;

  const TimeUnit({
    required this.key,
    required this.label,
    required this.max,
    required this.steps
  });

  /// A single time unit string is composed of a unit identifier, a colon separator and a number that indicates the step size:
  /// <identifier>:<number of steps>

  factory TimeUnit.fromString(String unitString) {
    final unitParts = unitString.split(':');

    final unitKey = unitParts[0];
    final unitSteps = int.parse(unitParts[1]);
    final String unitName;
    final int unitMax;

    switch (unitKey) {
      case 'd':
        unitName = 'Tage';
        unitMax = 366;
      break;
      case 'h':
        unitName = 'Stunden';
        unitMax = 24;
      break;
      case 'm':
        unitName = 'Minuten';
        unitMax = 60;
      break;
      case 's':
        unitName = 'Sekunden';
        unitMax = 60;
      break;
      default:
        unitName = 'Unknown';
        unitMax = 0;
    }

    return TimeUnit(
      key: unitKey,
      label: unitName,
      max: unitMax,
      steps: unitSteps
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TimeUnit &&
      other.key == key &&
      other.label == label &&
      other.max == max &&
      other.steps == steps;
  }

  @override
  int get hashCode {
    return key.hashCode ^
      label.hashCode ^
      max.hashCode ^
      steps.hashCode;
  }
}
