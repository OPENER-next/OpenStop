import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '/api/photo_capture_store.dart';
import '/commons/themes.dart';
import '/l10n/app_localizations.g.dart';
import '/models/answer.dart';
import '/models/panoramax_photo.dart';
import '/models/question_catalog/answer_definition.dart';
import 'question_input_widget.dart';

class PhotoInput extends QuestionInputWidget<PhotoAnswerDefinition, PhotoAnswer> {
  final Future<PhotoCaptureStore> Function()? openStore;

  const PhotoInput({
    required super.definition,
    required PhotoAnswerController controller,
    this.openStore,
    super.key,
  }) : super(controller: controller);

  @override
  Widget build(BuildContext context) => _PhotoInputView(
    definition: definition,
    controller: controller as PhotoAnswerController,
    openStore: openStore,
  );
}

class _PhotoInputView extends StatefulWidget {
  final PhotoAnswerDefinition definition;
  final PhotoAnswerController controller;
  final Future<PhotoCaptureStore> Function()? openStore;

  const _PhotoInputView({
    required this.definition,
    required this.controller,
    this.openStore,
  });

  @override
  State<_PhotoInputView> createState() => _PhotoInputState();
}

class _PhotoInputState extends State<_PhotoInputView> {
  late final _picker = ImagePicker();
  late PhotoCaptureStore _store;
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
    _store = await (widget.openStore ?? PhotoCaptureStore.open)();
    final reference = widget.controller.osmReference;
    if (reference == null) return;
    final recovered = PhotoCaptureStore.recoveredFor(reference);
    if (recovered.isNotEmpty) {
      await _save([
        ..._answerPhotos,
        ...recovered.where((photo) => !_answerPhotos.any((item) => item.id == photo.id)),
      ]);
      PhotoCaptureStore.acknowledgeRecovered(reference, recovered);
    }
    if (mounted && PhotoCaptureStore.takeRecoveryError(reference)) {
      _setError(_locale.photoCaptureError);
    }
  });

  Future<void> _save(List<PanoramaxPhoto> photos) async {
    if (widget.controller.isDisposed) throw StateError('The questionnaire has been discarded');
    final previous = widget.controller.answer;
    widget.controller.answer = PhotoAnswer(definition: widget.definition, value: photos);
    try {
      if (!await widget.controller.persist()) {
        throw StateError('The questionnaire has been discarded');
      }
    } catch (_) {
      widget.controller.answer = previous;
      rethrow;
    }
  }

  List<PanoramaxPhoto> get _answerPhotos => widget.controller.answer?.value ?? const [];

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
    if (_answerPhotos.length >= widget.definition.input.max) return;
    try {
      final photo = await PanoramaxPhoto.captureWithLocation(
        directory: _store.directory,
        source: source,
        picker: _picker,
        onCaptureStarted: (photo) => _store.prepareCapture(
          photo,
          osmReference:
              widget.controller.osmReference ?? (throw StateError('No questionnaire target')),
        ),
      );
      if (photo != null) {
        try {
          await _save([..._answerPhotos, photo]);
        } catch (_) {
          await _store.delete(photo);
          rethrow;
        }
      }
    } on FormatException {
      if (mounted) _setError(_locale.photoMetadataError);
    } finally {
      await _store.cancelCapture();
    }
  });

  Future<void> _remove(PanoramaxPhoto photo) => _run(() async {
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
    await _save(_answerPhotos.where((item) => item.id != photo.id).toList());
    await _store.delete(photo);
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
                  onPressed: _busy || photos.length >= widget.definition.input.max
                      ? null
                      : _capture,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(_locale.photoTakePicture),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  style: photoButtonStyle,
                  onPressed: _busy || photos.length >= widget.definition.input.max
                      ? null
                      : _chooseFromLibrary,
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
                          semanticLabel: widget.controller.label ?? _locale.photoTakePicture,
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
