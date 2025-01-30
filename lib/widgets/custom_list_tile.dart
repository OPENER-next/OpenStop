import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final void Function()? onTap;
  final bool isThreeLine;

  const CustomListTile({
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailingIcon,
    this.onTap,
    this.isThreeLine = false,
    super.key
  });


  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      isThreeLine: isThreeLine,
      // used to vertically center the icon
      leading: leadingIcon == null ? null : SizedBox(
        height: double.infinity,
        child: Icon(leadingIcon),
      ),
      trailing: trailingIcon == null ? null : SizedBox(
        height: double.infinity,
        child: Icon(
          trailingIcon,
          size: 16,
          color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.2)
        ),
      ),
      onTap: onTap,
    );
  }
}


class CustomSwitchListTile extends StatelessWidget {
  final bool value;
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final ValueChanged<bool>? onChanged;
  final bool isThreeLine;

  const CustomSwitchListTile({
    required this.value,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.onChanged,
    this.isThreeLine = false,
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      value: value,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      isThreeLine: isThreeLine,
      // used to vertically center the icon
      secondary: leadingIcon == null ? null : SizedBox(
        height: double.infinity,
        child: Icon(leadingIcon),
      ),
      onChanged: onChanged,
    );
  }
}
