import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:musikat_web_admin/app.dart';
import 'package:musikat_web_admin/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

