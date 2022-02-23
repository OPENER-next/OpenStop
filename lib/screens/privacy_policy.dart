import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  void _launchUrl(String url) async {
    if (!await launch(url)) throw '$url kann nicht aufgerufen werden';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Datenschutzerklärung'),
        ),
        body: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(40.0, 20.0, 40.0, 20.0),
            scrollDirection: Axis.vertical,
            child: FutureBuilder(
                future: DefaultAssetBundle.of(context).loadString('PRIVACY_POLICY.md'),
                builder: (context, snapshot) {
                  return MarkdownBody(
                      data: snapshot.data.toString(),
                      selectable: true,
                      onTapLink: (text, href, title) { if(href != null) _launchUrl(href); }
                  );
                }
            )
          ),
        ),
    );
  }
}
