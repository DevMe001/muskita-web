import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:musikat_web_admin/controller/song_controller.dart';
import 'package:musikat_web_admin/models/playlist_model.dart';
import 'package:musikat_web_admin/models/song_model.dart';
import 'package:musikat_web_admin/models/user_model.dart';
import 'package:musikat_web_admin/utils/constants.dart';
import 'package:musikat_web_admin/widgets/avatar.dart';
import 'package:musikat_web_admin/widgets/custom_appbar.dart';
import 'package:musikat_web_admin/widgets/custom_container.dart';
import 'package:musikat_web_admin/widgets/tile_list.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key, required this.selectedUser});
  final String selectedUser;

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final SongController _songCon = SongController();

  UserModel? user;
  @override
  void initState() {
    UserModel.fromUid(uid: widget.selectedUser).then((value) {
      if (mounted) {
        setState(() {
          user = value;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: musikatBackgroundColor,
        appBar: const CustomAppBar(),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 110, right: 30),
                child: Text(
                  'User info',
                  style: welcomeStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 110, right: 110, top: 30, bottom: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 60, right: 30),
                          child: AvatarImage(
                            uid: widget.selectedUser,
                            radius: 100,
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.only(left: 50),
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: 310,
                            child: GridView.count(
                              crossAxisCount: 2,
                              childAspectRatio: 5,
                              children: [
                                TileList(
                                  icon: Icons.card_giftcard,
                                  title: 'User ID',
                                  subtitle: widget.selectedUser,
                                ),
                                TileList(
                                  icon: Icons.verified_user,
                                  title: 'Username',
                                  subtitle: user?.username ?? '',
                                ),
                                TileList(
                                  icon: Icons.abc,
                                  title: 'Name',
                                  subtitle:
                                      '${user?.firstName} ${user?.lastName}',
                                ),
                                TileList(
                                  icon: Icons.email,
                                  title: 'Email',
                                  subtitle: user?.email ?? '',
                                ),
                                TileList(
                                  icon: Icons.male,
                                  title: 'Gender',
                                  subtitle: user?.gender ?? '',
                                ),
                                TileList(
                                  icon: Icons.numbers,
                                  title: 'Age',
                                  subtitle: user?.age ?? '',
                                ),
                                TileList(
                                  icon: Icons.calendar_month,
                                  title: 'Date created',
                                  subtitle: user?.created == null
                                      ? ''
                                      : DateFormat("MMMM dd, yyyy").format(
                                          user!.created.toDate(),
                                        ),
                                ),
                                TileList(
                                  icon: Icons.account_box,
                                  title: 'Account type',
                                  subtitle: user?.accountType ?? '',
                                ),
                                TileList(
                                    icon: FontAwesomeIcons.userShield,
                                    title: 'Followers',
                                    subtitle:
                                        user?.followers.length.toString() ??
                                            '0'),
                                TileList(
                                    icon: FontAwesomeIcons.userShield,
                                    title: 'Followings',
                                    subtitle:
                                        user?.followings.length.toString() ??
                                            '0'),
                              ],
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 110, right: 30, top: 30),
                child: Text(
                  'Library',
                  style: welcomeStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 100, right: 110, top: 20, bottom: 20),
                child: StreamBuilder<List<SongModel>>(
                    stream: _songCon.getSongsStream(widget.selectedUser),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<SongModel>> snapshot) {
                      if (!snapshot.hasData || snapshot.data == null) {
                        return Container();
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      } else {
                        final songs = snapshot.data!;

                        return songs.isEmpty
                            ? const SizedBox(
                                height: 180,
                                child: Center(
                                  child: Text(
                                    'No songs found...',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: songs.map((song) {
                                    return CustomContainer(
                                      url: song.albumCover,
                                      title: song.title,
                                      subtitle: song.artist,
                                    );
                                  }).toList(),
                                ),
                              );
                      }
                    }),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 110, right: 30, top: 30),
                child: Text(
                  'Playlists',
                  style: welcomeStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 100, right: 110, top: 20, bottom: 20),
                child: StreamBuilder<List<PlaylistModel>>(
                    stream: _songCon.getPlaylistStream(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<PlaylistModel>> snapshot) {
                      if (!snapshot.hasData || snapshot.data == null) {
                        return Container();
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      } else {
                        final playlists = snapshot.data!
                            .where((playlist) =>
                                playlist.uid == widget.selectedUser)
                            .toList();

                        return playlists.isEmpty
                            ? const SizedBox(
                                height: 180,
                                child: Center(
                                  child: Text(
                                    'No playlists found...',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: playlists.map((playlist) {
                                    return CustomContainer(
                                      url: playlist.playlistImg,
                                      title: playlist.title,
                                      subtitle: playlist.description!,
                                    );
                                  }).toList(),
                                ),
                              );
                      }
                    }),
              ),
            ],
          ),
        ));
  }
}
