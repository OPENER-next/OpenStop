import 'package:flutter/material.dart';
import '/commons/themes.dart';
import '/widgets/hero_viewer.dart';

class GalleryViewer extends StatelessWidget {

  final List<String> images;

  const GalleryViewer({required this.images, super.key });

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = EdgeInsets.symmetric(horizontal: 20);
    final List<UniqueKey> imagesKeys = List.generate(images.length, (index) => UniqueKey());

    return ListView.separated(
      padding: horizontalPadding,
      clipBehavior: Clip.none,
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: images.length,
      separatorBuilder: (context, index) => const SizedBox(width: 10),
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(Default.borderRadius),
          // hero viewer cannot be used in frame builder
          // because the builder may be called after the page route transition starts
          child: HeroViewer(
            pageBuilder: (BuildContext context, Widget child){
              return ColoredBox(
                color: Theme.of(context).colorScheme.background,
                child: GalleryNavigator(
                  images: images,
                  imagesKeys: imagesKeys,
                  initialIndex: index,
                ),
              );
            },
            tag: imagesKeys[index],
            child: Image.asset(
              images[index],
              errorBuilder: (context, _, __) {
                return Image.asset(
                  'assets/images/placeholder_image.png',
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class GalleryNavigator extends StatefulWidget {
  final List<String> images;
  final List<UniqueKey> imagesKeys;
  final int initialIndex;

  const GalleryNavigator({
    required this.images,
    required this.imagesKeys,
    this.initialIndex = 0, 
    super.key,}
  );

  @override
  State<GalleryNavigator> createState() => _GalleryNavigatorState();
}

class _GalleryNavigatorState extends State<GalleryNavigator> with TickerProviderStateMixin {
  bool _isZooming = false;
  int _currentPageIndex = 0;
  int _previousPageIndex = 0;
  bool reverseLeft = false;
  bool reverseRight = true;
  late final PageController _pageController;
  late final AnimationController _leftArrow = AnimationController(
    vsync: this, 
    lowerBound : -1.0,
    duration: const Duration(milliseconds: 300));
  late final Animation<Offset> _leftAnimation = Tween<Offset>(
    begin: const Offset(-1.0, 0.0),
    end: Offset.zero)
    .animate(_leftArrow);
  late final AnimationController _rightArrow = AnimationController(
    vsync: this, 
    duration: const Duration(milliseconds: 300));
  late final Animation<Offset> _rightAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(1.0, 0.0))
    .animate(_rightArrow);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _pageController.addListener(_animateArrows);
    if (widget.initialIndex == 0) {
      _leftArrow.value = -1.0;
      _leftArrow.reverse();
    }
    else {
      _leftArrow.value = 0.0;
      _leftArrow.forward();
    }
    if (widget.initialIndex < widget.images.length - 1 && widget.images.length > 1) {
      _rightArrow.value = 0.0;
      _rightArrow.reverse();
    }
    else {
      _rightArrow.value = 1.0;
      _rightArrow.forward();
    }
  }

  bool get hasPrevious {
    if (_pageController.hasClients && _pageController.page != null) {
      return _pageController.page!.round() > 0;
    }
    else if (_pageController.initialPage > 0) {
      return true;
    } 
    else {
      return false;
    }
  }

  bool get hasNext {
    if (_pageController.hasClients && _pageController.page != null) {
      return _pageController.page!.round() < widget.images.length - 1;
    }
    else if (_pageController.initialPage < widget.images.length - 1) {
      return true;
    }
    else {
      return false;
    }
  }

  void _animateArrows() {
    if (_pageController.hasClients && _pageController.page != null) {
      _previousPageIndex = _currentPageIndex;
      _currentPageIndex = _pageController.page!.round();
      print('_previousPageIndex ' +  _previousPageIndex.toString() + '_currentPageIndex ' + _currentPageIndex.toString());
      handleLeftArrow();
      handleRightArrow();
    }
  }

  void handleLeftArrow() {
    double newValue = 0.0;
    if (_pageController.page! > 0.0 && _pageController.page! < 1.0){
      newValue = double.parse((-1.00 + _pageController.page!).toStringAsFixed(2));
      if (newValue == -0.00) {
        newValue = 0.0;
      }
      _leftArrow.reset();
      _leftArrow.value = newValue;
      if (_previousPageIndex > _currentPageIndex) {
        reverseLeft = true;
        _leftArrow.reverse();
      }
      else if (_previousPageIndex < _currentPageIndex){
        reverseLeft = false;
        _leftArrow.forward();
      }
      else {
        if (reverseLeft == true) {
          _leftArrow.reverse();
        }
        else {
          _leftArrow.forward();
        }
      }
    }
  }

  void handleRightArrow() {
    double newValue = 0.0;
    if (_pageController.page! >  widget.images.length - 2 && widget.images.length > 1){
      newValue = double.parse((0.00 + (_pageController.page! - _pageController.page!.floor())).toStringAsFixed(2));
      _rightArrow.reset();
      _rightArrow.value = newValue;
      if (_previousPageIndex > _currentPageIndex) {
        reverseRight = true;
        _rightArrow.reverse();
      }
      else if (_previousPageIndex < _currentPageIndex){
        reverseRight = false;
        _rightArrow.forward();
      }
      else {
        if (reverseRight == true) {
          _rightArrow.reverse();
        }
        else {
          _rightArrow.forward();
        }
      }
    }
  }

  void goToPreviousImage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  void goToNextImage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (details.pointerCount == 2) {
      _isZooming = true;
    }
    else {
      _isZooming = false;
    }
    setState(() {});
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    setState(() {
      _isZooming = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: PageView.custom(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            physics: _isZooming ? const NeverScrollableScrollPhysics() : null,   
            childrenDelegate: SliverChildBuilderDelegate(
              (context, index) {
              return   InteractiveViewer(
                onInteractionStart: _handleScaleStart,
                onInteractionEnd: _handleScaleEnd,
                maxScale: 3,
                child: FittedBox(
                fit: BoxFit.contain,
                  child: Hero(
                    tag:  widget.imagesKeys[index],
                    child: Image.asset(
                      widget.images[index],
                      errorBuilder: (context, _, __) {
                        return Image.asset(
                          'assets/images/placeholder_image.png',
                        );
                      },
                    ),
                  ),
                ),
              );
            },
            childCount: widget.images.length,
            addAutomaticKeepAlives: false,
            ),
          ),
        ),
        Positioned(
          left: 0,
          child: SafeArea(
            child: AnimatedBuilder(
              animation: _leftArrow,
              builder: (BuildContext context, _) {
                return SlideTransition(
                  position: _leftAnimation,
                  child:  IconButton(
                    onPressed: hasPrevious ? goToPreviousImage : null,
                    color: Theme.of(context).colorScheme.primary,
                    icon: const Icon(Icons.arrow_circle_left, size: 30.0),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          right: 0,
          child: SafeArea(
            child: AnimatedBuilder(
              animation: _rightArrow,
              builder: (BuildContext context, _) {
                return SlideTransition(
                  position: _rightAnimation,
                  child: IconButton(
                    onPressed: hasNext ? goToNextImage : null,
                    color: Theme.of(context).colorScheme.primary,
                    icon: const Icon(Icons.arrow_circle_right, size: 30.0),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
