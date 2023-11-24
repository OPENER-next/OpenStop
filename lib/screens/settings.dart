import 'package:flutter/material.dart' hide View;
import 'package:flutter_mvvm_architecture/base.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/view_models/settings_view_model.dart';
import '/widgets/select_dialog.dart';
import '/widgets/custom_list_tile.dart';

class SettingsScreen extends View<SettingsViewModel> {

  

  const SettingsScreen({super.key}) : super(create: SettingsViewModel.new);

  @override
  Widget build(BuildContext context, viewModel) {
    final appLocale = AppLocalizations.of(context)!;

    final Map<ThemeMode, String> themeModesMap = {
      ThemeMode.system: appLocale.settingsThemeOptionSystem,
      ThemeMode.light: appLocale.settingsThemeOptionLight,
      ThemeMode.dark: appLocale.settingsThemeOptionDark,
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocale.settingsTitle),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Column(
            children: [
              CustomListTile(
                leadingIcon: Icons.palette,
                title: appLocale.settingsThemeLabel,
                subtitle: themeModesMap[viewModel.themeMode] ?? 'Unbekannt',
                onTap: () async {
                  final selection = await showDialog<ThemeMode>(
                    context: context,
                    builder: (BuildContext context) {
                      return SelectDialog(
                        semanticLabel: appLocale.semanticsSettingsDialogBox,
                        valueLabelMap: themeModesMap,
                        value: viewModel.themeMode,
                        title: Text(appLocale.settingsThemeDialogTitle),
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
                title: appLocale.settingsProfessionalQuestionsLabel,
                subtitle: appLocale.settingsProfessionalQuestionsDescription,
                onChanged: (v) => viewModel.changeIsProfessional([v]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
