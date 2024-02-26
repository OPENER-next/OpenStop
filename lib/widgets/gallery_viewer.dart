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
  bool _pagingEnabled = true;
  int _pointerCount = 0;
  late final PageController _pageController;
  late final DerivedAnimation<PageController, double> _rightAnimation ;
  late final DerivedAnimation<PageController, double> _leftAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _leftAnimation = DerivedAnimation<PageController, double>(notifier: _pageController, transformer: (controller) {
      if (controller.hasClients && controller.page != null) {
        return controller.page!.clamp(0,1);
      } 
      else if (controller.initialPage == 0) {
        return 0.0;
      }
      else {
        return 1.0;
      }
    });
    _rightAnimation = DerivedAnimation<PageController, double>(notifier: _pageController, transformer: (controller) {
      if (controller.hasClients && controller.page != null) {
        final penultimate = widget.images.length - 2;
        return (controller.page!.clamp(penultimate, widget.images.length -1) - penultimate).toDouble();
      }
      if (controller.initialPage < widget.images.length - 1 && widget.images.length > 1) {
        return 0.0;
      }
      else {
        return 1.0;
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.deferToChild,
            onPointerDown: (event) {
              _pointerCount++;
              if (_pointerCount >= 2) {
                setState(() { _pagingEnabled = false; });
              }
            },
            onPointerUp: (event) {
              _pointerCount = 0;
              setState(() { _pagingEnabled = true; });
            },
            child: PageView.custom(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              physics: _pagingEnabled ? const PageScrollPhysics() : const NeverScrollableScrollPhysics(),
              childrenDelegate: SliverChildBuilderDelegate((context, index) {
                return  InteractiveViewer(
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
              addAutomaticKeepAlives: false, //Necessary to guarantee only the Hero animation execute for the last viewed image
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          child: SafeArea(
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(_leftAnimation),
              child: IconButton(
                onPressed: goToPreviousImage,
                color: Theme.of(context).colorScheme.primary,
                icon: const Icon(Icons.arrow_circle_left, size: 30.0),
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          child: SafeArea(
            child: SlideTransition(
            position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(1.0, 0.0),
              ).animate(_rightAnimation),
              child: IconButton(
                onPressed: goToNextImage,
                color: Theme.of(context).colorScheme.primary,
                icon: const Icon(Icons.arrow_circle_right, size: 30.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
