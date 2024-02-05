// ignore_for_file: avoid_print, avoid_web_libraries_in_flutter
import 'dart:async';

import 'dart:js';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:musikat_web_admin/models/user_model.dart';
import 'package:musikat_web_admin/widgets/toast_msg.dart';

class AuthController with ChangeNotifier {
  Future<UserCredential?> login(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          String? accountType = userDoc.data()?['accountType'] as String?;

          if (accountType == 'Admin') {
            notifyListeners();
            return userCredential;
          } else {
            await FirebaseAuth.instance.signOut();
            ToastMessage.show(
                context as BuildContext, "Only admins can login.");
            return null;
          }
        }
      }

      await FirebaseAuth.instance.signOut();
      ToastMessage.show(context as BuildContext, "User not found.");
      return null;
    } catch (e) {
      print(e.toString());
      ToastMessage.show(context as BuildContext, e.toString());
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  Stream<List<UserModel>> getUsers() {
    return FirebaseFirestore.instance.collection('users').snapshots().map(
      (QuerySnapshot querySnapshot) {
        List<UserModel> users = [];
        for (var doc in querySnapshot.docs) {
          users.add(UserModel.fromDocumentSnap(doc));
        }
        return users;
      },
    );
  }
}
