import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';

class LoginInfoHeader extends StatelessWidget {
  final VoidCallback? onLoginTap;

  const LoginInfoHeader({
    this.onLoginTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocale = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 25,
        left: 15,
        right: 15,
        bottom: 25,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ExcludeSemantics(
            child: Text(
              appLocale.loginHint,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Semantics(
            hint: appLocale.semanticsLoginHint,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              onPressed: onLoginTap,
              label: Text(appLocale.login),
              icon: const Icon(Icons.login_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
