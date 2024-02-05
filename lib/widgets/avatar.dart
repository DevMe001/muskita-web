import 'package:flutter/material.dart';
import 'package:musikat_web_admin/models/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:musikat_web_admin/utils/constants.dart';

class AvatarImage extends StatelessWidget {
  final String uid;
  final double radius;
  const AvatarImage({required this.uid, this.radius = 22, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel>(
        stream: UserModel.fromUidStream(uid: uid),
        builder: (context, AsyncSnapshot<UserModel?> snap) {
          if (snap.error != null || !snap.hasData) {
            return tempProfile(context);
          } else {
            if (snap.data!.profileImage.isEmpty) {
              return tempProfile(context);
            } else if (snap.connectionState == ConnectionState.waiting) {
              return tempProfile(context);
            } else {
              return FittedBox(
                child: CircleAvatar(
                  backgroundColor: musikatBackgroundColor,
                  radius: radius,
                  backgroundImage: CachedNetworkImageProvider(
                    snap.data!.profileImage,
                  ),
                ),
              );
            }
          }
        });
  }

  Widget tempProfile(BuildContext context) {
    return FittedBox(
      child: CircleAvatar(
        radius: radius,
        backgroundImage: const NetworkImage(
            'https://us.123rf.com/450wm/soloviivka/soloviivka1606/soloviivka160600001/59688426-music-note-vector-icon-white-on-black-background.jpg',
            scale: 1.0),
      ),
    );
  }
}
