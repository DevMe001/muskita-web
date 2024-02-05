// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:musikat_web_admin/controller/song_controller.dart';
import 'package:musikat_web_admin/models/playlist_model.dart';
import 'package:musikat_web_admin/models/song_model.dart';
import 'package:musikat_web_admin/utils/constants.dart';
import 'package:musikat_web_admin/widgets/custom_appbar.dart';
import 'package:musikat_web_admin/widgets/custom_dialog.dart';
import 'package:musikat_web_admin/widgets/loading_indicator.dart';
import 'package:musikat_web_admin/widgets/toast_msg.dart';

class PlaylistDetailScreen extends StatefulWidget {
  const PlaylistDetailScreen({super.key, required this.playlist});
  final PlaylistModel playlist;

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  final SongController _songCon = SongController();
  TextEditingController searchController = TextEditingController();

  List<SongModel> _songs = [];
  List<SongModel> _filteredSongs = [];

  @override
  void initState() {
    super.initState();
    _subscribeToSongs();
  }

  void _subscribeToSongs() {
    _songCon.getSongs().listen((List<SongModel>? songs) {
      if (songs != null) {
        setState(() {
          _songs = songs;
          _filteredSongs = songs;
        });
      }
    }, onError: (error) {});
  }

  @override
  void dispose() {
    _songCon.dispose();
    super.dispose();
  }

  void _filterSongs(String searchTerm) {
    setState(() {
      if (searchTerm.isEmpty) {
        _filteredSongs = _songs;
      } else {
        _filteredSongs = _songs.where((song) {
          final title = song.title.toLowerCase();
          final artist = song.artist.toLowerCase();
          final searchLower = searchTerm.toLowerCase();
          return title.contains(searchLower) || artist.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      appBar: CustomAppBar(
        title: Text(
          widget.playlist.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 40, right: 20, top: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 10, right: 20),
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(
                                widget.playlist.playlistImg),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.playlist.title,
                            style: welcomeStyle,
                          ),
                          Text(widget.playlist.description ?? '...',
                              style: const TextStyle(
                                fontSize: 12,
                                height: 2,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              )),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: StreamBuilder<List<SongModel>>(
                        stream: _songCon
                            .getSongsForPlaylist(widget.playlist.playlistId),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<SongModel>> snapshot) {
                          if (!snapshot.hasData || snapshot.data == null) {
                            return Container();
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: LoadingIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else {
                            List<SongModel> songs = snapshot.data!;

                            return songs.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No songs in the playlist for now.',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: songs.length,
                                    itemBuilder: (context, index) {
                                      SongModel song = songs[index];

                                      return ListTile(
                                        onTap: () async {
                                          try {
                                            await _songCon
                                                .removeSongFromPlaylist(
                                                    widget.playlist.playlistId,
                                                    song.songId);
                                            ToastMessage.show(context,
                                                'Song remove from playlist');
                                          } catch (e) {
                                            ToastMessage.show(context,
                                                'Failed to remove song from playlist');
                                          }
                                        },
                                        title: Text(song.title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            )),
                                        subtitle: Text(song.artist,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            )),
                                        leading: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: CachedNetworkImageProvider(
                                                  song.albumCover),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                          }
                        }),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  height: 50,
                  width: 400,
                  child: SearchBar(
                    controller: searchController,
                    onChanged: _filterSongs,
                    hintText: 'Search',
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredSongs.length,
                    itemBuilder: (context, index) {
                      final song = _filteredSongs[index];

                      return ListTile(
                        title: Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          song.artist,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image:
                                  CachedNetworkImageProvider(song.albumCover),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.add,
                            color: Colors.grey,
                          ),
                          onPressed: () async {
                            try {
                              await _songCon.addSongToPlaylist(
                                  widget.playlist.playlistId, song.songId);
                              ToastMessage.show(
                                  context, 'Song added to playlist');
                            } catch (e) {
                              ToastMessage.show(
                                  context, 'Failed to add song to playlist');
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
