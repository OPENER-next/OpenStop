import 'package:flutter/material.dart';

import '/l10n/app_localizations.g.dart';

class SelectDialog<T> extends StatefulWidget {
  final Map<T, String> valueLabelMap;

  final T? value;

  final Widget? title;

  final String? semanticLabel;

  const SelectDialog({
    required this.valueLabelMap,
    this.value,
    this.title,
    this.semanticLabel,
    super.key,
  });

  @override
  State<SelectDialog<T>> createState() => _SelectDialogState<T>();
}

class _SelectDialogState<T> extends State<SelectDialog<T>> {
  late var _entries = widget.valueLabelMap.entries.toList();

  late T? _selectedValue = widget.value;

  @override
  void didUpdateWidget(covariant SelectDialog<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _entries = widget.valueLabelMap.entries.toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: widget.title,
      semanticLabel: widget.semanticLabel,
      content: RadioGroup(
        groupValue: _selectedValue,
        onChanged: (T? value) {
          setState(() {
            _selectedValue = value;
          });
        },
        // Use column instead of ListView. See: https://github.com/flutter/flutter/issues/18108
        child: Column(
          children: List.generate(_entries.length, (index) {
            final entry = _entries[index];
            return RadioListTile<T>(
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              value: entry.key,
              title: Text(entry.value),
            );
          }),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedValue),
          child: Text(AppLocalizations.of(context)!.confirm),
        ),
      ],
    );
  }
}
