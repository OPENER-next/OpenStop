import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:community_material_icon/community_material_icon.dart';

import '/widgets/custom_list_tile.dart';
import '/commons/app_config.dart' as app_config;
import '/commons/routes.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {

  Future<void> _launchUrl(String url) async {
    if (!await launchUrlString(
      url,
      mode: LaunchMode.externalApplication,
    )) throw '$url kann nicht aufgerufen werden';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hilfe'),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Column(
            children: [
              CustomListTile(
                leadingIcon: CommunityMaterialIcons.head_sync,
                trailingIcon: Icons.arrow_forward_ios_rounded,
                title: 'Einführung erneut anschauen',
                onTap: () => Navigator.push(context, Routes.onboarding),
              ),
              CustomListTile(
                leadingIcon: Icons.feedback,
                trailingIcon: Icons.open_in_new,
                title: 'Fehler melden',
                onTap: () => _launchUrl('${app_config.appProjectUrl}/issues'),
              ),
            ],
          ),
        ),
      )
    );
  }
}
