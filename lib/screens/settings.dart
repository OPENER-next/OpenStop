import 'package:flutter/material.dart' hide View;
import 'package:flutter_mvvm_architecture/base.dart';

import '/view_models/settings_view_model.dart';
import '/widgets/select_dialog.dart';
import '/widgets/custom_list_tile.dart';

class SettingsScreen extends View<SettingsViewModel> {

  static const _themeModesMap = {
    ThemeMode.system : 'Systemeinstellung',
    ThemeMode.light : 'Hell',
    ThemeMode.dark : 'Dunkel',
  };

  const SettingsScreen({super.key}) : super(create: SettingsViewModel.new);

  @override
  Widget build(BuildContext context, viewModel) {
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
                subtitle: _themeModesMap[viewModel.themeMode] ?? 'Unbekannt',
                onTap: () async {
                  final selection = await showDialog<ThemeMode>(
                    context: context,
                    builder: (BuildContext context) {
                      return SelectDialog(
                        valueLabelMap: _themeModesMap,
                        value: viewModel.themeMode,
                        title: const Text('Design auswählen'),
                      );
                    }
                  );
                  if (selection != null) {
                    viewModel.changeThemeMode([selection]);
                  }
                },
              ),
              CustomSwitchListTile(
                value: viewModel.isProfessional,
                leadingIcon: Icons.report_problem_rounded,
                title: 'Profi-Fragen anzeigen',
                subtitle: 'Aus Sicherheitsgründen nur für Fachpersonal bestimmt',
                onChanged: (v) => viewModel.changeIsProfessional([v]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
