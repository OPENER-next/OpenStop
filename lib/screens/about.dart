import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({Key? key}) : super(key: key);

  final String _urlContributors = 'https://github.com/OPENER-next/OPENER-next/graphs/contributors';
  final String _urlCode = 'https://github.com/OPENER-next';
  final String _urlLicence = 'https://github.com/OPENER-next/OPENER-next/blob/master/LICENSE';
  final String _urlIdea = 'https://www.tu-chemnitz.de/etit/sse';

  void _launchUrl(_url) async {
    if (!await launch(_url)) throw 'Could not launch $_url';
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
                  subtitle: const Text('1.12.3'),
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Image.asset('assets/logos/BMVI_Fz_2017_Office_Farbe_de.png'),
                        )
                    ),
                    Expanded(
                        child: Padding(
                          padding:const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Image.asset('assets/logos/mFUND_Logo_sRGB.png'),
                        )),
                  ],
                )
              ],
            ),
          ),
        ),
    );
  }
}
