import 'dart:ui';

import '/utils/service_worker.dart';

mixin LocaleHandler<M> on ServiceWorker<M> {
  List<Locale> userLocales = const [];
  Locale appLocale = const Locale('en');

  void updateLocales(Locale appLocale, List<Locale> userLocales) {
    this.appLocale = appLocale;
    this.userLocales = userLocales;
  }
}
