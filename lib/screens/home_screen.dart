import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:musikat_web_admin/controller/auth_controller.dart';
import 'package:musikat_web_admin/controller/song_controller.dart';
import 'package:musikat_web_admin/models/playlist_model.dart';
import 'package:musikat_web_admin/models/song_model.dart';
import 'package:musikat_web_admin/models/user_model.dart';
import 'package:musikat_web_admin/screens/users/user_info_screen.dart';
import 'package:musikat_web_admin/utils/constants.dart';
import 'package:musikat_web_admin/widgets/custom_container.dart';
import 'package:musikat_web_admin/widgets/overview_cards.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? user;
  final AuthController _auth = AuthController();
  final SongController _song = SongController();

  @override
  void initState() {
    UserModel.fromUid(uid: FirebaseAuth.instance.currentUser!.uid)
        .then((value) {
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title(),
              Row(children: [
                totalUsers(),
                totalSongs(),
                totalPlaylists(),
              ]),
              allSongs(),
              allUsers(),
            ],
          ),
        ),
      ),
    );
  }

  Padding allUsers() {
    return Padding(
      padding: const EdgeInsets.only(left: 30, top: 10, bottom: 10),
      child: StreamBuilder<List<UserModel>>(
          stream: _auth.getUsers(),
          builder:
              (BuildContext context, AsyncSnapshot<List<UserModel>> snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return Container();
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            } else {
              List<UserModel> users = snapshot.data!;
              users = users
                  .where((user) =>
                      user.uid != FirebaseAuth.instance.currentUser!.uid)
                  .toList();

              return users.isEmpty
                  ? const SizedBox(
                      height: 180,
                      child: Center(
                        child: Text(
                          'No users found...',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Users',
                          style: buttonStyle,
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: users.map((user) {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => UserInfoScreen(
                                                selectedUser: user.uid,
                                              )));
                                },
                                child: CustomContainer(
                                  url: user.profileImage,
                                  title: user.username,
                                  subtitle: user.email,
                                  extraText: DateFormat("MMMM dd, yyyy").format(
                                    user.created.toDate(),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
            }
          }),
    );
  }

  Padding allSongs() {
    return Padding(
      padding: const EdgeInsets.only(left: 30, top: 10, bottom: 10),
      child: StreamBuilder<List<SongModel>>(
          stream: _song.getSongs(),
          builder:
              (BuildContext context, AsyncSnapshot<List<SongModel>> snapshot) {
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
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Songs',
                          style: buttonStyle,
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: songs.map((song) {
                              return CustomContainer(
                                url: song.albumCover,
                                title: song.title,
                                subtitle: song.artist,
                                extraText: DateFormat("MMMM dd, yyyy").format(
                                  song.createdAt,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
            }
          }),
    );
  }

  Padding totalPlaylists() {
    return Padding(
      padding: const EdgeInsets.only(left: 30, top: 5, bottom: 20),
      child: StreamBuilder(
          stream: _song.getPlaylistStream(),
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
              int playlists = snapshot.data!.length;

              return OverviewCard(
                  icon: Icons.queue_music,
                  title: '$playlists',
                  subtitle: 'Total Playlists');
            }
          }),
    );
  }

  Padding totalSongs() {
    return Padding(
      padding: const EdgeInsets.only(left: 30, top: 5, bottom: 20),
      child: StreamBuilder(
          stream: _song.getSongs(),
          builder:
              (BuildContext context, AsyncSnapshot<List<SongModel>> snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return Container();
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            } else {
              int songs = snapshot.data!.length;

              return OverviewCard(
                  icon: FontAwesomeIcons.music,
                  title: '$songs',
                  subtitle: 'Total Songs');
            }
          }),
    );
  }

  Padding totalUsers() {
    return Padding(
      padding: const EdgeInsets.only(left: 30, top: 5, bottom: 20),
      child: StreamBuilder(
          stream: _auth.getUsers(),
          builder:
              (BuildContext context, AsyncSnapshot<List<UserModel>> snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return Container();
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            } else {
              int users = snapshot.data!.length;

              return OverviewCard(
                  icon: FontAwesomeIcons.users,
                  title: '$users',
                  subtitle: 'Total Users');
            }
          }),
    );
  }

  Padding title() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Text(
        'Welcome, ${user?.firstName ?? ''}!',
        style: welcomeStyle,
      ),
    );
  }
}
