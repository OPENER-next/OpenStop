import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:community_material_icon/community_material_icon.dart';

import '/models/difficulty_level.dart';
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

  static const difficultyMap = {
    DifficultyLevel.easy : 'Einfach',
    DifficultyLevel.standard : 'Standard',
    DifficultyLevel.hard : 'Schwer',
  };

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<PreferencesProvider, ThemeMode>((preferences) => preferences.themeMode);
    final difficulty = context.select<PreferencesProvider, DifficultyLevel>((preferences) => preferences.difficulty);

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
                    context.read<PreferencesProvider>().themeMode = selection;
                  }
                },
              ),
              CustomListTile(
                leadingIcon: CommunityMaterialIcons.gauge,
                title: 'Schwierigkeitsgrad der Fragen',
                subtitle: difficultyMap[difficulty] ?? 'Unbekannt',
                onTap: () async {
                  final selection = await showDialog<DifficultyLevel>(
                    context: context,
                    builder: (BuildContext context) {
                      return SelectDialog(
                        valueLabelMap: difficultyMap,
                        value: context.select<PreferencesProvider, DifficultyLevel>((preferences) => preferences.difficulty),
                        title: const Text('Schwierigkeit auswählen'),
                      );
                    }
                  );
                  if (selection != null) {
                    context.read<PreferencesProvider>().difficulty = selection;
                  }
                },
              )
            ],
          ),
        ),
      )
    );
  }
}
