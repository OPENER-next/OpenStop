import 'dart:math';

import 'package:flutter/material.dart';


class QuestionList extends StatefulWidget {
  final List<QuestionListEntry> children;

  final int index;

  const QuestionList({
    required this.children,
    this.index = -1,
    Key? key
  }) : super(key: key);

  @override
  State<QuestionList> createState() => _QuestionListState();
}


class _QuestionListState extends State<QuestionList> {
  final _keys = <GlobalKey>[];
  final _sizes = <Size>[];

  @override
  void initState() {
    super.initState();
    _update();
  }

  @override
  void didUpdateWidget(covariant QuestionList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _update(oldWidget);
  }


  void _update([covariant QuestionList? oldWidget]) {
    // NOTE: This might not be bullet proof when entries are removed or added in between

    final difference = _keys.length - widget.children.length;

    // add additional global keys for new children or remove obsolete global keys

    if (difference < 0) {
      for (int i = 0; i > difference; i--) {
        _keys.add(GlobalKey());
      }
    }
    else if (difference > 0) {
      for (int i = 0; i < difference; i++) {
        _keys.removeAt(_keys.length - 1);
      }
    }

    // refresh sizes after build
    WidgetsBinding.instance?.addPostFrameCallback((_) => _refreshSizesCache());
  }


  void _refreshSizesCache() {
    setState(() {
      _sizes.clear();
      for (final childKey in _keys) {
        _sizes.add(childKey.currentContext?.size ?? Size.zero);
      }
    });
  }


  double _calcTotalHeight() {
    double totalHeight = 0;
    for (final size in _sizes) {
      totalHeight += size.height;
    }
    return totalHeight;
  }


  double _calcTopOffset() {
    double offsetBottom = 0;
    final max = min(widget.index + 1, _sizes.length);

    for (var i = 1; i < max; i++) {
      offsetBottom -= _sizes[i].height;
    }
    return offsetBottom;
  }


  @override
  Widget build(BuildContext context) {
    final totalHeight = _calcTotalHeight();
    var accumulatedOffset = 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedPositioned(
              top: _calcTopOffset(),
              left: 0,
              right: 0,
              curve: Curves.easeInOutCubicEmphasized,
              duration: const Duration(milliseconds: 500),
              child: ConstrainedBox(
                // required, otherwise the stack will throw an error due to infinite height
                constraints: BoxConstraints.expand(
                  height: totalHeight + constraints.biggest.height
                ),
                child: Stack(
                  children: List.generate(widget.children.length, (index) {
                    final isActive = index == widget.index;
                    final offsetBottom = totalHeight - accumulatedOffset;
                    // all items that currently do not have a size
                    final isOffstage = index >= _sizes.length;

                    final nextIndex = index + 1;
                    if (nextIndex < _sizes.length) {
                      accumulatedOffset += _sizes[nextIndex].height;
                    }

                    return Positioned(
                      bottom: offsetBottom,
                      left: 0,
                      right: 0,
                      // layout new items but hide them for the first frame so we can get the height after wards
                      child: Offstage(
                        offstage: isOffstage,
                        child: IgnorePointer(
                          ignoring: !isActive,
                          child: AnimatedOpacity(
                            opacity: isActive ? 1 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: ConstrainedBox(
                              constraints: constraints,
                              child: KeyedSubtree(
                                key: _keys[index],
                                child: widget.children[index],
                              ),
                            )
                          )
                        )
                      )
                    );
                  }, growable: false)
                )
              ),
            )
          ]
        );
      }
    );
  }


  @override
  void dispose() {
    super.dispose();
  }
}


class QuestionListEntry extends StatelessWidget {
  final Widget child;

  const QuestionListEntry({
    required Key key,
    required this.child
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return child;
  }
}
