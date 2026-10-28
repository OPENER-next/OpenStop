import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '/api/stop_photo_store.dart';
import '/commons/themes.dart';
import '/l10n/app_localizations.g.dart';
import '/models/answer.dart';
import '/models/map_features/map_feature_representation.dart';
import '/models/question_catalog/answer_definition.dart';
import '/models/stop_photo.dart';
import 'question_input_widget.dart';

class PhotoInput extends QuestionInputWidget<PhotoAnswerDefinition, PhotoAnswer> {
  final MapFeatureRepresentation target;
  final Future<StopPhotoStore> Function() openStore;

  const PhotoInput({
    required super.definition,
    required PhotoAnswerController controller,
    required this.target,
    required this.openStore,
    super.key,
  }) : super(controller: controller);

  @override
  Widget build(BuildContext context) => _PhotoInputView(
    definition: definition,
    target: target,
    controller: controller as PhotoAnswerController,
    openStore: openStore,
  );
}

class _PhotoInputView extends StatefulWidget {
  final MapFeatureRepresentation target;
  final PhotoAnswerDefinition definition;
  final PhotoAnswerController controller;
  final Future<StopPhotoStore> Function() openStore;

  const _PhotoInputView({
    required this.definition,
    required this.target,
    required this.controller,
    required this.openStore,
  });

  @override
  State<_PhotoInputView> createState() => _PhotoInputState();
}

class _PhotoInputState extends State<_PhotoInputView> {
  late final _picker = ImagePicker();
  late StopPhotoStore _store;
  bool get _busy => widget.controller.busy;
  String? get _error => widget.controller.message;

  AppLocalizations get _locale => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    // Loading notifies the shared controller, which also rebuilds the dialog.
    // Its ancestor must finish building before we dispatch those notifications.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() => _run(() async {
    _store = await widget.openStore();
    await _refresh();
    if (mounted && _store.recoveryFailed) {
      _setError(_locale.photoCaptureError);
    }
  });

  Future<void> _refresh() async {
    final photos = await _store.load();
    if (!mounted) return;
    widget.controller.answer = PhotoAnswer(definition: widget.definition, value: photos);
  }

  List<StopPhoto> get _answerPhotos => widget.controller.answer?.value ?? const [];

  void _setError(String message) => widget.controller.update(busy: _busy, message: message);

  Future<void> _run(Future<void> Function() operation) async {
    if (!mounted) return;
    widget.controller.update(busy: true);
    try {
      await operation();
    } catch (_) {
      if (mounted) _setError(_locale.photoCaptureError);
    } finally {
      widget.controller.update(busy: false, message: _error);
    }
  }

  Future<void> _capture() => _pickPhoto(ImageSource.camera);

  Future<void> _chooseFromLibrary() => _pickPhoto(ImageSource.gallery);

  Future<void> _pickPhoto(ImageSource source) => _run(() async {
    final target = widget.target;
    final id = const Uuid().v4();
    await _store.prepareCapture(
      StopPhoto(
        id: id,
        osmType: target.type.name,
        osmId: target.id,
        label: target.elementLabel(_locale),
        path: '${_store.directory.path}/$id.jpg',
      ),
    );
    try {
      final image = await _picker.pickImage(source: source, requestFullMetadata: true);
      if (image == null) return;
      await _store.finishCapture(image);
    } on FormatException {
      if (mounted) _setError(_locale.photoMetadataError);
    } finally {
      await _store.cancelCapture();
    }
    await _refresh();
  });

  Future<void> _remove(StopPhoto photo) => _run(() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_locale.photoRemove),
        content: Text(_locale.photoRemoveDescription),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(_locale.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(_locale.photoRemove),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _store.delete(photo);
    await _refresh();
  });

  @override
  Widget build(BuildContext context) => _buildQuestionInput();

  Widget _buildQuestionInput() {
    final photos = _answerPhotos;
    const photoButtonStyle = ButtonStyle(
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Default.borderRadius)),
        ),
      ),
      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
      minimumSize: WidgetStatePropertyAll(Size(0, 48)),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_busy) const LinearProgressIndicator(),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: photoButtonStyle,
                  onPressed: _busy ? null : _capture,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(_locale.photoTakePicture),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  style: photoButtonStyle,
                  onPressed: _busy ? null : _chooseFromLibrary,
                  child: Text(_locale.photoChooseFromLibrary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final photo in photos)
              SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: _busy
                            ? null
                            : () => showDialog<void>(
                                context: context,
                                builder: (_) => Dialog(
                                  child: Image.file(File(photo.path), fit: BoxFit.contain),
                                ),
                              ),
                        child: Image.file(
                          File(photo.path),
                          fit: BoxFit.cover,
                          semanticLabel: photo.label,
                          errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton.filled(
                        tooltip: _locale.photoRemove,
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: _busy ? null : () => _remove(photo),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        if (_error != null)
          Semantics(
            liveRegion: true,
            child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
      ],
    );
  }
}
