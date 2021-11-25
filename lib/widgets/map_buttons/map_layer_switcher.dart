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


class _MapLayerSwitcherState extends State<MapLayerSwitcher> with SingleTickerProviderStateMixin {
  late double _animationLengthScale, _intervalLength, _overlapLength, _intervalOffset;

  var _isActive = false;

  late final AnimationController _controller = AnimationController(vsync: this);

  late final OverlayEntry _overlayEntry = _buildOverlayEntry();


  // pre calculate necessary variables
  void _setup() {
    // calculate animation scale factor based on overlap value and number of entries
    _animationLengthScale = 1 + ((1 - widget.animationOverlap) * (widget.entries.length - 1));

    // the length of one sub interval in a total interval from 0 to 1
    _intervalLength = 1 / _animationLengthScale;

    // the length of one overlap in a sub interval
    _overlapLength = _intervalLength * widget.animationOverlap;

    // the non-overlapping length of one sub interval
    _intervalOffset = _intervalLength - _overlapLength;

    // stretch length by amount of items minus the animation overlap
    _controller.duration = widget.duration * _animationLengthScale;
    _controller.reverseDuration = widget.reverseDuration * _animationLengthScale;
  }


  @override
  void initState() {
    super.initState();

    _setup();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.forward || status == AnimationStatus.reverse) {
        setState(() {
          _isActive = status == AnimationStatus.forward;
        });
      }

      if (status == AnimationStatus.dismissed) {
        // remove overlay / hide speed dial buttons
        _overlayEntry.remove();
      }
    });
  }


  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    _setup();

    WidgetsBinding.instance!.addPostFrameCallback(
      (_) => _overlayEntry.markNeedsBuild()
    );
  }


  OverlayEntry _buildOverlayEntry() {
    return OverlayEntry(
      builder: (overlayContext) {
        final renderBox = context.findRenderObject() as RenderBox;
        final size = renderBox.size;
        final offset = renderBox.localToGlobal(Offset.zero);

        return Positioned(
          left: offset.dx,
          bottom: MediaQuery.of(context).size.height - offset.dy - size.height + MediaQuery.of(context).padding.bottom,
          width: MediaQuery.of(context).size.width - offset.dx,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.entries.length, _buildItem),
          )
        );
      }
    );
  }


  Widget _buildItem(int index) {
    final entry = widget.entries[index];
    final start = (widget.entries.length - (index + 1)) * _intervalOffset;
    final end = start + _intervalLength;

    return Container(
      height: 50,
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _controller,
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
              parent: _controller,
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
              child: Text(
                entry.label,
                style: Theme.of(context).textTheme.bodyText2
              )
            )
          )
        ]
      )
    );
  }


  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      child: _isActive
        ? Icon(
          Icons.layers_clear_rounded,
          color: Colors.black,
        )
        : Icon(
          Icons.layers_rounded,
          color: Colors.black,
        ),
      onPressed: () {
        if (_controller.isDismissed) {
          Overlay.of(context)!.insert(_overlayEntry);
          _controller.forward();
        }
        else {
          _controller.reverse();
        }
      },
    );
  }


  @override
  void dispose() {
    _controller.dispose();

    // this is required since the widget might be unmounted in a later frame
    _overlayEntry.addListener(() {
      if (!_overlayEntry.mounted) {
        _overlayEntry.dispose();
      }
    });

    super.dispose();
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