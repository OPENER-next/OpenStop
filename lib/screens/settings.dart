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
    final Map<Enum, String> _themeModesMap = {
    ThemeMode.system : AppLocalizations.of(context)!.settingsThemeOptionSystem,
    ThemeMode.light : AppLocalizations.of(context)!.settingsThemeOptionLight,
    ThemeMode.dark : AppLocalizations.of(context)!.settingsThemeOptionDark,
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTitle),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Column(
            children: [
              CustomListTile(
                leadingIcon: Icons.palette,
                title: AppLocalizations.of(context)!.settingsThemeLabel,
                subtitle: _themeModesMap[viewModel.themeMode] ?? 'Unbekannt',
                onTap: () async {
                  final selection = await showDialog<ThemeMode>(
                    context: context,
                    builder: (BuildContext context) {
                      return SelectDialog(
                        valueLabelMap: _themeModesMap,
                        value: viewModel.themeMode,
                        title: Text(AppLocalizations.of(context)!.settingsThemeDialogTitle),
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
                title: AppLocalizations.of(context)!.settingsProfessionalQuestionsLabel,
                subtitle: AppLocalizations.of(context)!.settingsProfessionalQuestionsDescription,
                onChanged: (v) => viewModel.changeIsProfessional([v]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
