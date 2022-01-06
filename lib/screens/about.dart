import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Screens
import 'terms_of_use.dart';
import 'privacy_policy.dart';

class About extends StatefulWidget {
  const About({Key? key}) : super(key: key);

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  static const String _urlContributors = 'https://github.com/OPENER-next/OPENER-next/graphs/contributors';
  static const String _urlCode = 'https://github.com/OPENER-next';
  static const String _urlLicence = 'https://github.com/OPENER-next/OPENER-next/blob/master/LICENSE';
  static const String _urlIdea = 'https://www.tu-chemnitz.de/etit/sse';

  final _packageInfo = PackageInfo.fromPlatform();

  void _launchUrl(_url) async {
    if (!await launch(_url)) throw '$_url kann nicht aufgerufen werden';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Über'),
      ),
      body: FutureBuilder<PackageInfo>(
        future: _packageInfo,
        builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
          if (snapshot.hasData) {
            return Scrollbar(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset(
                        'assets/app_icon_android.png',
                        height: 120,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        '"DIE Erfassungs-App für Barrieredaten im ÖPV"',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.info),
                      title: const Text('Version'),
                      subtitle: Text('${snapshot.data!.version}+${snapshot.data!.buildNumber}'),
                      onTap: () {},
                    ),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.supervisor_account),
                      title: const Text('Autoren'),
                      subtitle: Text('${snapshot.data!.appName} Mitwirkende'),
                      onTap: () => _launchUrl(_urlContributors),
                    ),
                    ListTile(
                      dense: true,
                      isThreeLine: true,
                      leading: const Icon(Icons.lightbulb),
                      title: const Text('Idee'),
                      subtitle: const Text('Technische Universität Chemnitz\n'
                          'Professur Schaltkreis- und Systementwurf'),
                      onTap: () => _launchUrl(_urlIdea),
                    ),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.code),
                      title: const Text('Quellcode'),
                      subtitle: const Text('https://github.com/OPENER-next'),
                      onTap: () => _launchUrl(_urlCode),
                    ),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.text_snippet),
                      title: const Text('Lizenz'),
                      subtitle: const Text('GPL-3.0'),
                      onTap: () => _launchUrl(_urlLicence),
                    ),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.privacy_tip),
                      title: const Text('Datenschutzerklärung'),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrivacyPolicy(),
                          )
                      ),
                    ),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.contact_page),
                      title: const Text('Nutzungsbedingungen'),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TermsOfUse(),
                          )
                      ),
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
                                    'assets/logos/BMVI_Fz_2017_Office_Farbe_de.png'),
                              )),
                          Flexible(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 50.0),
                                child: Image.asset(
                                    'assets/logos/mFUND_Logo_sRGB.png'),
                              )
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.error_outline_outlined,
                        color: Colors.black54, size: 60),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text('Error: ${snapshot.error}'),
                )
              ]
              ),
            );
          } else {
            return Center(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const <Widget>[
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Rufe Informationen ab...'),
                    )
                  ]
              ),
            );
          }
        },
      ),
    );
  }
}
