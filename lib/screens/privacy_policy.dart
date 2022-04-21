import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final _privacyPolicyText = rootBundle.loadString('PRIVACY_POLICY.md');

  void _launchUrl(String text, String? url, String? title) async {
    if (url != null) {
      if (!await launch(url)) throw '$url kann nicht aufgerufen werden';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datenschutzerklärung'),
      ),
      body: Scrollbar(
        child: FutureBuilder<String>(
          future: _privacyPolicyText,
          builder: (context, snapshot) {
            return (!snapshot.hasData)
              ? const Center(
                child: CircularProgressIndicator()
              )
              : Markdown(
                data: snapshot.requireData,
                padding: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).padding.bottom
                ),
                selectable: true,
                onTapLink: _launchUrl
              );
          }
        )
      ),
    );
  }
}
