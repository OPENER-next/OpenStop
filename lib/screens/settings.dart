import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/view_models/preferences_provider.dart';
import '/widgets/select_dialog.dart';
import '/widgets/custom_list_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  static const themeModesMap = {
    ThemeMode.system : 'Systemeinstellung',
    ThemeMode.light : 'Hell',
    ThemeMode.dark : 'Dunkel',
  };

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<PreferencesProvider, ThemeMode>((preferences) => preferences.themeMode);
    final isProfessional = context.select<PreferencesProvider, bool>((preferences) => preferences.isProfessional);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Column(
            children: [
              CustomListTile(
                leadingIcon: Icons.palette,
                title: 'Farbliche Darstellung der App',
                subtitle: themeModesMap[themeMode] ?? 'Unbekannt',
                onTap: () async {
                  final preferencesProvider = context.read<PreferencesProvider>();
                  final selection = await showDialog<ThemeMode>(
                    context: context,
                    builder: (BuildContext context) {
                      return SelectDialog(
                        valueLabelMap: themeModesMap,
                        value: context.select<PreferencesProvider, ThemeMode>((preferences) => preferences.themeMode),
                        title: const Text('Design auswählen'),
                      );
                    }
                  );
                  if (selection != null) {
                    preferencesProvider.themeMode = selection;
                  }
                },
              ),
              CustomSwitchListTile(
                value: isProfessional,
                leadingIcon: Icons.report_problem_rounded,
                title: 'Profi-Fragen anzeigen',
                subtitle: 'Aus Sicherheitsgründen nur für Fachpersonal bestimmt',
                isThreeLine: true,
                onChanged: (value) {
                  context.read<PreferencesProvider>().isProfessional = value;
                },
              )
            ],
          ),
        ),
      )
    );
  }
}
