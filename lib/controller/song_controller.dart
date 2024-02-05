import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:musikat_web_admin/models/playlist_model.dart';
import 'package:musikat_web_admin/models/song_model.dart';

class SongController with ChangeNotifier {
  Stream<List<SongModel>> getSongsStream(String uid) {
    return FirebaseFirestore.instance
        .collection('songs')
        .where('uid', isEqualTo: uid)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((QuerySnapshot querySnapshot) => querySnapshot.docs
            .map((DocumentSnapshot documentSnapshot) =>
                SongModel.fromDocumentSnap(documentSnapshot))
            .toList());
  }

    Stream<List<SongModel>> getSongs() {
    return FirebaseFirestore.instance
        .collection('songs')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((QuerySnapshot querySnapshot) => querySnapshot.docs
            .map((DocumentSnapshot documentSnapshot) =>
                SongModel.fromDocumentSnap(documentSnapshot))
            .toList());
  }

Stream<List<PlaylistModel>> getPlaylistStream() {
  CollectionReference<Map<String, dynamic>> playlistsRef =
      FirebaseFirestore.instance.collection('playlists');

  return playlistsRef
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((querySnapshot) {
    return querySnapshot.docs.map((doc) {
      return PlaylistModel.fromDocumentSnap(doc);
    }).toList();
  });
}


    Stream<List<SongModel>> getSongsForPlaylist(String playlistId) {
    final playlistRef =
        FirebaseFirestore.instance.collection('playlists').doc(playlistId);
    return playlistRef.snapshots().asyncMap((playlistSnap) async {
      final playlist = PlaylistModel.fromDocumentSnap(playlistSnap);

      final songs = <SongModel>[];
      for (final songId in playlist.songs) {
        final songRef =
            FirebaseFirestore.instance.collection('songs').doc(songId);
        final songSnap = await songRef.get();
        final song = SongModel.fromDocumentSnap(songSnap);
        songs.add(song);
      }

      return songs;
    });
  }

    Future<void> addSongToPlaylist(String playlistId, String songId) async {
    DocumentReference playlistRef =
        FirebaseFirestore.instance.collection('playlists').doc(playlistId);
    DocumentSnapshot playlistSnap = await playlistRef.get();
    PlaylistModel playlist = PlaylistModel.fromDocumentSnap(playlistSnap);

    playlist.songs.add(songId);

    await playlistRef.update(playlist.json);
  }

    Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    DocumentReference playlistRef =
        FirebaseFirestore.instance.collection('playlists').doc(playlistId);
    DocumentSnapshot playlistSnap = await playlistRef.get();
    PlaylistModel playlist = PlaylistModel.fromDocumentSnap(playlistSnap);

    playlist.songs.remove(songId);

    await playlistRef.update(playlist.json);
  }

}
