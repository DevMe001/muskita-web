// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:musikat_web_admin/models/playlist_model.dart';
import 'package:musikat_web_admin/models/user_model.dart';
import 'package:musikat_web_admin/widgets/loading_indicator.dart';
import 'package:musikat_web_admin/widgets/toast_msg.dart';
import 'dart:html' as html;

class PlaylistService {
  static Future<void> createPlaylist(
    BuildContext context,
    TextEditingController titleCon,
    TextEditingController descriptionCon,
    html.File? selectedPlaylistCover,
    String? selectedGenre,
  ) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentReference playlistRef = firestore.collection('playlists').doc();

      final String title = titleCon.text.trim();
      final String description = descriptionCon.text.trim();
      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      final DateTime createdAt = DateTime.now();

      final DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final UserModel user = UserModel.fromDocumentSnap(userSnapshot);
      final String username = user.username;

      String playlistImg = '';
      if (selectedPlaylistCover != null) {
        final String fileName = selectedPlaylistCover.name;

        final Reference storageRef = FirebaseStorage.instance
            .ref('users/$username/playlistCover/$fileName');

        final UploadTask uploadTask = storageRef.putBlob(selectedPlaylistCover);
        final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

        playlistImg = await taskSnapshot.ref.getDownloadURL();
      }

      if (title.isEmpty) {
        ToastMessage.show(context, 'Please enter a title for the playlist');
        return;
      }

      if (playlistImg.isEmpty) {
        ToastMessage.show(context, 'Please choose an image for the playlist');
        return;
      }

      final String playlistDescription =
          description.isNotEmpty ? description : '';

      PlaylistModel newPlaylist = PlaylistModel(
        playlistId: playlistRef.id,
        title: title,
        uid: uid ?? '',
        createdAt: createdAt,
        description: playlistDescription,
        playlistImg: playlistImg,
        songs: [],
        isOfficial: true,
        genre: selectedGenre!,
      );

      Map<String, dynamic> json = newPlaylist.json;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: LoadingIndicator());
        },
      );

      await playlistRef.set(json);

      Navigator.pop(context);

      ToastMessage.show(context, 'Playlist created successfully');
    } catch (e) {
      Navigator.pop(context);
      ToastMessage.show(context, 'Error adding playlist: $e');
    }
    Navigator.pop(context);
  }




  static Future<void> editPlaylist(
      BuildContext context,
      PlaylistModel playlist,
      TextEditingController titleCon,
      TextEditingController descriptionCon,
      dynamic selectedPlaylistCover) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: LoadingIndicator());
        },
      );

    
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      final String title = titleCon.text.trim();
      final String description = descriptionCon.text.trim();

      String playlistImg = playlist.playlistImg;
      if (selectedPlaylistCover != null) {
        final String fileName = selectedPlaylistCover!.path.split('/').last;
        final Reference storageRef = FirebaseStorage.instance
            .ref('users/${playlist.uid}/playlistCover/$fileName');

        final UploadTask uploadTask =
            storageRef.putFile(selectedPlaylistCover!);
        final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

        playlistImg = await taskSnapshot.ref.getDownloadURL();
      }

      // Check if the playlist's fields are the same as the existing fields
      if (title == playlist.title &&
          description == playlist.description &&
          playlistImg == playlist.playlistImg) {
        ToastMessage.show(context, 'Playlist details are the same');
        return;
      }

      // Set the title field to the existing title if it's null or empty
      final String playlistTitle = title.isNotEmpty ? title : playlist.title;

      // Set the description field to the existing description if it's null or empty
      final String playlistDescription =
          description.isNotEmpty ? description : playlist.description ?? '';

      // Update the playlist's fields in Firestore
      await firestore.collection('playlists').doc(playlist.playlistId).update({
        'title': playlistTitle,
        'description': playlistDescription,
        'playlistImg': playlistImg,
      });

      ToastMessage.show(context, 'Playlist updated successfully');
    } catch (e) {
      ToastMessage.show(context, 'Error editing playlist: $e');
    } finally {
      Navigator.pop(context);
    }
    Navigator.pop(context);
  }
}
