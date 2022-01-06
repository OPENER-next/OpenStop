import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/view_models/preferences_provider.dart';
import '/widgets/select_dialog.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  var appThemesMap = {
    themeEnum.light : 'Hell',
    themeEnum.dark : 'Dunkel',
    themeEnum.contrast : 'Kontrast',
  };

  var difficultyMap = {
    1 : 'Einfach',
    2 : 'Standard',
    3 : 'Schwer',
  };

  @override
  Widget build(BuildContext context) {
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
                        leading: const Icon(Icons.palette),
                        title: const Text('Design'),
                        trailing: Text(appThemesMap[context.select<PreferencesProvider, themeEnum>((preferences) => preferences.theme)] ?? 'Unbekannt'),
                        //subtitle: const Text('Farbliche Darstellung'),
                        onTap: () async {
                          // change int to the type you are using as the key in the map below
                          final selection = await showDialog<themeEnum>(
                              context: context,
                              builder: (BuildContext context) {
                                return SelectDialog(
                                  valueLabelMap: appThemesMap,
                                  value: context.select<PreferencesProvider, themeEnum>((preferences) => preferences.theme),
                                  title: const Text('Design wählen'),
                                );
                              }
                          );
                          context.read<PreferencesProvider>().theme = selection!;
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.line_weight),
                        title: const Text('Schwierigkeitsgrad'),
                        trailing: Text(difficultyMap[context.select<PreferencesProvider, int>((preferences) => preferences.difficulty)] ?? 'Unbekannt'),
                        //subtitle: const Text('Schwere der Fragen'),
                        onTap: () async {
                          // change int to the type you are using as the key in the map below
                          final selection = await showDialog<int>(
                              context: context,
                              builder: (BuildContext context) {
                                return SelectDialog(
                                  valueLabelMap: difficultyMap,
                                  value: context.select<PreferencesProvider, int>((preferences) => preferences.difficulty),
                                  title: const Text('Schwierigkeitsgrad wählen'),
                                );
                              }
                          );
                          context.read<PreferencesProvider>().difficulty = selection!;
                        },
                      )
                    ],
                  ),
                ),
              )
      );
  }
}
