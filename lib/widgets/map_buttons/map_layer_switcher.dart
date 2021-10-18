import 'package:flutter/material.dart';

class MapLayerSwitcher extends StatefulWidget {
  /// A callback function that gets
  final Function(MapLayerSwitcherEntry entry) onSelection;

  final List<MapLayerSwitcherEntry> entries;

  final String active;

  /// Show animation duration of a single entry.
  final Duration duration;

  /// Hide animation duration of a single entry.
  final Duration reverseDuration;

  /// A Number from 0 (no overlap) to 1 (full overlap) defining the overlap of the entry animations.
  final double animationOverlap;

  const MapLayerSwitcher({
    required this.onSelection,
    required this.entries,
    required this.active,
    this.duration = const Duration(milliseconds: 500),
    this.reverseDuration = const Duration(milliseconds: 300),
    this.animationOverlap = 0.8,
  });

  @override
  State createState() => new _MapLayerSwitcherState();
}

class _MapLayerSwitcherState extends State<MapLayerSwitcher> with TickerProviderStateMixin {
  late double animationLengthScale, intervalLength, overlapLength, intervalOffset;

  late final AnimationController controller = AnimationController(vsync: this);

  late final isActive = ValueNotifier(false);

  // pre calculate necessary variables
  _setup() {
    // calculate animation scale factor based on overlap value and number of entries
    animationLengthScale = 1 + ((1 - widget.animationOverlap) * (widget.entries.length - 1));

    // the length of one sub interval in a total interval from 0 to 1
    intervalLength = 1 / animationLengthScale;

    // the length of one overlap in a sub interval
    overlapLength = intervalLength * widget.animationOverlap;

    // the non-overlapping length of one sub interval
    intervalOffset = intervalLength - overlapLength;

    // stretch length by amount of items minus the animation overlap
    controller.duration = widget.duration * animationLengthScale;
    controller.reverseDuration = widget.reverseDuration * animationLengthScale;
  }

  @override
  void initState() {
    super.initState();

    _setup();

    controller.addStatusListener((status) {
      if (status == AnimationStatus.forward || status == AnimationStatus.reverse) {
        isActive.value = status == AnimationStatus.forward;
      }

      if (status == AnimationStatus.dismissed) {
        // trigger rebuild to hide speed dial buttons
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    _setup();
  }

  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // hide speed dial buttons when dismissed
        if (!controller.isDismissed) ...List.generate(widget.entries.length, (index) {
          final entry = widget.entries[index];
          final start = (widget.entries.length - (index + 1)) * intervalOffset;
          final end = start + intervalLength;

          return Container(
            height: 50,
            padding: EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                ScaleTransition(
                  scale: CurvedAnimation(
                    parent: controller,
                    curve: Interval(
                      start,
                      end,
                      curve: Curves.elasticOut
                    ),
                    reverseCurve: Interval(
                      start,
                      end,
                      curve: Curves.easeOutBack,
                    ),
                  ),
                  child: FloatingActionButton(
                    backgroundColor: widget.active == entry.key ? Theme.of(context).colorScheme.primary : null,
                    mini: true,
                    child: Icon(
                      entry.icon,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      if (widget.active != entry.key) {
                        widget.onSelection(entry);
                      }
                    },
                  ),
                ),
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: controller,
                    curve: Interval(
                      start,
                      end,
                      curve: Curves.ease
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.only(left: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: kElevationToShadow[4]
                    ),
                    padding: EdgeInsets.all(5),
                    child: Text(entry.label)
                  )
                )
              ]
            )
          );
        }),
        FloatingActionButton.small(
          child: ValueListenableBuilder<bool>(
            valueListenable: isActive,
            builder: (context, isActive, child) {
              return isActive
                ? Icon(
                  Icons.layers_clear_rounded,
                  color: Colors.black,
                )
                : Icon(
                  Icons.layers_rounded,
                  color: Colors.black,
                );
            }
          ),
          onPressed: () {
            // trigger rebuild to add speed dial buttons to widget tree
            if (controller.isDismissed) {
              setState(() {
                controller.forward();
              });
            }
            else {
              controller.reverse();
            }
          },
        )
      ]
    );
  }


  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    isActive.dispose();
  }
}


class MapLayerSwitcherEntry {
  final String key;

  final IconData icon;

  final String label;

  const MapLayerSwitcherEntry({
    required this.key,
    required this.icon,
    required this.label,
  });
}