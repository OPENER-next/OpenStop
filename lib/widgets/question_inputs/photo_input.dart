import 'dart:async';

import 'package:flutter/material.dart';

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

  List<PanoramaxPhoto> get _answerPhotos => controller.answer?.value ?? const [];

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final photos = _answerPhotos;
    final enabled = photos.length < definition.input.max;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (photos.isNotEmpty)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              childAspectRatio: 1,
              children: [
                for (final photo in photos)
                  _PhotoItem(photo: photo, onRemove: () => _removePhoto(photo)),
              ],
            ),
          Row(
            spacing: 15,
            children: [
              Expanded(
                child: _BusyButton(
                  icon: Icons.add_a_photo_rounded,
                  label: locale.photoTakePicture,
                  onPressed: enabled ? () => _takePhoto(context) : null,
                ),
              ),
              Expanded(
                child: _BusyButton(
                  icon: Icons.folder_open_rounded,
                  label: locale.photoChooseFromLibrary,
                  onPressed: enabled ? () => _selectPhoto(context) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _takePhoto(BuildContext context) async {
    final locale = AppLocalizations.of(context)!;
    try {
      final photo = await PanoramaxPhoto.takePhoto();
      if (photo == null) return;
      if (!context.mounted) {
        return unawaited(photo.deleteFromDisk());
      }
      _addPhoto(photo);
    } catch (_) {
      unawaited(_showError(context, locale.photoCaptureError));
    }
  }

  Future<void> _selectPhoto(BuildContext context) async {
    final locale = AppLocalizations.of(context)!;
    try {
      final photo = await PanoramaxPhoto.selectPhoto();
      if (photo == null) return;
      if (!context.mounted) {
        return unawaited(photo.deleteFromDisk());
      }
      if (_answerPhotos.any(photo.isDuplicateOf)) {
        return unawaited(
          Future.wait([
            _showError(context, AppLocalizations.of(context)!.photoAlreadyAddedError),
            photo.deleteFromDisk(),
          ]),
        );
      }
      _addPhoto(photo);
    } on MissingLocationException {
      unawaited(_showError(context, locale.photoMissingLocationError));
    } on UnsupportedFileTypeException {
      unawaited(_showError(context, locale.photoUnsupportedFileTypeError));
    } catch (_) {
      unawaited(_showError(context, locale.photoCaptureError));
    }
  }

  void _addPhoto(PanoramaxPhoto photo) {
    controller.answer = PhotoAnswer(
      definition: definition,
      value: [..._answerPhotos, photo],
    );
  }

  Future<void> _removePhoto(PanoramaxPhoto photo) async {
    controller.answer = PhotoAnswer(
      definition: definition,
      value: _answerPhotos.where((item) => item.id != photo.id).toList(),
    );
    await photo.deleteFromDisk();
  }

  Future<void> _showError(BuildContext context, String message) async {
    if (context.mounted) {
      await showDialog<void>(
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
    }
  }
}

class _BusyButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Future<void> Function()? onPressed;

  const _BusyButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  State<_BusyButton> createState() => _BusyButtonState();
}

class _BusyButtonState extends State<_BusyButton> {
  bool _busy = false;

  Future<void> _run() async {
    setState(() => _busy = true);
    try {
      await widget.onPressed!();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canInteract = widget.onPressed != null && !_busy;

    return FilledButton.icon(
      onPressed: canInteract ? _run : null,
      icon: Icon(widget.icon),
      label: Text(
        widget.label,
        overflow: .fade,
        softWrap: false,
      ),
    );
  }
}

class _PhotoItem extends StatelessWidget {
  final PanoramaxPhoto photo;
  final VoidCallback onRemove;

  const new({required this.photo, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final buttonShape = theme.outlinedButtonTheme.style?.shape?.resolve({});
    final borderRadius = buttonShape is RoundedRectangleBorder
        ? buttonShape.borderRadius.resolve(Directionality.of(context))
        : BorderRadius.zero;

    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, right: 20),
          child: DecoratedBox(
            position: .foreground,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border.all(
                color: theme.colorScheme.primary, // Border color
                width: 1.0, // Border thickness
              ),
            ),
            child: ClipRRect(
              borderRadius: borderRadius,
              child: HeroViewer(
                tag: photo.id,
                openOn: InteractionTrigger.tap,
                child: Image.file(
                  photo.file,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: .topRight,
          child: IconButton.filled(
            style: IconButton.styleFrom(
              shape: const CircleBorder(),
            ),
            visualDensity: VisualDensity.comfortable,
            tooltip: locale?.photoRemove,
            icon: const Icon(Icons.remove),
            onPressed: onRemove,
          ),
        ),
      ],
    );
  }
}
