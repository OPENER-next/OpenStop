import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'question_catalog.dart';

class QuestionCatalogReader {
  final String defaultLocate;

  QuestionCatalogReader({this.defaultLocate = 'en'});

  Locale get _deviceLocale => PlatformDispatcher.instance.locale;

  Future<QuestionCatalog> read(bool advanceCatalog) async {
    var questionCatalog = await _readCatalog('question_catalog');

    if (advanceCatalog) {
      final advanceQ = await _readCatalog('advanced_question_catalog');
      questionCatalog.addAll(advanceQ);
    }

    return QuestionCatalog.fromJson(
        questionCatalog.cast<Map<String, dynamic>>());
  }

  Future<dynamic> _readCatalog(String directory) async {
    final locales = await Future.wait([
      _readFile('assets/$directory/locales/$_deviceLocale.arb'),
      _readFile('assets/$directory/locales/${_deviceLocale.languageCode}.arb'),
      _readFile('assets/$directory/locales/$defaultLocate.arb')
    ]);

    final questionCatalog =
        await _readFile('assets/$directory/definition.json', (key, value) {
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

    return questionCatalog;
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
}
