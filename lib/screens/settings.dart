import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/difficulty_level.dart';
import '/view_models/preferences_provider.dart';
import '/widgets/select_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  static const themeModesMap = {
    ThemeMode.light : 'Hell',
    ThemeMode.dark : 'Dunkel',
    ThemeMode.system : 'Systemvorgabe',
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
              ListTile(
                // used to vertically center the icon
                leading: const SizedBox(
                  height: double.infinity,
                  child: Icon(Icons.palette),
                ),
                title: const Text('Farbliche Darstellung der App'),
                subtitle: Text(themeModesMap[themeMode] ?? 'Unbekannt'),
                onTap: () async {
                  final selection = await showDialog<ThemeMode>(
                    context: context,
                    builder: (BuildContext context) {
                      return SelectDialog(
                        valueLabelMap: themeModesMap,
                        value: context.select<PreferencesProvider, ThemeMode>((preferences) => preferences.themeMode),
                        title: const Text('Design'),
                      );
                    }
                  );
                  if (selection != null) {
                    context.read<PreferencesProvider>().themeMode = selection;
                  }
                },
              ),
              const Divider(height: 1),
              ListTile(
                // used to vertically center the icon
                leading: const SizedBox(
                  height: double.infinity,
                  child: Icon(Icons.line_weight),
                ),
                title: const Text('Schwierigkeitsgrad der Fragen'),
                subtitle: Text(difficultyMap[difficulty] ?? 'Unbekannt'),
                onTap: () async {
                  final selection = await showDialog<DifficultyLevel>(
                    context: context,
                    builder: (BuildContext context) {
                      return SelectDialog(
                        valueLabelMap: difficultyMap,
                        value: context.select<PreferencesProvider, DifficultyLevel>((preferences) => preferences.difficulty),
                        title: const Text('Schwierigkeitsgrad'),
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
