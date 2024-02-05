import 'package:flutter/material.dart';
import 'package:musikat_web_admin/utils/constants.dart';

class TileList extends StatelessWidget {
  const TileList(
      {Key? key,
      required this.icon,
      required this.title,
      this.ontap,
      this.subtitle})
      : super(key: key);

  final IconData icon;
  final String title;
  final String? subtitle;
  final void Function()? ontap;

 @override
Widget build(BuildContext context) {
  return SizedBox(
    height: 80,
    width: MediaQuery.of(context).size.width * 0.2,
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      color: const Color(0xff353434),
      elevation: 4, 
      shadowColor: Colors.black.withOpacity(0.5),
      child: Center(
        child: ListTile(
          onTap: ontap,
          leading: CircleAvatar(
            backgroundColor: musikatColor2,
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 15, color: Colors.white),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                )
              : null,
        ),
      ),
    ),
  );
}
}