import 'package:flutter/material.dart';

class MapLayerSwitcher<T> extends StatefulWidget {
  /// A callback function that gets
  final void Function(T id) onSelection;

  final List<MapLayerSwitcherEntry<T>> entries;

  final T active;

  /// Show animation duration of a single entry.
  final Duration duration;

  /// Hide animation duration of a single entry.
  final Duration reverseDuration;

  /// A Number from 0 (no overlap) to 1 (full overlap) defining the overlap of the entry animations.
  final double animationOverlap;

  /// The dimensions of the speed dial buttons.
  final Size subButtonSize;

  const MapLayerSwitcher({
    required this.onSelection,
    required this.entries,
    required this.active,
    this.duration = const Duration(milliseconds: 500),
    this.reverseDuration = const Duration(milliseconds: 300),
    this.animationOverlap = 0.8,
    this.subButtonSize = const Size.square(42),
    Key? key,
  }) : super(key: key);

  @override
  State createState() => _MapLayerSwitcherState<T>();
}


class _MapLayerSwitcherState<T> extends State<MapLayerSwitcher<T>> with SingleTickerProviderStateMixin {
  late double _animationLengthScale, _intervalLength, _overlapLength, _intervalOffset;

  var _isActive = false;

  final _layerLink = LayerLink();

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

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _overlayEntry.markNeedsBuild()
    );
  }


  OverlayEntry _buildOverlayEntry() {
    return OverlayEntry(
      builder: (overlayContext) {
        return CompositedTransformFollower(
          link: _layerLink,
          followerAnchor: Alignment.bottomLeft,
          targetAnchor: Alignment.topCenter,
          // shift column so the buttons are perfectly centered
          offset: Offset(-widget.subButtonSize.width / 2, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            // pass the overlay context so the OverlayEntry automatically rebuilds
            // when any inherit widget changes to which a widget in the builder may have subscribed to
            children: List.generate(
              widget.entries.length,
              (i) => _buildItem(i, overlayContext)
            )
          ),
        );
      }
    );
  }


  Widget _buildItem(int index, BuildContext context) {
    final entry = widget.entries[index];
    final start = (widget.entries.length - (index + 1)) * _intervalOffset;
    final end = start + _intervalLength;
    final isActive = widget.active == entry.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
            child: SizedBox.fromSize(
              size: widget.subButtonSize,
              child: FloatingActionButton.small(
                heroTag: null,
                backgroundColor: isActive ? Theme.of(context).colorScheme.primary : null,
                child: Icon(
                  entry.icon,
                  color: isActive ? Theme.of(context).colorScheme.onPrimary : null,
                ),
                onPressed: () {
                  if (widget.active != entry.id) {
                    widget.onSelection(entry.id);
                  }
                },
              ),
            )
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
              margin: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(3),
                boxShadow: kElevationToShadow[4]
              ),
              padding: const EdgeInsets.all(5),
              child: Text(
                entry.label,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: isActive ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onPrimaryContainer
                )
              )
            )
          )
        ]
      )
    );
  }


  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: FloatingActionButton.small(
        heroTag: null,
        child: _isActive
            ? const Icon(
          Icons.layers_clear_rounded,
        )
            : const Icon(
          Icons.layers_rounded,
        ),
        onPressed: () {
          if (_controller.isDismissed) {
            Overlay.of(context)?.insert(_overlayEntry);
            _controller.forward();
          }
          else {
            _controller.reverse();
          }
        },
      ),
    );
  }


  @override
  void dispose() {
    _controller.dispose();

    if (_overlayEntry.mounted) {
      _overlayEntry.remove();
    }
    _overlayEntry.dispose();

    super.dispose();
  }
}


class MapLayerSwitcherEntry<T> {
  final T id;

  final IconData icon;

  final String label;

  const MapLayerSwitcherEntry({
    required this.id,
    required this.icon,
    required this.label,
  });
}
