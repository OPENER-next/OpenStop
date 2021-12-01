import 'dart:math';

import 'package:flutter/material.dart';


class QuestionList extends StatefulWidget {
  final List<QuestionListEntry> children;

  final int index;

  const QuestionList({
    Key? key,
    required this.children,
    this.index = -1,
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
      _keys.forEach((childKey) {
        _sizes.add(childKey.currentContext?.size ?? Size.zero);
      });
    });
  }


  double _calcTotalHeight() {
    double totalHeight = 0;
    _sizes.forEach((size) => totalHeight += size.height);
    return totalHeight;
  }


  double _calcBottomOffset() {
    double offsetBottom = 0;
    for (var i = 0; i < min(widget.index, _sizes.length); i++) {
      offsetBottom -= _sizes[i].height;
    }
    return offsetBottom;
  }


  @override
  Widget build(BuildContext context) {
    var totalHeight = _calcTotalHeight();
    var accumulatedOffset = 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedPositioned(
              top: _calcBottomOffset(),
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

                    var isOffstage = true;

                    if (index < _sizes.length) {
                      accumulatedOffset += _sizes[index].height;
                      isOffstage = false;
                    }

                    return Positioned(
                      bottom: offsetBottom,
                      left: 0,
                      right: 0,
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

  QuestionListEntry({
    required Key key,
    required this.child
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return child;
  }
}