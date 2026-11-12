import 'dart:io';

import 'package:flutter/material.dart';

import '/commons/themes.dart';
import '/l10n/app_localizations.g.dart';
import '/models/answer.dart';
import '/models/panoramax_photo.dart';
import '/models/question_catalog/answer_definition.dart';
import '/widgets/hero_viewer.dart';
import 'question_input_widget.dart';

class PhotoInput extends QuestionInputWidget<PhotoAnswerDefinition, PhotoAnswer> {
  const PhotoInput({
    required super.definition,
    required super.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) => _PhotoInputView(
    definition: definition,
    controller: controller,
  );
}

class _PhotoInputView extends StatefulWidget {
  final PhotoAnswerDefinition definition;
  final AnswerController<PhotoAnswer> controller;

  const _PhotoInputView({required this.definition, required this.controller});

  @override
  State<_PhotoInputView> createState() => _PhotoInputState();
}

class _PhotoInputState extends State<_PhotoInputView> {
  bool _busy = false;

  AppLocalizations get _locale => AppLocalizations.of(context)!;

  void _save(List<PanoramaxPhoto> photos) {
    if (widget.controller.isDisposed) throw StateError('The questionnaire has been discarded');
    widget.controller.answer = PhotoAnswer(definition: widget.definition, value: photos);
  }

  List<PanoramaxPhoto> get _answerPhotos => widget.controller.answer?.value ?? const [];

  Future<void> _showError(String message) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    ),
  );

  Future<void> _run(Future<void> Function() operation) async {
    if (!mounted || _busy) return;
    setState(() => _busy = true);
    try {
      await operation();
    } on FormatException {
      if (mounted) await _showError(_locale.photoMetadataError);
    } catch (_) {
      if (mounted) await _showError(_locale.photoCaptureError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickPhoto(Future<PanoramaxPhoto?> Function() pick) => _run(() async {
    if (_answerPhotos.length >= widget.definition.input.max) return;
    final photo = await pick();
    if (photo == null) return;
    if (!mounted || widget.controller.isDisposed) {
      await photo.deleteFromDisk();
      return;
    }
    try {
      _save([..._answerPhotos, photo]);
    } catch (_) {
      await photo.deleteFromDisk();
      rethrow;
    }
  });

  Future<void> _remove(PanoramaxPhoto photo) => _run(() async {
    _save(_answerPhotos.where((item) => item.id != photo.id).toList());
    await photo.deleteFromDisk();
  });

  @override
  Widget build(BuildContext context) {
    final photos = _answerPhotos;
    final canAdd = !_busy && photos.length < widget.definition.input.max;
    final theme = Theme.of(context);
    final buttonStyle = FilledButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Default.borderRadius)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      minimumSize: const Size(0, 48),
      textStyle: theme.textTheme.bodyLarge,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_busy) const LinearProgressIndicator(),
        LayoutBuilder(
          builder: (context, constraints) => IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: constraints.maxWidth * 0.45,
                  child: FilledButton.icon(
                    style: buttonStyle,
                    onPressed: canAdd ? () => _pickPhoto(PanoramaxPhoto.takePhoto) : null,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(_locale.photoTakePicture, textAlign: TextAlign.center),
                  ),
                ),
                SizedBox(
                  width: constraints.maxWidth * 0.45,
                  child: OutlinedButton(
                    style: buttonStyle,
                    onPressed: canAdd ? () => _pickPhoto(PanoramaxPhoto.selectPhoto) : null,
                    child: Text(_locale.photoChooseFromLibrary, textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (photos.isNotEmpty) ...[
          const SizedBox(height: Default.padding),
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
                        borderRadius: BorderRadius.circular(Default.borderRadius),
                        child: HeroViewer(
                          tag: photo.id,
                          openOn: _busy ? InteractionTrigger.none : InteractionTrigger.tap,
                          child: Image.file(
                            File(photo.path),
                            fit: BoxFit.cover,
                            semanticLabel: _locale.photoTakePicture,
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
        ],
      ],
    );
  }
}
