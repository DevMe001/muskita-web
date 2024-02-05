import 'package:flutter/material.dart';
import 'package:musikat_web_admin/utils/constants.dart';

class DisplayTiles extends StatelessWidget {
  const DisplayTiles({
    Key? key,
    required this.text,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  final String text;
  final Function()? onTap, onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Material(
          elevation: 4,
          shadowColor: Colors.grey,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 50,
            width: 100,
            decoration: BoxDecoration(
              color: musikatColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                text,
                style: sloganStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
