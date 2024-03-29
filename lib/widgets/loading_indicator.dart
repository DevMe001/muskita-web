import 'package:flutter/material.dart';
import 'package:musikat_web_admin/utils/constants.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 64,
      height: 64,
      child: CircularProgressIndicator(
        backgroundColor: musikatColor2,
        valueColor: AlwaysStoppedAnimation(
          musikatColor,
        ),
        strokeWidth: 10,
      ),
    );
  }
}