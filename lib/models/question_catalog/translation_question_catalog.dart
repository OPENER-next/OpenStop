import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TranslationQuestionCatalog {
  late Map<String, String> questionCatalogTranslations;
  String Locale = Intl.getCurrentLocale().substring(0, 2);

  Map<String, String> getQuestionCatalogTransalation() {
    // Read JSON file
    /* final File file = File('$dir/assets/translations/question_catalog_$Locale.arb');
    final String jsonString = file.readAsStringSync();

    // Parse JSON string into dynamic object
    final dynamic jsonData = json.decode(jsonString);
    //final dynamic jsonData = _readARBFile(Locale);
    print(jsonData); */

    _readARBFile(Locale).then((jsonMap) {
      print(jsonMap);
      jsonMap.forEach((key, value) {
        questionCatalogTranslations[key.toString()] = value.toString();
        print(key); // Print attribute key
        print(value); // Recursively print attributes of the value
      });
    });

    /*  // Map the keyNames
    if (jsonData is Map) {
      jsonData.forEach((key, value) {
        questionCatalogTranslations[key.toString()] = value.toString();
        print(key); // Print attribute key
        print(value); // Recursively print attributes of the value
      });
    }  */

    return questionCatalogTranslations;
  }

  Map<String, String> getQuestionCatalogTransalationMap(ByteData dataT) {
    final jsonData = json.decode(utf8.decode(dataT.buffer.asUint8List()));
    jsonData.forEach((key, value) {
      questionCatalogTranslations[key.toString()] = value.toString();
      print(key); // Print attribute key
      print(value); // Recursively print attributes of the value
    });
    return questionCatalogTranslations;
  }

  Future<Map<String, dynamic>> _readARBFile(String Locale) async {
    String jsonData =
        await rootBundle.loadString('assets/question_catalog_$Locale.json');
    return json.decode(jsonData);
  }
}
