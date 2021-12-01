import 'package:flutter/material.dart';
import '/widgets/question_inputs/question_input_view.dart';
import '/models/question_input.dart';

class DurationInput extends QuestionInputView {
  DurationInput(QuestionInput questionInput,
      {void Function(Map<String, String>)? onChange, Key? key})
      : super(questionInput, onChange: onChange, key: key);

  @override
  _DurationInputState createState() => _DurationInputState();
}

class _DurationInputState extends State<DurationInput> {
  final List<TimeUnit> _unitList = [];

  void initUnits() {
    final units = widget.questionInput.unit.split(',').map((e) => e.split(":"));
    for (var element in units) {
      if (element[0] == "d") {
        var d = TimeUnit(
            unit: 'Tage',
            max: 366,
            steps: int.parse(element[1]));
        _unitList.add(d);
      } else if (element[0] == "h") {
        var h = TimeUnit(
          unit: 'Stunden',
          max: 24,
          steps: int.parse(element[1]),
        );
        _unitList.add(h);
      } else if (element[0] == "m") {
        var m = TimeUnit(
          unit: 'Minuten',
          max: 60,
          steps: int.parse(element[1]),
        );
        _unitList.add(m);
      } else if (element[0] == "s") {
        var s = TimeUnit(
          unit: 'Sekunden',
          max: 60,
          steps: int.parse(element[1]),
        );
        _unitList.add(s);
      }
    }
  }

  List<Widget> _buildChildren() {
    final List<Widget> widgets = [];

    final entry = _unitList.first;
    widgets.add(Flexible(
      child: TimeScroller(
        timeUnit: entry.unit,
        timeUnitMax: entry.max,
        timeUnitSteps: entry.steps,
      ),
    ));

    for (var i = 1; i < _unitList.length; i++) {
      widgets.add(VerticalDivider(color: Colors.transparent));

      final entry = _unitList[i];
      widgets.add(Flexible(
        child: TimeScroller(
          timeUnit: entry.unit,
          timeUnitMax: entry.max,
          timeUnitSteps: entry.steps,
        ),
      ));
    }

    return widgets;
  }

  @override
  void initState() {
    initUnits();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DurationInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unitList.clear();
    initUnits();
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
}

class TimeUnit {
  String unit;
  int max;
  int steps;

  TimeUnit({required this.unit, required this.max, required this.steps});
}

class TimeScroller extends StatefulWidget {
  final String timeUnit;
  final int timeUnitMax;
  final int timeUnitSteps;

  TimeScroller(
      {Key? key,
        required this.timeUnit,
        required this.timeUnitMax,
        required this.timeUnitSteps})
      : super(key: key);

  @override
  _TimeScrollerState createState() => _TimeScrollerState();
}

class _TimeScrollerState extends State<TimeScroller> {
  var _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        margin: const EdgeInsets.only(top:6.0),
        foregroundDecoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.white.withOpacity(0.0),
              Colors.white.withOpacity(0.0),
              Colors.white
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.07, 0.2, 0.8, 0.93],
          ),
          border: Border.all(color: Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: ListWheelScrollView.useDelegate(
          itemExtent: 30,
          controller: FixedExtentScrollController(),
          physics: FixedExtentScrollPhysics(),
          onSelectedItemChanged: (int index) => setState(() => _selected =
              (-index) % (widget.timeUnitMax ~/ widget.timeUnitSteps)),
          childDelegate: ListWheelChildBuilderDelegate(
              builder: (BuildContext context, int index) {
                index = (-index) % (widget.timeUnitMax ~/ widget.timeUnitSteps);
                return Center(
                  child: AnimatedOpacity(
                    opacity: index == _selected ? 1 : 0.3,
                    duration: Duration(milliseconds: 200),
                    child: AnimatedScale(
                      scale: index == _selected ? 1 : 0.7,
                      duration: Duration(milliseconds: 200),
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
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(widget.timeUnit,
                style: Theme.of(context).textTheme.caption)),
      )
    ]);
  }
}
