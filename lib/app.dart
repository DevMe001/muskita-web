import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:musikat_web_admin/screens/categories/genres_screen.dart';
import 'package:musikat_web_admin/screens/categories/languages_screen.dart';
import 'package:musikat_web_admin/screens/categories/moods_screen.dart';
import 'package:musikat_web_admin/screens/login_screen.dart';
import 'package:musikat_web_admin/utils/constants.dart';
import 'package:musikat_web_admin/widgets/custom_drawer.dart';
import 'package:musikat_web_admin/widgets/loading_indicator.dart';
import 'package:musikat_web_admin/utils/scroll_behavior.dart';

class MyApp extends StatelessWidget {
 
  const MyApp({
    Key? key,
  }) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       scrollBehavior: MyCustomScrollBehavior(),
      restorationScopeId: 'app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData().copyWith(
        colorScheme: ThemeData().colorScheme.copyWith(
              primary: musikatColor2,
            ),
      ),
      builder: (context, Widget? child) => child as Widget,
      title: 'MuSikat',
      home: FutureBuilder<bool>(
        future: isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final isLoggedIn = snapshot.data;
            if (isLoggedIn!) {
              return const CustomDrawer();
            } else {
              return const LoginScreen();
            }
          } else {
            return const LoadingIndicator();
          }
        },
      ),
      
      routes: {
        '/login': (context) => const LoginScreen(),
        '/drawer': (context) => const CustomDrawer(),
        '/drawer/categories/genres': (context) => const GenresScreen(),
        '/drawer/categories/languages': (context) => const LanguagesScreen(),
        '/drawer/categories/moods': (context) => const MoodsScreen(),
       
      },
    );
  }

  Future<bool> isLoggedIn() async {
    final user = FirebaseAuth.instance.currentUser;
    return user != null;
  }
}
