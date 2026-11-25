import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '/commons/app_config.dart';
import '/commons/routes.dart';
import '/l10n/app_localizations.g.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static final _urlIssues = Uri.parse('$kAppProjectUrl/issues');
  static final _urlTranslation = Uri.parse('https://hosted.weblate.org/engage/openstop/');

  @override
  Widget build(BuildContext context) {
    final appLocale = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocale.helpTitle),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(MdiIcons.headSync),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                title: Text(appLocale.helpOnboardingLabel),
                onTap: () => Navigator.push(context, Routes.onboarding),
              ),
              ListTile(
                leading: const Icon(Icons.feedback),
                trailing: const Icon(Icons.open_in_new),
                title: Text(appLocale.helpReportErrorLabel),
                onTap: () => launchUrl(_urlIssues),
              ),
              ListTile(
                leading: const Icon(Icons.translate),
                trailing: const Icon(Icons.open_in_new),
                title: Text(appLocale.helpImproveTranslationLabel),
                onTap: () => launchUrl(_urlTranslation),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
