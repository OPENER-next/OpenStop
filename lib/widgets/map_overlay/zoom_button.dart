import 'package:flutter/material.dart';

import '/l10n/app_localizations.g.dart';

class ZoomButton extends StatelessWidget {
  final void Function()? onZoomInPressed;
  final void Function()? onZoomOutPressed;

  const ZoomButton({
    super.key,
    this.onZoomInPressed,
    this.onZoomOutPressed,
  });

  @override
  Widget build(BuildContext context) {
    final appLocale = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final fabTheme = theme.floatingActionButtonTheme;

    return Material(
      elevation: theme.floatingActionButtonTheme.elevation ?? 4.0,
      shape: theme.floatingActionButtonTheme.shape,
      color: theme.colorScheme.primaryContainer,
      shadowColor: theme.colorScheme.shadow,
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        container: true, // Necessary to read Semantically the buttons together
        child: Column(
          children: [
            SizedBox(
              height: (fabTheme.smallSizeConstraints?.minHeight ?? 48.0) * 1.25,
              width: fabTheme.smallSizeConstraints?.minWidth ?? 48.0,
              child: InkWell(
                onTap: onZoomInPressed,
                child: Icon(
                  Icons.add,
                  color: theme.colorScheme.onPrimaryContainer,
                  semanticLabel: appLocale.semanticsZoomInButton,
                ),
              ),
            ),
            Container(
              height: 1,
              width: fabTheme.smallSizeConstraints?.minWidth,
              color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
            ),
            SizedBox(
              height: (fabTheme.smallSizeConstraints?.minHeight ?? 48.0) * 1.25,
              width: fabTheme.smallSizeConstraints?.minWidth ?? 48.0,
              child: InkWell(
                onTap: onZoomOutPressed,
                child: Icon(
                  Icons.remove,
                  color: theme.colorScheme.onPrimaryContainer,
                  semanticLabel: appLocale.semanticsZoomOutButton,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
