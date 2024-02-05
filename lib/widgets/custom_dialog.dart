import 'package:flutter/material.dart';
import 'package:musikat_web_admin/utils/constants.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    super.key,
    this.controller,
    required this.title,

    this.actions, this.content,
  });

  final TextEditingController? controller;
  final String title;
  final Widget? content;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: musikatBackgroundColor,
      title: Text(
        title,
        style: sloganStyle,
      ),
      content:content,
      actions: actions,
    );
  }
}
