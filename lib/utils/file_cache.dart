import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// A simple file-based cache with a time-to-live (TTL) per entry.
///
/// Each cached file is laid out as:
/// [0..7] -> 8 bytes: eviction timestamp
/// [8..]  -> gzip-compressed payload
///
/// Files live under a subdirectory of either the platform's temporary directory
/// (may be purged by the OS at any time) or the application support directory
/// (kept until the app deletes them), see [FileCacheLocation].
class FileCache {
  FileCache({
    required this.timeToLive,
    this.folderName = 'file_cache',
    this.location = FileCacheLocation.temporary,
    @visibleForTesting this._baseDirectory,
  });

  final Duration timeToLive;

  /// Name of the subdirectory created under the base directory to hold cached files.
  final String folderName;

  /// The base directory in which the cache folder is created.
  final FileCacheLocation location;

  final Future<Directory> Function()? _baseDirectory;

  /// Size of the header block that stores the eviction timestamp.
  /// 64 bits = 8 bytes.
  static const int _headerSizeBytes = 8;

  /// Suffix of files that are currently being written.
  static const String _tempSuffix = '.tmp';

  Future<Directory>? _directoryFuture;

  /// The cache directory. A failed lookup is not cached,
  /// so a call made too early (e.g. before platform channels are available in an isolate)
  /// doesn't break the cache permanently.
  Future<Directory> get _directory => _directoryFuture ??= () async {
    try {
      final baseDir = await (_baseDirectory?.call() ?? switch (location) {
        FileCacheLocation.temporary => getTemporaryDirectory(),
        FileCacheLocation.applicationSupport => getApplicationSupportDirectory(),
      });
      return Directory('${baseDir.path}${Platform.pathSeparator}$folderName');
    } catch (_) {
      _directoryFuture = null;
      rethrow;
    }
  }();

  bool _staleEntriesEvicted = false;

  /// Calls [evictStale] once per instance in the background.
  ///
  /// Must not be called from a constructor of a class that is created during the
  /// field initialization of a service worker, because platform channels are not available yet.
  void evictStaleOnce() {
    if (_staleEntriesEvicted) return;
    _staleEntriesEvicted = true;
    evictStale().catchError((Object e) => debugPrint('Could not evict stale entries: $e')).ignore();
  }

  /// Writes [payload] to the cache under [id],
  /// prefixed with an 8-byte eviction timestamp. Creates the cache
  /// directory on disk if it doesn't exist yet.
  ///
  /// The data is first written to a temporary file which is renamed on success.
  /// This way an existing entry is never replaced by a partially written file,
  /// for example when the app is killed during the write.
  Future<void> write(String id, Stream<List<int>> payload) async {
    final dir = await _directory;
    await dir.create(recursive: true);
    final file = await _fileFor(id);
    final tempFile = File('${file.path}$_tempSuffix');

    final evictionDate = DateTime.now().add(timeToLive);
    final header = _encodeHeader(evictionDate);

    final sink = tempFile.openWrite();
    try {
      sink.add(header);
      // pipe also closes the sink
      await payload.pipe(sink);
    } catch (e) {
      debugPrint('Discard $file from cache due to error: $e');
      // prevent storage of corrupted or invalid cache files
      await sink.close().catchError((_) {});
      if (tempFile.existsSync()) await tempFile.delete();
      rethrow;
    }
    await tempFile.rename(file.path);
  }

  /// Writes the given [bytes] to the cache under [id], see [write].
  Future<void> writeBytes(String id, List<int> bytes) => write(id, Stream.value(bytes));

  /// Reads the entire payload for [id] or returns `null` if there is no entry.
  /// This does not check staleness.
  Future<Uint8List?> readBytes(String id) async {
    final file = await _fileFor(id);
    if (!file.existsSync()) return null;
    final bytes = await file.readAsBytes();
    return bytes.length < _headerSizeBytes ? null : Uint8List.sublistView(bytes, _headerSizeBytes);
  }

  /// Whether a cache entry exists for [id] (does not check staleness).
  Future<bool> hasHit(String id) async {
    final file = await _fileFor(id);
    return file.existsSync();
  }

  /// Whether the cache entry for [id] is past its eviction date.
  /// Returns `true` if the file is missing, unreadable, or expired.
  Future<bool> isStale(String id) async {
    final file = await _fileFor(id);
    if (!file.existsSync()) return true;

    final raf = await file.open();
    try {
      final headerBytes = await raf.read(_headerSizeBytes);
      if (headerBytes.length < _headerSizeBytes) return true;
      final evictionDate = _decodeHeader(headerBytes);
      return DateTime.now().isAfter(evictionDate);
    } finally {
      await raf.close();
    }
  }

  /// Whether the cache entry for [id] exists and has not yet expired.
  Future<bool> isFresh(String id) async => !(await isStale(id));

  /// Streams the payload for [id], skipping the header.
  Stream<List<int>> read(String id) async* {
    final file = await _fileFor(id);
    if (!file.existsSync()) return;
    yield* file.openRead(_headerSizeBytes);
  }

  /// Deletes the cached entry for [id], if present.
  Future<void> delete(String id) async {
    final file = await _fileFor(id);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  /// Deletes all entries that are past their eviction date
  /// as well as any leftovers of interrupted writes.
  Future<void> evictStale() async {
    final dir = await _directory;
    if (!dir.existsSync()) return;
    await for (final entity in dir.list()) {
      if (entity is! File) continue;
      try {
        if (entity.path.endsWith(_tempSuffix)) {
          await entity.delete();
        } else {
          final id = entity.uri.pathSegments.last;
          if (await isStale(id)) await entity.delete();
        }
      } on FileSystemException catch (e) {
        debugPrint('Could not evict $entity from cache: $e');
      }
    }
  }

  /// Deletes all cached entries.
  Future<void> clear() async {
    final dir = await _directory;
    if (!dir.existsSync()) return;
    await dir.delete(recursive: true);
  }

  /// Resolves the [File] for a given cache [id] within the cache directory.
  Future<File> _fileFor(String id) async {
    final dir = await _directory;
    return File('${dir.path}${Platform.pathSeparator}$id');
  }

  /// Builds the byte header encoding [evictionDate] as a 64-bit
  /// big-endian millisecondsSinceEpoch timestamp.
  Uint8List _encodeHeader(DateTime evictionDate) {
    final header = ByteData(_headerSizeBytes)
      ..setInt64(0, evictionDate.millisecondsSinceEpoch, Endian.big);
    return header.buffer.asUint8List();
  }

  /// Parses a header (as produced by [_encodeHeader]) back into the
  /// eviction [DateTime] it encodes.
  DateTime _decodeHeader(Uint8List headerBytes) {
    final byteData = ByteData.sublistView(headerBytes);
    final evictionMillis = byteData.getInt64(0, Endian.big);
    return DateTime.fromMillisecondsSinceEpoch(evictionMillis);
  }
}

enum FileCacheLocation {
  /// The platform's temporary directory, which may be purged by the OS at any time.
  temporary,

  /// The application support directory, which is kept until the app deletes it.
  applicationSupport,
}
