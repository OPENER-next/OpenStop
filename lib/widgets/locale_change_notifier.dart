// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/widgets.dart';

/// This is only needed to forward the locale from the PlatformDispatcher instance
/// and the app UI to the app worker isolate, because it is not available there.

class LocaleChangeNotifier extends StatefulWidget {
  final Widget? child;
  final void Function(Locale appLocale, List<Locale> userLocales) onChange;

  const LocaleChangeNotifier({
    required this.onChange,
    this.child,
    super.key,
  });

  @override
  State<LocaleChangeNotifier> createState() => _LocaleChangeNotifierState();
}

class _LocaleChangeNotifierState extends State<LocaleChangeNotifier> with WidgetsBindingObserver {
  Locale get appLocale => Localizations.localeOf(context);

  List<Locale> get userLocales => WidgetsBinding.instance.platformDispatcher.locales;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dispatch();
  }

  @override
  void didChangeLocales(List<Locale>? locales) => dispatch();

  void dispatch() =>  widget.onChange(appLocale, userLocales);

  @override
  Widget build(BuildContext context) => widget.child ?? const SizedBox.shrink();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
