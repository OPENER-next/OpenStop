import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '/commons/app_config.dart';
import '/commons/routes.dart';
import '/l10n/app_localizations.g.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static final _urlCode = Uri.parse('https://github.com/OPENER-next');
  static final _urlContributors = Uri.parse(
    'https://github.com/OPENER-next/OpenStop/graphs/contributors',
  );
  static final _urlIdea = Uri.parse('https://www.tu-chemnitz.de/etit/sse');
  static final _urlLicense = Uri.parse(
    'https://github.com/OPENER-next/OpenStop/blob/master/LICENSE',
  );
  static final _urlVersion = Uri.parse('https://github.com/OPENER-next/OpenStop/releases');
  static final _urlStatistic = Uri.parse('https://stats.openstop.app/');

  @override
  Widget build(BuildContext context) {
    final appLocale = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocale.aboutTitle),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset(
                  'assets/images/app_icon_android.png',
                  height: 120,
                  excludeFromSemantics: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Semantics(
                  label: appLocale.semanticsSlogan,
                  child: Text(
                    appLocale.aboutSlogan,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.info),
                trailing: const Icon(Icons.open_in_new),
                title: Text(appLocale.aboutVersionLabel),
                subtitle: const Text(kAppVersion),
                onTap: () => launchUrl(_urlVersion),
              ),
              ListTile(
                leading: const Icon(Icons.supervisor_account),
                trailing: const Icon(Icons.open_in_new),
                title: Text(appLocale.aboutAuthorsLabel),
                subtitle: Text(appLocale.aboutAuthorsDescription(kAppName)),
                onTap: () => launchUrl(_urlContributors),
              ),
              ListTile(
                leading: const Icon(Icons.lightbulb),
                trailing: const Icon(Icons.open_in_new),
                title: Text(appLocale.aboutIdeaLabel),
                subtitle: Text(appLocale.aboutIdeaDescription),
                onTap: () => launchUrl(_urlIdea),
              ),
              ListTile(
                leading: const Icon(Icons.code),
                trailing: const Icon(Icons.open_in_new),
                title: Text(appLocale.aboutSourceCodeLabel),
                subtitle: const Text('https://github.com/OPENER-next'),
                onTap: () => launchUrl(_urlCode),
              ),
              ListTile(
                leading: const Icon(Icons.query_stats),
                trailing: const Icon(Icons.open_in_new),
                title: Text(appLocale.aboutStatisticLabel),
                onTap: () => launchUrl(_urlStatistic),
              ),
              ListTile(
                leading: const Icon(Icons.copyright),
                trailing: const Icon(Icons.open_in_new),
                title: Text(appLocale.aboutLicenseLabel),
                subtitle: const Text('GPL-3.0-or-later'),
                onTap: () => launchUrl(_urlLicense),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                title: Text(appLocale.aboutPrivacyPolicyLabel),
                onTap: () => Navigator.push(context, Routes.privacyPolicy),
              ),
              ListTile(
                leading: const Icon(Icons.text_snippet),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                title: Text(appLocale.aboutLicensePackageLabel),
                onTap: () => Navigator.push(context, Routes.licenses),
              ),
              Container(
                color: Colors.white,
                height: 160,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Image.asset(
                          'assets/images/logos/BMDV_Fz_2021_Office_Farbe_de.png',
                          semanticLabel: appLocale.semanticsFederalMinistryImage,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 50.0),
                        child: Image.asset(
                          'assets/images/logos/mFUND_Logo_sRGB.png',
                          semanticLabel: appLocale.semanticsMFundImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
