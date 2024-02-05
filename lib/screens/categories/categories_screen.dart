import 'package:flutter/material.dart';
import 'package:musikat_web_admin/utils/constants.dart';
import 'package:musikat_web_admin/widgets/custom_cards.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: Text(
                'Categories',
                style: welcomeStyle,
              ),
            ),
            Row(
              children: [
                CustomCards(
                  title: 'Genres',
                  icon: Icons.music_note,
                  onTap: () {
                    Navigator.pushNamed(context, '/drawer/categories/genres');
                  },
                ),
                 CustomCards(
                  title: 'Languages',
                  icon: Icons.language,
                    onTap: () {
                    Navigator.pushNamed(context, '/drawer/categories/languages');
                  },
                ),
               CustomCards(
                  title: 'Moods',
                  icon: Icons.emoji_emotions,
                     onTap: () {
                    Navigator.pushNamed(context, '/drawer/categories/moods');
                  },
                ),
              ],
            ),
          ],
        ),
      )),
    );
  }
}
