import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/widgets/custom_list_tile.dart';
import '/commons/app_config.dart' as app_config;
import '/commons/routes.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  static final _urlIssues = Uri.parse('${app_config.appProjectUrl}/issues');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.helpTitle),
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
                title: AppLocalizations.of(context)!.helpOnboardingLabel,
                onTap: () => Navigator.push(context, Routes.onboarding),
              ),
              CustomListTile(
                leadingIcon: Icons.feedback,
                trailingIcon: Icons.open_in_new,
                title: AppLocalizations.of(context)!.helpReportError,
                onTap: () => launchUrl(_urlIssues),
              ),
            ],
          ),
        ),
      )
    );
  }
}
