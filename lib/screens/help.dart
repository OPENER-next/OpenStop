import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/widgets/custom_list_tile.dart';
import '/commons/app_config.dart' as app_config;
import '/commons/routes.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static final _urlIssues = Uri.parse('${app_config.appProjectUrl}/issues');
  static final _urlTranslation = Uri.parse('https://hosted.weblate.org/engage/openstop/');

  @override
  Widget build(BuildContext context) {
    final appLocale = AppLocalizations.of(context)!;
    return Scaffold(
      // Workaround until the default backgroundColor is not defined by the deprecated colorScheme.background anymore
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(appLocale.helpTitle),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Column(
            children: [
              CustomListTile(
                leadingIcon: MdiIcons.headSync,
                trailingIcon: Icons.arrow_forward_ios_rounded,
                title: appLocale.helpOnboardingLabel,
                onTap: () => Navigator.push(context, Routes.onboarding),
              ),
              CustomListTile(
                leadingIcon: Icons.feedback,
                trailingIcon: Icons.open_in_new,
                title: appLocale.helpReportErrorLabel,
                onTap: () => launchUrl(_urlIssues),
              ),
              CustomListTile(
                leadingIcon: Icons.translate,
                trailingIcon: Icons.open_in_new,
                title: appLocale.helpImproveTranslationLabel,
                onTap: () => launchUrl(_urlTranslation),
              ),
            ],
          ),
        ),
      )
    );
  }
}
