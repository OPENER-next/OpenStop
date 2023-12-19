import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreditText extends StatefulWidget {
  final List<CreditTextPart> children;

  final InlineSpan? Function(BuildContext context, int i)? separatorBuilder;

  final TextAlign alignment;

  final EdgeInsets padding;

  static InlineSpan _defaultSeparatorBuilder(BuildContext context, int i) {
    return const TextSpan(
      children: [
        WidgetSpan(
          child: ExcludeSemantics(
            child: Text(', '),
          ),
        ),
      ],
    );
  }

  const CreditText({
    required this.children,
    this.separatorBuilder = _defaultSeparatorBuilder,
    this.alignment = TextAlign.center,
    this.padding = EdgeInsets.zero,
    Key? key
  }) : super(key: key);

  @override
  State<CreditText> createState() => _CreditTextState();
}


class _CreditTextState extends State<CreditText> {
  final List<TapGestureRecognizer?> _gestureRecognizers = [];

  @override
  void initState() {
    super.initState();
    _setupGestureRecognizers();
  }


  @override
  void didUpdateWidget(covariant CreditText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateGestureRecognizers();
  }


  void _setupGestureRecognizers() {
    _gestureRecognizers.addAll(
      widget.children.map((creditTextLink) {
        return creditTextLink.url != null
        ? (TapGestureRecognizer()..onTap = () => openUrl(Uri.parse(creditTextLink.url!)))
        : null;
      })
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
    final creditTextParts = _buildParts();
    final appLocale = AppLocalizations.of(context)!;
    return Padding(
      padding: widget.padding,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          // Stroked text as border.
          ExcludeSemantics(
            child:RichText(
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
                children: creditTextParts
              ),
            ),
          ),
          // Solid text as fill.
          Semantics(
            container: true,
            label: appLocale.semanticsCredits,
            child: RichText(
              textAlign: widget.alignment,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
                children: creditTextParts
              ),
            ),
          ),
        ],
      )
    );
  }


  List<InlineSpan> _buildParts() {
    final creditTextParts = <InlineSpan>[
      if (widget.children.isNotEmpty) _buildPart(0)
    ];
    for (var i = 1; i < widget.children.length; i++) {
      final separator = widget.separatorBuilder?.call(context, i);
      if (separator != null) {
        creditTextParts.add(separator);
      }
      creditTextParts.add(_buildPart(i));
    }
    return creditTextParts;
  }


  TextSpan _buildPart(int index) {
    return TextSpan(
      semanticsLabel: widget.children[index].text,
      text: widget.children[index].text,
      recognizer: _gestureRecognizers[index]
    );
  }


  /// Open the given credits URL in the default browser.

  Future<void> openUrl(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) throw '$url kann nicht aufgerufen werden';
  }


  @override
  void dispose() {
    _cleanupGestureRecognizers();
    super.dispose();
  }
}


class CreditTextPart {
  final String text;
  final String? url;

  const CreditTextPart(this.text, {
    this.url,
  });
}
