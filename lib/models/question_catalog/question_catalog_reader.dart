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

  String _defaultLocate;

  QuestionCatalogReader({
    required Iterable<String> assetPaths,
    String defaultLocate = 'en',
  }) :
    _assetPaths = assetPaths,
    _defaultLocate = defaultLocate
  {
    WidgetsBinding.instance.addObserver(this);
    _readAll(assetPaths).then((questionCatalog) {
      _streamController.add(QuestionCatalogChange(catalog: questionCatalog, change: QuestionCatalogChangeReason.definition));
    });
  }

  Iterable<String> get assetPaths => _assetPaths;

  String get defaultLocate => _defaultLocate;

  set assetPaths(Iterable<String> value) {
    _assetPaths = value;
    _readAll(assetPaths).then((questionCatalog) {
      _streamController.add(QuestionCatalogChange(catalog: questionCatalog, change: QuestionCatalogChangeReason.definition));
    });
  }

  set defaultLocate(String value) {
    _defaultLocate = value;
    _readAll(assetPaths).then((questionCatalog) {
      _streamController.add(QuestionCatalogChange(catalog: questionCatalog, change: QuestionCatalogChangeReason.definition));
    });
  }

  Locale get _deviceLocale => PlatformDispatcher.instance.locale;

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
      _readFile('$directory/locales/$_deviceLocale.arb'),
      _readFile('$directory/locales/${_deviceLocale.languageCode}.arb'),
      _readFile('$directory/locales/$defaultLocate.arb')
    ]);

    final questionCatalog =
        await _readFile('$directory/definition.json', (key, value) {
      if (value is String) {
        if (value.startsWith('@')) {
          for (final languagefiles in locales) {
            final localeString = languagefiles[value.substring(1)];
            if (localeString != null) {
              return localeString;
            }
          }
        }
      }
      return value;
    });

    return questionCatalog.cast<Map<String, dynamic>>();
  }

  Future<dynamic> _readFile(String path,
      [Object? Function(Object? key, Object? value)? reviver]) async {
    try {
      final jsonData = await rootBundle.loadString(path);
      return json.decode(jsonData, reviver: reviver);
    } catch (e) {
      return const <String, dynamic>{};
    }
  }

  @mustCallSuper
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _streamController.close();
  }
}
