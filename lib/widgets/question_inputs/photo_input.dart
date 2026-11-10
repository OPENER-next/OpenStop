import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mvvm_architecture/base.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '/commons/themes.dart';
import '/l10n/app_localizations.g.dart';
import '/models/answer.dart';
import '/models/panoramax_photo.dart';
import '/models/question_catalog/answer_definition.dart';
import '/view_models/home_view_model.dart';
import 'question_input_widget.dart';

class PhotoInput extends QuestionInputWidget<PhotoAnswerDefinition, PhotoAnswer> {
  const PhotoInput({
    required super.definition,
    required super.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) => _PhotoInputFragment(
    definition: definition,
    controller: controller,
  );
}

class _PhotoInputFragment extends ViewFragment<HomeViewModel> {
  final PhotoAnswerDefinition definition;
  final AnswerController<PhotoAnswer> controller;
  const _PhotoInputFragment({required this.definition, required this.controller});

  @override
  Widget build(BuildContext context, HomeViewModel viewModel) => _PhotoInputView(
    definition: definition,
    controller: controller,
    semanticLabel:
        viewModel.selectedElement?.elementLabel(AppLocalizations.of(context)!) ??
        AppLocalizations.of(context)!.photoTakePicture,
  );
}

class _PhotoInputView extends StatefulWidget {
  final String semanticLabel;
  final PhotoAnswerDefinition definition;
  final AnswerController<PhotoAnswer> controller;

  const _PhotoInputView({
    required this.semanticLabel,
    required this.definition,
    required this.controller,
  });

  @override
  State<_PhotoInputView> createState() => _PhotoInputState();
}

class _PhotoInputState extends State<_PhotoInputView> {
  late final _picker = ImagePicker();
  bool _busy = false;
  String? _error;

  AppLocalizations get _locale => AppLocalizations.of(context)!;

  void _save(List<PanoramaxPhoto> photos) {
    if (widget.controller.isDisposed) throw StateError('The questionnaire has been discarded');
    widget.controller.answer = PhotoAnswer(definition: widget.definition, value: photos);
  }

  List<PanoramaxPhoto> get _answerPhotos => widget.controller.answer?.value ?? const [];

  void _setError(String message) {
    if (mounted) setState(() => _error = message);
  }

  Future<void> _run(Future<void> Function() operation) async {
    if (!mounted || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await operation();
    } catch (_) {
      if (mounted) _setError(_locale.photoCaptureError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _capture() => _pickPhoto(ImageSource.camera);

  Future<void> _chooseFromLibrary() => _pickPhoto(ImageSource.gallery);

  Future<void> _pickPhoto(ImageSource source) => _run(() async {
    if (_answerPhotos.length >= widget.definition.input.max) return;
    try {
      final support = await getApplicationSupportDirectory();
      final directory = await Directory('${support.path}/stop_photos').create(recursive: true);
      if (!mounted || widget.controller.isDisposed) return;
      final photo = await PanoramaxPhoto.captureWithLocation(
        directory: directory,
        source: source,
        picker: _picker,
      );
      if (photo != null) {
        try {
          if (!mounted || widget.controller.isDisposed) {
            await File(photo.path).delete();
            return;
          }
          _save([..._answerPhotos, photo]);
        } catch (_) {
          await File(photo.path).delete();
          rethrow;
        }
      }
    } on FormatException {
      if (mounted) _setError(_locale.photoMetadataError);
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
    _save(_answerPhotos.where((item) => item.id != photo.id).toList());
    await File(photo.path).delete();
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
                          semanticLabel: widget.semanticLabel,
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
