import 'package:flutter/material.dart';

class DownloadIndicator extends StatefulWidget {
  final bool active;

  const DownloadIndicator({
    required this.active,
    super.key,
  });

  @override
  State<DownloadIndicator> createState() => _DownloadIndicatorState();
}

class _DownloadIndicatorState extends State<DownloadIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ).drive(Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.1),
    ));
    _triggerBounce();
  }

  @override
  void didUpdateWidget(covariant DownloadIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _triggerBounce();
  }

  void _triggerBounce() {
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.active ? 1 : 0,
      onEnd: () {
        if (!widget.active) _controller.reset();
      },
      duration: const Duration(milliseconds: 500),
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          Theme.of(context).brightness == Brightness.dark
            ? Colors.black45
            : Colors.black26,
          BlendMode.srcOut,
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          // required hack to make ColorFilter work for the entire container
          // because if it is fully transparent it is only applied to the Icon painting rect
          // might be related to https://github.com/flutter/flutter/pull/72526#issuecomment-749185938
          color: const Color.fromARGB(1, 255, 255, 255),
          padding: const EdgeInsets.all(40),
          child: FittedBox(
            alignment: const Alignment(0, -0.75),
            child: SlideTransition(
              position: _animation,
              child: const Icon(
                Icons.cloud_download_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
