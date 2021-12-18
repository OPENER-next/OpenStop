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
  final String _urlContributors = 'https://github.com/OPENER-next/OPENER-next/graphs/contributors';
  final String _urlCode = 'https://github.com/OPENER-next';
  final String _urlLicence = 'https://github.com/OPENER-next/OPENER-next/blob/master/LICENSE';
  final String _urlIdea = 'https://www.tu-chemnitz.de/etit/sse';

  late PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  void _launchUrl(_url) async {
    if (!await launch(_url)) throw '$_url kann nicht aufgerufen werden';
  }

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Über OPENER next'),
          backgroundColor: Colors.white10,
          elevation: 0.0,
          ),
        body: Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset('assets/app_icon_android.png',
                  height: 120,),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Text('"DIE Erfassungs-App für Barrieredaten im ÖPV"',
                  style: TextStyle(
                    fontStyle: FontStyle.italic
                  ),
                  ),
                ),
                ListTile(
                  dense: true,
                  leading: const Icon(
                      Icons.info,
                      color: Colors.black54
                  ),
                  title: const Text('Version'),
                  subtitle: Text('${_packageInfo.version}+${_packageInfo.buildNumber}'),
                  onTap: () {},
                ),
                ListTile(
                  dense: true,
                  leading: const Icon(
                      Icons.supervisor_account,
                      color: Colors.black54
                  ),
                  title: const Text('Autoren'),
                  subtitle: const Text('OPENER next Contributors'),
                  onTap: () => _launchUrl(_urlContributors),
                ),
                ListTile(
                  dense: true,
                  isThreeLine: true,
                  leading: const Icon(
                      Icons.lightbulb,
                      color: Colors.black54
                  ),
                  title: const Text('Idee'),
                  subtitle: const Text('Technische Universität Chemnitz\n'
                      'Professur Schaltkreis- und Systementwurf'),
                  onTap: () => _launchUrl(_urlIdea),
                ),
                ListTile(
                  dense: true,
                  leading: const Icon(
                      Icons.code,
                      color: Colors.black54
                  ),
                  title: const Text('Quellcode'),
                  subtitle: const Text('https://github.com/OPENER-next'),
                  onTap: () => _launchUrl(_urlCode),
                ),
                ListTile(
                  dense: true,
                  leading: const Icon(
                      Icons.text_snippet,
                      color: Colors.black54
                  ),
                  title: const Text('Lizenz'),
                  subtitle: const Text('GPL-3.0'),
                  onTap: () => _launchUrl(_urlLicence),
                ),
                ListTile(
                  dense: true,
                  leading: const Icon(
                      Icons.privacy_tip,
                      color: Colors.black54
                  ),
                  title: const Text('Datenschutzerklärung'),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PrivacyPolicy(),
                      )
                  ),
                ),
                ListTile(
                  dense: true,
                  leading: const Icon(
                      Icons.contact_page,
                      color: Colors.black54
                  ),
                  title: const Text('Nutzungsbedingungen'),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TermsOfUse(),
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
                          )
                      ),
                      Flexible(
                        flex: 1,
                          child: Padding(
                            padding:const EdgeInsets.fromLTRB(20.0,50.0,20.0,50.0),
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
        ),
    );
  }
}
