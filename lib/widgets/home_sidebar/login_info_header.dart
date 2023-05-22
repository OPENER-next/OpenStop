import 'package:flutter/material.dart';


class LoginInfoHeader extends StatelessWidget {
  final VoidCallback? onLoginTap;

  const LoginInfoHeader({
    this.onLoginTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          Text(
            'Melde dich mit deinem OpenStreetMap-Konto an, um deine Änderungen hochzuladen.',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            onPressed: onLoginTap,
            label: const Text('Anmelden'),
            icon: const Icon(Icons.login_rounded),
          ),
        ],
      ),
    );
  }
}
