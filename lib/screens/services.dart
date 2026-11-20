import 'package:flutter/material.dart' hide View;
import 'package:flutter_mvvm_architecture/base.dart';

import '/commons/panoramax_config.dart';
import '/commons/themes.dart';
import '/l10n/app_localizations.g.dart';
import '/view_models/services_view_model.dart';

class ServicesScreen extends View<ServicesViewModel> {
  const ServicesScreen({super.key}) : super(create: ServicesViewModel.new);

  @override
  Widget build(BuildContext context, viewModel) {
    final appLocale = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final userName = viewModel.panoramaxUserName;

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocale.servicesTitle),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.fromLTRB(
            Default.padding,
            Default.padding,
            Default.padding,
            Default.padding + MediaQuery.of(context).padding.bottom,
          ),
          child: Card.filled(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        foregroundImage: AssetImage('assets/images/logos/Panoramax.webp'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Panoramax', style: theme.textTheme.titleLarge),
                            Text(
                              appLocale.servicesPanoramaxDescription,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Supporting content
                ListTile(
                  title: Text(
                    appLocale.servicesInstanceUrl,
                  ),
                  subtitle: Text(
                    viewModel.panoramaxInstance.host,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: viewModel.openPanoramaxWebsite,
                ),
                if (userName != null)
                  ListTile(
                    title: Text(
                      appLocale.servicesAccount,
                    ),
                    subtitle: Text(
                      userName,
                      semanticsLabel: appLocale.semanticsUser(userName),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: viewModel.openPanoramaxUserProfile,
                  ),
                // Actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: OverflowBar(
                    alignment: MainAxisAlignment.end,
                    overflowAlignment: OverflowBarAlignment.end,
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: () => showDialog<void>(
                          context: context,
                          builder: (context) => _PanoramaxInstanceDialog(
                            instance: viewModel.panoramaxInstance.toString(),
                            onConfirm: viewModel.changePanoramaxInstance,
                          ),
                        ),
                        child: Text(appLocale.servicesChangeServer),
                      ),
                      if (userName != null)
                        FilledButton(
                          onPressed: viewModel.logoutPanoramax,
                          child: Text(appLocale.logout),
                        )
                      else
                        FilledButton(
                          onPressed: viewModel.loginPanoramax,
                          child: Text(appLocale.login),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PanoramaxInstanceDialog extends StatefulWidget {
  final String instance;
  final Future<bool> Function(String value) onConfirm;

  const _PanoramaxInstanceDialog({
    required this.instance,
    required this.onConfirm,
  });

  @override
  State<_PanoramaxInstanceDialog> createState() => _PanoramaxInstanceDialogState();
}

class _PanoramaxInstanceDialogState extends State<_PanoramaxInstanceDialog> {
  late final _controller = TextEditingController(text: widget.instance);

  bool _busy = false;

  bool _failed = false;

  Future<void> _confirm() async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    final success = await widget.onConfirm(_controller.text);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      setState(() {
        _busy = false;
        _failed = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocale = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(appLocale.servicesPanoramaxInstance),
      content: TextField(
        controller: _controller,
        enabled: !_busy,
        keyboardType: TextInputType.url,
        decoration: InputDecoration(
          labelText: appLocale.servicesInstanceUrl,
          hintText: kPanoramaxUrl,
          errorText: _failed ? appLocale.servicesInstanceError : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: Text(appLocale.cancel),
        ),
        TextButton(
          onPressed: _busy ? null : _confirm,
          child: Text(appLocale.confirm),
        ),
      ],
    );
  }
}
