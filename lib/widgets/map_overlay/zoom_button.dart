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
    return Material(
      elevation: Theme.of(context).floatingActionButtonTheme.elevation ?? 4.0,
      shape: Theme.of(context).floatingActionButtonTheme.shape,
      color: Theme.of(context).colorScheme.primaryContainer,
      shadowColor: Theme.of(context).colorScheme.shadow,
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        container: true, // Necessary to read Semantically the buttons together
        child: Column(
          children: [
            SizedBox(
              height: (Theme.of(context).floatingActionButtonTheme.smallSizeConstraints?.minHeight ?? 48.0) * 1.25,
              width: Theme.of(context).floatingActionButtonTheme.smallSizeConstraints?.minWidth ?? 48.0,
              child: InkWell(
                onTap: onZoomInPressed,
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  semanticLabel: appLocale.semanticsZoomInButton,
                ),
              ),
            ),
            Container(
              height: 1,
              width: Theme.of(context).floatingActionButtonTheme.smallSizeConstraints?.minWidth,
              color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
            ),
            SizedBox(
              height: (Theme.of(context).floatingActionButtonTheme.smallSizeConstraints?.minHeight ?? 48.0) * 1.25,
              width: Theme.of(context).floatingActionButtonTheme.smallSizeConstraints?.minWidth ?? 48.0,
              child: InkWell(
                onTap: onZoomOutPressed,
                child: Icon(
                  Icons.remove,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
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
