import 'package:flutter/material.dart';

import '/models/answer.dart';
import '/models/question_input.dart';
import 'question_input_widget.dart';

class DurationInput extends QuestionInputWidget {
  const DurationInput(
    QuestionInput questionInput,
    { AnswerController? controller, Key? key }
  ) : super(questionInput, controller: controller, key: key);

  @override
  _DurationInputState createState() => _DurationInputState();
}

class _DurationInputState extends QuestionInputWidgetState {
  Map<TimeUnit, int> _unitValueMap = const {};

  void _initUnits() {
    final Map<TimeUnit, int> newUnitValueMap = {};
    final unitStrings = widget.questionInput.values.values.first.unit?.split(',') ?? [];

    for (final unitString in unitStrings) {
      final key = TimeUnit.fromString(unitString);
      newUnitValueMap[key] = _unitValueMap[key] ?? 0;
    }
    _unitValueMap = newUnitValueMap;
  }


  List<Widget> _buildChildren() {
    final List<Widget> widgets = [];

    final entry = _unitValueMap.keys.first;
    widgets.add(Flexible(
      child: TimeScroller(
        timeUnitLabel: entry.label,
        timeUnitMax: entry.max,
        timeUnitSteps: entry.steps,
        onChange: (value) {
          _unitValueMap[entry] = value;
          _handleChange();
        }
      ),
    ));

    for (final entry in _unitValueMap.keys.skip(1)) {
      widgets.add(const VerticalDivider(color: Colors.transparent));

      widgets.add(Flexible(
        child: TimeScroller(
          timeUnitLabel: entry.label,
          timeUnitMax: entry.max,
          timeUnitSteps: entry.steps,
          onChange: (value) {
            _unitValueMap[entry] = value;
            _handleChange();
          }
        ),
      ));
    }

    return widgets;
  }

  @override
  void initState() {
    _initUnits();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DurationInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initUnits();
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

  void _handleChange() {
    final duration = Duration(
      days: _getValueByUnit('d'),
      hours: _getValueByUnit('h'),
      minutes: _getValueByUnit('m'),
      seconds: _getValueByUnit('s'),
    );

    // if all values are zero return null
    widget.controller?.answer = duration != Duration.zero
      ? DurationAnswer(
        questionValues: widget.questionInput.values,
        value: duration
      )
      : null;
  }


  int _getValueByUnit(String unitKey) {
     try {
       return _unitValueMap.entries.firstWhere(
         (entry) => entry.key.key == unitKey
        ).value;
     }
     catch (e) {
       return 0;
     }
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


class TimeScroller extends StatefulWidget {
  final String timeUnitLabel;
  final int timeUnitMax;
  final int timeUnitSteps;
  final Function(int value)? onChange;

  const TimeScroller({
    required this.timeUnitLabel,
    required this.timeUnitMax,
    required this.timeUnitSteps,
    this.onChange,
    Key? key,
  }) : super(key: key);

  @override
  _TimeScrollerState createState() => _TimeScrollerState();
}

class _TimeScrollerState extends State<TimeScroller> {
  var _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        margin: const EdgeInsets.only(top: 6.0),
        foregroundDecoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.0),
              Theme.of(context).colorScheme.surface.withOpacity(0.0),
              Theme.of(context).colorScheme.surface
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
          controller: FixedExtentScrollController(),
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: _handleChange,
          childDelegate: ListWheelChildBuilderDelegate(
              builder: (BuildContext context, int index) {
            index = (-index) % (widget.timeUnitMax ~/ widget.timeUnitSteps);
            return Center(
              child: AnimatedOpacity(
                opacity: index == _selected ? 1 : 0.3,
                duration: const Duration(milliseconds: 200),
                child: AnimatedScale(
                  scale: index == _selected ? 1 : 0.7,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                      (index * widget.timeUnitSteps).toString().padLeft(2, '0'),
                      style: Theme.of(context).textTheme.headline5),
                ),
              ),
            );
          }),
        ),
      ),
      Positioned(
        left: 8,
        child: Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(widget.timeUnitLabel,
                style: Theme.of(context).textTheme.caption)),
      )
    ]);
  }


  void _handleChange(int index) {
    setState(() {
      _selected = (-index) % (widget.timeUnitMax ~/ widget.timeUnitSteps);
    });

    widget.onChange?.call(_selected * widget.timeUnitSteps);
  }
}
