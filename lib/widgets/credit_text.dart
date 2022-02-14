import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class CreditText extends StatelessWidget {
  final List<Widget> children;

  final IndexedWidgetBuilder separatorBuilder;

  final WrapAlignment alignment;

  final EdgeInsets padding;

  static Widget _defaultSeparatorBuilder (BuildContext context, int i) => const CreditTextPart(', ');

  const CreditText({
    required this.children,
    this.separatorBuilder = _defaultSeparatorBuilder,
    this.alignment = WrapAlignment.center,
    this.padding = EdgeInsets.zero,
    Key? key
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Wrap(
        alignment: alignment,
        children: _buildParts(context)
      )
    );
  }


  List<Widget> _buildParts(BuildContext context) {
    final creditTextParts = <Widget>[
      if (children.isNotEmpty) children.first
    ];
    for (var i = 1; i < children.length; i++) {
      creditTextParts.add(separatorBuilder(context, i));
      creditTextParts.add(children[i]);
    }
    return creditTextParts;
  }
}


class CreditTextPart extends StatelessWidget {
  final String creditsText;
  final String? creditsUrl;

  const CreditTextPart(this.creditsText, {
    this.creditsUrl,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: creditsUrl != null ? _openCreditsUrl : null,
      child: Stack(
        children: [
          // Stroked text as border.
          Text(
            creditsText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 4
                ..strokeJoin = StrokeJoin.round
                ..color = Colors.white,
            ),
          ),
          // Solid text as fill.
          Text(
            creditsText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black,
            ),
          ),
        ],
      )
    );
  }


  /// Open the given credits URL in the default browser.

  void _openCreditsUrl() async {
    if (!await launch(creditsUrl!)) throw '$creditsUrl kann nicht aufgerufen werden';
  }
}
