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
          child: Card.outlined(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Default.borderRadius),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.only(left: Default.padding * 1.5, right: 4),
                  leading: const Icon(Icons.panorama),
                  title: Text(
                    'Panoramax',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Row(
                    children: [
                      Flexible(
                        child: Text(
                          viewModel.panoramaxInstance.host,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.open_in_new,
                        size: 14,
                        color: theme.iconTheme.color?.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                  onTap: viewModel.openPanoramaxWebsite,
                  trailing: IconButton(
                    tooltip: appLocale.servicesPanoramaxInstance,
                    icon: const Icon(Icons.settings),
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (context) => _PanoramaxInstanceDialog(
                        instance: viewModel.panoramaxInstance.toString(),
                        onConfirm: viewModel.changePanoramaxInstance,
                      ),
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  color: theme.colorScheme.outlineVariant,
                ),
                if (userName != null)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: Default.padding * 1.5),
                    leading: CircleAvatar(
                      radius: 12,
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      child: Text(userName.characters.first.toUpperCase()),
                    ),
                    title: Text(
                      userName,
                      semanticsLabel: appLocale.semanticsUser(userName),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Icon(
                      Icons.open_in_new,
                      size: 16,
                      color: theme.iconTheme.color?.withValues(alpha: 0.4),
                    ),
                    onTap: viewModel.openPanoramaxUserProfile,
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Default.padding * 1.5,
                      Default.padding,
                      Default.padding * 1.5,
                      0,
                    ),
                    child: Text(
                      appLocale.servicesPanoramaxDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(Default.padding),
                  child: userName != null
                      ? OutlinedButton.icon(
                          onPressed: viewModel.logoutPanoramax,
                          icon: const Icon(Icons.logout),
                          label: Text(appLocale.logout),
                        )
                      : OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                          onPressed: viewModel.loginPanoramax,
                          icon: const Icon(Icons.login),
                          label: Text(appLocale.login),
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
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(Default.borderRadius)),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
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
