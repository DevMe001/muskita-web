import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:musikat_web_admin/controller/song_controller.dart';
import 'package:musikat_web_admin/models/playlist_model.dart';
import 'package:musikat_web_admin/screens/playlists/create_playlists_screen.dart';
import 'package:musikat_web_admin/screens/playlists/playlist_detail.dart';
import 'package:musikat_web_admin/utils/constants.dart';
import 'package:musikat_web_admin/widgets/custom_container.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final SongController _songCon = SongController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: Text(
                'Playlists',
                style: welcomeStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreatePlaylistScreen()));
                },
                child: Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xff353434),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 50),
                      Text(
                        'Create a playlist',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                              playlist.uid ==
                              FirebaseAuth.instance.currentUser!.uid)
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
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PlaylistDetailScreen(
                                                      playlist: playlist)));
                                    },
                                    child: CustomContainer(
                                      url: playlist.playlistImg,
                                      title: playlist.title,
                                      subtitle: playlist.description!,
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                    }
                  }),
            ),
          ],
        ),
      )),
    );
  }
}
