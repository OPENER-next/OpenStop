/// A selected image and the state needed to upload it to Panoramax.
class ElementPhoto {
  final String id;
  final String path;

  /// Measured during an in-app capture; library photos use their original EXIF.
  final ({double latitude, double longitude})? captureLocation;
  final PhotoUploadState upload;

  ElementPhoto({
    required this.id,
    required this.path,
    this.captureLocation,
    PhotoUploadState? upload,
  }) : upload = upload ?? PhotoUploadState();
}

/// Mutable checkpoints retained in the answer for retries after partial uploads.
class PhotoUploadState {
  final String? accountId;
  String? setId;
  bool fileUploaded;
  bool completed;

  PhotoUploadState({this.accountId, this.setId, this.fileUploaded = false, this.completed = false});
}
