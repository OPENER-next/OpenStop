import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '/l10n/app_localizations.g.dart';

class AttributionText extends StatefulWidget {
  final List<AttributionTextPart> children;

  final InlineSpan? Function(BuildContext context, int i)? separatorBuilder;

  final TextAlign alignment;

  final EdgeInsets padding;

  static InlineSpan _defaultSeparatorBuilder(BuildContext context, int i) {
    return const TextSpan(
      text: ' • ',
      semanticsLabel: '',
    );
  }

  const AttributionText({
    required this.children,
    this.separatorBuilder = _defaultSeparatorBuilder,
    this.alignment = TextAlign.center,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  @override
  State<AttributionText> createState() => _AttributionTextState();
}

class _AttributionTextState extends State<AttributionText> {
  final List<TapGestureRecognizer?> _gestureRecognizers = [];

  @override
  void initState() {
    super.initState();
    _setupGestureRecognizers();
  }

  @override
  void didUpdateWidget(covariant AttributionText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateGestureRecognizers();
  }

  void _setupGestureRecognizers() {
    _gestureRecognizers.addAll(
      widget.children.map((attributionTextLink) {
        return attributionTextLink.url != null
            ? (TapGestureRecognizer()..onTap = () => openUrl(Uri.parse(attributionTextLink.url!)))
            : null;
      }),
    );
  }

  void _cleanupGestureRecognizers() {
    for (var i = _gestureRecognizers.length - 1; i >= 0; i--) {
      _gestureRecognizers.removeAt(i)?.dispose();
    }
  }

  void _updateGestureRecognizers() {
    _cleanupGestureRecognizers();
    _setupGestureRecognizers();
  }

  @override
  Widget build(BuildContext context) {
    final attributionTextParts = _buildParts();
    final appLocale = AppLocalizations.of(context)!;
    return Padding(
      padding: widget.padding,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          // Stroked text as border.
          ExcludeSemantics(
            child: RichText(
              textAlign: widget.alignment,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 10,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 4
                    ..strokeJoin = StrokeJoin.round
                    ..color = Theme.of(context).colorScheme.tertiary,
                ),
                children: attributionTextParts,
              ),
            ),
          ),
          // Solid text as fill.
          Semantics(
            container: true,
            label: appLocale.semanticsAttribution,
            child: RichText(
              textAlign: widget.alignment,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
                children: attributionTextParts,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<InlineSpan> _buildParts() {
    final attributionTextParts = <InlineSpan>[
      if (widget.children.isNotEmpty) _buildPart(0),
    ];
    for (var i = 1; i < widget.children.length; i++) {
      final separator = widget.separatorBuilder?.call(context, i);
      if (separator != null) {
        attributionTextParts.add(separator);
      }
      attributionTextParts.add(_buildPart(i));
    }
    return attributionTextParts;
  }

  TextSpan _buildPart(int index) {
    return TextSpan(
      semanticsLabel: widget.children[index].text,
      text: widget.children[index].text,
      recognizer: _gestureRecognizers[index],
    );
  }

  /// Open the given attributions URL in the default browser.

  Future<void> openUrl(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('$url kann nicht aufgerufen werden');
    }
  }

  @override
  void dispose() {
    _cleanupGestureRecognizers();
    super.dispose();
  }
}

class AttributionTextPart {
  final String text;
  final String? url;

  const AttributionTextPart(
    this.text, {
    this.url,
  });
}
