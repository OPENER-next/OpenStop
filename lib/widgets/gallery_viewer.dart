import 'package:flutter/material.dart';
import '/commons/themes.dart';
import '/widgets/hero_viewer.dart';
import '/widgets/derived_animation.dart';

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

class _GalleryNavigatorState extends State<GalleryNavigator>{
  int _pointerCount = 0;

  late final PageController _pageController;
  late final DerivedAnimation<PageController, double> _rightAnimation ;
  late final DerivedAnimation<PageController, double> _leftAnimation;

  final List<TransformationController> _transformationControllers = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _leftAnimation = DerivedAnimation<PageController, double>(notifier: _pageController, transformer: (controller) {
      return fractionalIndex.clamp(0, 1).toDouble();
    });
    _rightAnimation = DerivedAnimation<PageController, double>(notifier: _pageController, transformer: (controller) {
      final lastIndex = widget.images.length - 1;
      return (lastIndex - fractionalIndex.clamp(lastIndex - 1, lastIndex)).toDouble();
    });
    _pageController.addListener(() {
      if (fractionalIndex == index) {
        // reset invisible controllers
        for (int i = 0; i < index; i++) {
          _transformationControllers[i].value.setIdentity();
        }
        for (int i = index + 1; i < _transformationControllers.length; i++) {
          _transformationControllers[i].value.setIdentity();
        }
      }
    });
    _processTransformationControllers();
  }

  @override
  void didUpdateWidget(covariant GalleryNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _processTransformationControllers();
  }

  void _processTransformationControllers() {
    int diff = widget.images.length - _transformationControllers.length;
    for (; diff > 0; diff--) {
      _transformationControllers.add(TransformationController());
    }
    for (; diff < 0; diff++) {
      final controller = _transformationControllers.removeLast();
      controller.dispose();
    }
  }

  num get fractionalIndex => _pageController.hasClients && _pageController.page != null
    ? _pageController.page!
    : _pageController.initialPage;

  int get index => fractionalIndex.round();

  bool get pagingDisabled =>
    _pointerCount > 1  || _transformationControllers[index].value.getMaxScaleOnAxis() > 1;

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
    for (final controller in _transformationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          // Workaround for scale and drag interference. See:
          // https://github.com/flutter/flutter/issues/137189
          // https://github.com/flutter/flutter/issues/68594
          // https://github.com/flutter/flutter/issues/65006
          child: Listener(
            behavior: HitTestBehavior.deferToChild,
            onPointerDown: (event) {
              setState(() => _pointerCount++ );
            },
            onPointerUp: (event) {
              setState(() => _pointerCount-- );
            },
            child: PageView.custom(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              // required to prevent panning when the user actually wants to pinch zoom
              // paging is also disabled when the image is scaled/zoomed in
              physics: pagingDisabled
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),
                onPageChanged: (value) {
                  setState(() {
                    // used to trigger a rebuild because pagingDisabled can change
                    // when the index changes (e.g. on arrow tap)
                  });
                },
              childrenDelegate: SliverChildBuilderDelegate((context, index) {
                return InteractiveViewer(
                  transformationController: _transformationControllers[index],
                  maxScale: 3,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Hero(
                      tag: widget.imagesKeys[index],
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
              // This will dispose images/widgets that are out of view
              // Necessary so only get Hero animations for visible images
              addAutomaticKeepAlives: false,
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          child: SafeArea(
            child: FadeTransition(
              opacity: _leftAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-1.0, 0.0),
                  end: Offset.zero,
                ).animate(_leftAnimation),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: goToPreviousImage,
                  color: Theme.of(context).colorScheme.onPrimary,
                  icon: Icon(
                    Icons.navigate_before_rounded,
                    size: 40.0,
                    shadows: [
                      Shadow(color: Theme.of(context).colorScheme.shadow, blurRadius: 25),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          child: SafeArea(
            child: FadeTransition(
              opacity: _rightAnimation,
              child: SlideTransition(
              position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(_rightAnimation),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: goToNextImage,
                  color: Theme.of(context).colorScheme.onPrimary,
                  icon: Icon(
                    Icons.navigate_next_rounded,
                    size: 40.0,
                    shadows: [
                      Shadow(color: Theme.of(context).colorScheme.shadow, blurRadius: 25),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
