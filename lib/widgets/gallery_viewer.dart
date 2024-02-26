import 'dart:ui';

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

class _GalleryNavigatorState extends State<GalleryNavigator>{
  bool _pagingEnabled = true;
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
    final events = [];
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.deferToChild,
            onPointerDown: (event) {
              events.add(event.pointer);
              if (events.length >= 2) {
                setState(() { _pagingEnabled = false; });
              }
            },
            onPointerUp: (event) {
              events.clear();
              setState(() { _pagingEnabled = true; });
            },
            child: PageView.custom(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              physics: _pagingEnabled ? const PageScrollPhysics() : const NeverScrollableScrollPhysics(),
              childrenDelegate: SliverChildBuilderDelegate(
                (context, index) {
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
              addAutomaticKeepAlives: false,
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

class DerivedAnimation<T extends ChangeNotifier,V> extends Animation<V> {
  final T _notifier;
  final V Function(T) _transformer;

  DerivedAnimation({
    required T notifier,
    required V Function(T) transformer,
  }) : 
  _notifier = notifier,
  _transformer = transformer;

  @override
  void addListener(VoidCallback listener) {
    _notifier.addListener(listener);
  }

  @override
  void addStatusListener(AnimationStatusListener listener) {
    // status will never change.
  }

  @override
  void removeListener(VoidCallback listener) {
    _notifier.removeListener(listener);
  }

  @override
  void removeStatusListener(AnimationStatusListener listener) {
    // status will never change.
  }

  @override
  AnimationStatus get status => AnimationStatus.forward;

  @override
  V get value => _transformer.call(_notifier);
}
