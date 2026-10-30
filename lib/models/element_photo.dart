/// A selected image with a preassigned Panoramax ID and its OSM context.
class ElementPhoto {
  final String id;
  final String osmType;
  final int osmId;
  final String label;
  final String path;
  final PhotoUploadState upload;

  ElementPhoto({
    required this.id,
    required this.osmType,
    required this.osmId,
    required this.label,
    required this.path,
    PhotoUploadState? upload,
  }) : upload = upload ?? PhotoUploadState();

  String get osmReference => '$osmType/$osmId';
}

/// Mutable checkpoints retained in the answer for retries after partial uploads.
class PhotoUploadState {
  final String? accountId;
  String? setId;
  bool fileUploaded;
  bool completed;

  PhotoUploadState({this.accountId, this.setId, this.fileUploaded = false, this.completed = false});
}
