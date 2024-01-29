import 'package:flutter/material.dart';

class GalleryViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const GalleryViewer({required this.images, this.initialIndex = 0, super.key });

  @override
  State<GalleryViewer> createState() => _GalleryViewerState();
}

class _GalleryViewerState extends State<GalleryViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  void goToPreviousImage() {
    setState(() {
      _currentIndex = (_currentIndex - 1).clamp(0, widget.images.length - 1);
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void goToNextImage() {
    setState(() {
      _currentIndex = (_currentIndex + 1).clamp(0, widget.images.length - 1);
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [ 
        PageView.builder(
          itemCount: widget.images.length,
          controller: _pageController,
          scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          allowImplicitScrolling: true,   
          itemBuilder: (context, index) {
            return Image.asset(
              widget.images[index],
              errorBuilder: (context, _, __) {
                return Image.asset(
                  'assets/images/placeholder_image.png',
                );
              },
            );
          }
        ),
        Positioned(
          left: 0,
          child: IconButton(
            disabledColor: Colors.transparent,
            icon: const Icon(Icons.arrow_circle_left),
            onPressed: _currentIndex > 0 ? goToPreviousImage : null,
          ),
        ),
        Positioned(
          right: 0,
          child: IconButton(
            disabledColor: Colors.transparent,
            icon: const Icon(Icons.arrow_circle_right),
            onPressed: _currentIndex < widget.images.length - 1 ? goToNextImage : null,
          ),
        ),
      ],
    );
  }
}
