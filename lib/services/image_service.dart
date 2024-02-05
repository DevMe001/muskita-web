// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:musikat_web_admin/widgets/toast_msg.dart';

import '../models/user_model.dart';

class ImageService {
  static updateProfileImage(BuildContext context) async {
    try {
      final html.FileUploadInputElement input = html.FileUploadInputElement();
      input.accept = 'image/*';
      input.click();

      await input.onChange.first;

      final file = input.files!.first;
      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      final DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final UserModel user = UserModel.fromDocumentSnap(userSnapshot);
      final String username = user.username;

      final ref = FirebaseStorage.instance.ref();

      final profileRef = ref.child(
        'users/$username/profileImage/${file.name}',
      );

      print(profileRef.fullPath);
      print(file.name);

      final task = profileRef.putBlob(file);
      final snapshot = await task;

      final publicUrl = await snapshot.ref.getDownloadURL();
      print(publicUrl);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'profileImage': publicUrl});

      ToastMessage.show(context, 'Profile image updated successfully');
    } catch (e) {
      ToastMessage.show(context, 'Upload failed');
    }
  }
}
