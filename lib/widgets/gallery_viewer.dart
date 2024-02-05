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
    super.key,  }
  );

  @override
  State<GalleryNavigator> createState() => _GalleryNavigatorState();
}

class _GalleryNavigatorState extends State<GalleryNavigator> {
  late PageController _pageController;
  late Object tag;

  @override
  void initState() {
    super.initState();
    tag = widget.imagesKeys[widget.initialIndex];
    _pageController = PageController(initialPage: widget.initialIndex);
    _pageController.addListener(handlePageChange);
  }

  void handlePageChange() {
      tag = widget.imagesKeys[_pageController.page!.round()];
      setState(() {});
  }

  void goToPreviousImage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void goToNextImage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
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
          child: Hero(
            tag: tag,
            child: PageView.builder(
              itemCount: widget.images.length,
              controller: _pageController,
              scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              allowImplicitScrolling: true,   
              itemBuilder: (context, index) {
                return  InteractiveViewer(
                  maxScale: 3,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Image.asset(
                      widget.images[index],
                      errorBuilder: (context, _, __) {
                        return Image.asset(
                          'assets/images/placeholder_image.png',
                        );
                      },
                    ),
                  ),
                );
              }
            ),
          ),
        ),
        Positioned(
          left: 0,
          child: SafeArea(
            child: IconButton(
              onPressed: _pageController.hasClients && _pageController.page != null ? _pageController.page! > 0 ? goToPreviousImage : null
              : _pageController.initialPage > 0 ? goToPreviousImage : null,
              color: Theme.of(context).colorScheme.primary,
              disabledColor: Colors.transparent,
              icon: const Icon( Icons.arrow_circle_left, size: 30.0),
            ),
          ),
        ),
        Positioned(
          right: 0,
          child: SafeArea(
            child: IconButton(
              onPressed: _pageController.hasClients && _pageController.page != null ? _pageController.page! < widget.images.length - 1 ? goToNextImage : null
              : _pageController.initialPage < widget.images.length - 1 ? goToNextImage : null,
              color: Theme.of(context).colorScheme.primary,
              disabledColor: Colors.transparent,
              icon: const Icon( Icons.arrow_circle_right, size: 30.0),
            ),
          ),
        ),
      ],
    );
  }
}
