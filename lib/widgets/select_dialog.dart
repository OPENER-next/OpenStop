import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectDialog<T> extends StatefulWidget {
  final Map<T, String> valueLabelMap;

  final T? value;

  final Widget? title;

  const SelectDialog({
    required this.valueLabelMap,
    this.value,
    this.title,
    Key? key
  }) : super(key: key);

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
      // Use column instead of ListView. See: https://github.com/flutter/flutter/issues/18108
      content: Column(
        children: List.generate(_entries.length, (index) {
          final entry = _entries[index];
          return RadioListTile<T>(
            contentPadding: EdgeInsets.zero,
            groupValue: _selectedValue,
            visualDensity: VisualDensity.compact,
            value: entry.key,
            onChanged: (T? value) {
              setState(() {
                _selectedValue = value;
              });
            },
            title: Text(entry.value),
          );
        }),
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
