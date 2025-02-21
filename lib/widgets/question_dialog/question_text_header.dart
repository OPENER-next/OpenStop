import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

import '/l10n/app_localizations.g.dart';
import '/widgets/edge_feather.dart';
import '/widgets/gallery_viewer.dart';

class QuestionTextHeader extends StatefulWidget {
  final String question;

  final String details;

  final List<String> images;

  const QuestionTextHeader({
    required this.question,
    required this.details,
    this.images = const [],
    super.key
  });

  @override
  State<QuestionTextHeader> createState() => _QuestionTextHeaderState();
}

class _QuestionTextHeaderState extends State<QuestionTextHeader> with SingleTickerProviderStateMixin {
  bool _selected = false;

  late final AnimationController _animationController;

  late final CurvedAnimation _sizeAnimation;

  late final CurvedAnimation _fadeAnimation;

  late Animation<Color?> _fillColorAnimation;

  late Animation<Color?>_iconColorAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      reverseDuration: const Duration(milliseconds: 500)
    );

    _sizeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubicEmphasized,
      reverseCurve: Curves.easeInCubic
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0, 0.5),
      reverseCurve: const Interval(0.5, 1)
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _fillColorAnimation = ColorTween(
      begin: Theme.of(context).colorScheme.primary.withValues(alpha: 0.0),
      end: Theme.of(context).colorScheme.primary
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.3),
        reverseCurve: const Interval(0.5, 1)
      )
    );

    _iconColorAnimation = ColorTween(
      begin: Theme.of(context).colorScheme.primary,
      end: Theme.of(context).colorScheme.onPrimary
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.3),
        reverseCurve: const Interval(0.5, 1)
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = EdgeInsets.symmetric(horizontal: 20);
    final appLocale = AppLocalizations.of(context)!;
    final hasAdditionalInfo = widget.details.isNotEmpty || widget.images.isNotEmpty;

    return Semantics(
      label: appLocale.semanticsQuestionSentence,
      hint: widget.details,
      blockUserActions: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: !hasAdditionalInfo ? null : () {
          _selected = !_selected;
          if (_selected) {
            _animationController.forward();
          }
          else {
            _animationController.reverse();
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(
            top: 25,
            bottom: 20,
          ),
          child: Column(
            children: [
              Padding(
                padding: horizontalPadding,
                  child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.question,
                        style: const TextStyle(
                          height: 1.3,
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    if (hasAdditionalInfo) ExcludeSemantics(
                      child: AnimatedBuilder(
                        animation: _fillColorAnimation,
                        builder: (context, child) {
                          return Container(
                            margin: const EdgeInsets.only(left: 10),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _fillColorAnimation.value,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            child: Icon(
                              MdiIcons.informationVariant,
                              color: _iconColorAnimation.value,
                            ),
                          );
                        },
                      ),
                    ),
                  ]
                ),
              ),
              if (hasAdditionalInfo) ExcludeSemantics(
                child: SizeTransition(
                  axisAlignment: -1,
                  sizeFactor: _sizeAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.details.isNotEmpty) Padding(
                            padding: widget.images.isNotEmpty
                              ? horizontalPadding + const EdgeInsets.only(bottom: 10)
                              : horizontalPadding,
                            child: Text(
                              widget.details,
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (widget.images.isNotEmpty) ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxHeight: 90
                            ),
                            child: EdgeFeather(
                              edges: horizontalPadding,
                              child: GalleryViewer(
                                images: widget.images
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
