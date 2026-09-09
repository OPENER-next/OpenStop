import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// A simple file-based cache with a time-to-live (TTL) per entry.
///
/// Each cached file is laid out as:
/// [0..7] -> 8 bytes: eviction timestamp
/// [8..]  -> gzip-compressed payload
///
/// Files live under a subdirectory of the platform's temporary directory.
class FileCache {
  FileCache({
    required this.timeToLive,
    this.folderName = 'file_cache',
  });

  final Duration timeToLive;

  /// Name of the subdirectory created under the platform's temporary
  /// directory to hold cached files.
  final String folderName;

  /// Size of the header block that stores the eviction timestamp.
  /// 64 bits = 8 bytes.
  static const int _headerSizeBytes = 8;

  late final Future<Directory> _directory = () async {
    final tempDir = await getTemporaryDirectory();
    return Directory('${tempDir.path}${Platform.pathSeparator}$folderName');
  }();

  /// Writes [payload] to the cache under [id],
  /// prefixed with an 8-byte eviction timestamp. Creates the cache
  /// directory on disk if it doesn't exist yet.
  Future<void> write(String id, Stream<List<int>> payload) async {
    final dir = await _directory;
    await dir.create(recursive: true);
    final file = await _fileFor(id);

    final evictionDate = DateTime.now().add(timeToLive);
    final header = _encodeHeader(evictionDate);

    final sink = file.openWrite();
    try {
      sink.add(header);
      await payload.pipe(sink);
      await sink.flush();
    } finally {
      await sink.close();
    }
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
