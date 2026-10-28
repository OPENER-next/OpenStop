import 'package:uuid/uuid.dart';

class StopPhoto {
  final String id;
  final String osmType;
  final int osmId;
  final String label;
  final String path;
  String? uploadSetId;
  final String? uploadAccountId;
  bool fileUploaded;
  bool completed;

  StopPhoto({
    required this.id,
    required this.osmType,
    required this.osmId,
    required this.label,
    required this.path,
    this.uploadSetId,
    this.uploadAccountId,
    this.fileUploaded = false,
    this.completed = false,
  });

  String get osmReference => '$osmType/$osmId';

  StopPhoto forAccount(String accountId) {
    if (uploadAccountId == accountId) return this;
    final changed = uploadAccountId != null;
    return StopPhoto(
      id: changed ? const Uuid().v4() : id,
      osmType: osmType,
      osmId: osmId,
      label: label,
      path: path,
      uploadAccountId: accountId,
      uploadSetId: changed ? null : uploadSetId,
      fileUploaded: !changed && fileUploaded,
      completed: !changed && completed,
    );
  }
}
