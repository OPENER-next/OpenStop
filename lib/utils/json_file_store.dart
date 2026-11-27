import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Persists a single JSON document in the application support directory.
///
/// Writes are atomic (temporary file + rename) and executed one after another,
/// so concurrent calls to [write] never interleave and the last call wins.

class JsonFileStore {
  JsonFileStore(
    this.fileName, {
    @visibleForTesting Future<Directory> Function()? baseDirectory,
  }) : _baseDirectory = baseDirectory ?? getApplicationSupportDirectory;

  /// Relative path of the file inside the application support directory.
  final String fileName;

  final Future<Directory> Function() _baseDirectory;

  Future<File>? _fileFuture;

  /// A failed lookup is not cached, so a call made too early
  /// (before platform channels are available in an isolate) doesn't break the store permanently.
  Future<File> get _file => _fileFuture ??= () async {
    try {
      final dir = await _baseDirectory();
      return File('${dir.path}${Platform.pathSeparator}$fileName');
    } catch (_) {
      _fileFuture = null;
      rethrow;
    }
  }();

  Future<void> _pendingWrite = Future.value();

  /// Returns the decoded JSON document or `null` if the file is missing or invalid.
  Future<Object?> read() async {
    // wait for any running write so the latest data is returned
    await _pendingWrite;
    final file = await _file;
    if (!file.existsSync()) return null;
    try {
      return jsonDecode(await file.readAsString());
    } on FormatException catch (e) {
      debugPrint('Ignore invalid JSON file $file: $e');
      return null;
    }
  }

  /// Replaces the stored document with [json].
  Future<void> write(Object? json) {
    final content = jsonEncode(json);
    return _pendingWrite = _pendingWrite.then((_) async {
      final file = await _file;
      await file.parent.create(recursive: true);
      final tempFile = File('${file.path}.tmp');
      await tempFile.writeAsString(content, flush: true);
      await tempFile.rename(file.path);
    }).catchError((Object e) {
      // a failed write must not block succeeding writes
      debugPrint('Could not write $fileName: $e');
    });
  }

  /// Deletes the stored document.
  Future<void> delete() {
    return _pendingWrite = _pendingWrite.then((_) async {
      final file = await _file;
      if (file.existsSync()) await file.delete();
    });
  }
}
