// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'question_catalog.dart';

/// This method should not be invoked prior `WidgetsFlutterBinding.ensureInitialized`
///
/// It automatically refreshes files when the locale is modified.
///
/// If the class is no longer in use, it is required to call `dispose`.

class QuestionCatalogReader with WidgetsBindingObserver {

  Iterable<String> _assetPaths;

  String _defaultLocale;

  QuestionCatalogReader({
    required Iterable<String> assetPaths,
    String defaultLocale = 'en',
  }) :
    _assetPaths = assetPaths,
    _defaultLocale = defaultLocale
  {
    WidgetsBinding.instance.addObserver(this);
    _readAll(assetPaths).then((questionCatalog) {
      _streamController.add(QuestionCatalogChange(catalog: questionCatalog, change: QuestionCatalogChangeReason.definition));
    });
  }

  Iterable<String> get assetPaths => _assetPaths;

  String get defaultLocale => _defaultLocale;

  set assetPaths(Iterable<String> value) {
    _assetPaths = value;
    _readAll(assetPaths).then((questionCatalog) {
      _streamController.add(QuestionCatalogChange(catalog: questionCatalog, change: QuestionCatalogChangeReason.definition));
    });
  }

  set defaultLocale(String value) {
    _defaultLocale = value;
    _readAll(assetPaths).then((questionCatalog) {
      _streamController.add(QuestionCatalogChange(catalog: questionCatalog, change: QuestionCatalogChangeReason.definition));
    });
  }

  List<Locale> get _deviceLocales => PlatformDispatcher.instance.locales;

  final _streamController = StreamController<QuestionCatalogChange>();

  Stream<QuestionCatalogChange> get questionCatalog => _streamController.stream;

  @override
  @mustCallSuper
  void didChangeLocales(List<Locale>? locales) async {
    final questionCatalog = await _readAll(assetPaths);
    _streamController.add(QuestionCatalogChange(catalog: questionCatalog, change: QuestionCatalogChangeReason.language));
  }

  Future<QuestionCatalog> _readAll(Iterable<String> assetPaths) async {
    final catalogs = await Future.wait(
      assetPaths.map(_readCatalog),
    );
    return QuestionCatalog.fromJson(catalogs.expand((list) => list));
  }

  Future<List<Map<String, dynamic>>> _readCatalog(String directory) async {
    final locales = await Future.wait([
      ..._deviceLocales.expand((deviceLocale) sync* {
        yield _readArbFile(directory, deviceLocale.toLanguageTag());
        yield _readArbFile(directory, deviceLocale.languageCode);
      }),
      _readArbFile(directory, defaultLocale),
    ]);

    return (await _readJsonFile(
      '$directory/definition.json',
      fallback: const [],
      reviver: (key, value) {
        if (value is String && value.startsWith('@')) {
          for (final locale in locales) {
            final localeString = locale[value.substring(1)];
            if (localeString != null) {
              return localeString;
            }
          }
        }
        return value;
      },
    )).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> _readArbFile(String directory, String localeCode) async {
    return (await _readJsonFile(
      '$directory/locales/$localeCode.arb',
      fallback: const {},
    )).cast<String, dynamic>();
  }

  Future<dynamic> _readJsonFile(String path, {
    Object? Function(Object? key, Object? value)? reviver,
    dynamic fallback,
  }) async {
    try {
      final jsonData = await rootBundle.loadString(path);
      return json.decode(jsonData, reviver: reviver);
    }
    catch (e) {
      return fallback;
    }
  }

  @mustCallSuper
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _streamController.close();
  }
}

enum QuestionCatalogChangeReason {
  language,
  definition,
}

class QuestionCatalogChange {
  final QuestionCatalog catalog;
  final QuestionCatalogChangeReason change;

  const QuestionCatalogChange({
    required this.catalog,
    required this.change,
  });
}
