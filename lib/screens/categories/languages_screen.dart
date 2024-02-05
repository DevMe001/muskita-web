// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:musikat_web_admin/controller/categories_controller.dart';
import 'package:musikat_web_admin/utils/constants.dart';
import 'package:musikat_web_admin/widgets/custom_appbar.dart';
import 'package:musikat_web_admin/widgets/custom_dialog.dart';
import 'package:musikat_web_admin/widgets/display_tiles.dart';
import 'package:musikat_web_admin/widgets/toast_msg.dart';

class LanguagesScreen extends StatefulWidget {
  const LanguagesScreen({Key? key}) : super(key: key);

  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  final CategoriesController _categoriesCon = CategoriesController();
  TextEditingController searchController = TextEditingController(),
      languageCon = TextEditingController();
  List<String> languages = [];
  List<String> filteredLanguages = [];
  late StreamSubscription<List<String>> _streamSubscription;

  @override
  void initState() {
    super.initState();
    _streamSubscription =
        _categoriesCon.getLanguagesStream().listen((fetchedLanguages) {
      setState(() {
        languages = fetchedLanguages;
        filteredLanguages = languages;
      });
    }, onError: (error) {
      print('Error fetching languages: $error');
      ToastMessage.show(context, 'Error fetching languages: $error');
    });
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      appBar: const CustomAppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 110, right: 30),
            child: Text(
              'Languages',
              style: welcomeStyle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 110),
            child: Text(
              'Different etho-languages of the Philippines',
              style: sideNavStyle,
            ),
          ),
          Row(
            children: [
              searchBar(),
              addLanguageButton(context),
            ],
          ),
          languageList(),
        ],
      ),
    );
  }

  SizedBox addLanguageButton(BuildContext context) {
    return SizedBox(
      height: 35,
      child: ElevatedButton(
        onPressed: () {
          _showAddLanguageDialog(context);
        },
        child: const Row(
          children: [
            Icon(Icons.add),
            SizedBox(
              width: 5,
            ),
            Text('Add Language'),
          ],
        ),
      ),
    );
  }

  Padding searchBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 100, right: 30, top: 10),
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(5),
        width: 400,
        height: 60,
        child: SearchBar(
            hintText: 'Search for a language...',
            controller: searchController,
            onChanged: (value) {
              setState(() {
                filteredLanguages = languages
                    .where((language) =>
                        language.toLowerCase().contains(value.toLowerCase()))
                    .toList();
              });
            }),
      ),
    );
  }

  Expanded languageList() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 80, right: 80),
        child: GridView.count(
          physics: const BouncingScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 9,
          children: List.generate(filteredLanguages.length, (index) {
            return DisplayTiles(
              text: filteredLanguages[index],
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomDialog(
                      title: 'Delete',
                      content: Text(
                        'Are you sure you want to delete this language?',
                        style: sideNavStyle,
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              _categoriesCon
                                  .deleteLanguage(filteredLanguages[index]);
                              Navigator.of(context).pop();
                              ToastMessage.show(
                                  context, 'Language deleted successfully');
                            },
                            child: const Text('Delete')),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel')),
                      ],
                    );
                  },
                );
              },
            );
          }),
        ),
      ),
    );
  }

  void _showAddLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: 'Add Language',
          content: SearchBar(
            hintText: 'Enter language name...',
            controller: languageCon,
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (languageCon.text.isNotEmpty) {
                  _categoriesCon.addLanguage(languageCon.text);
                  Navigator.of(context).pop();
                  languageCon.clear();
                  ToastMessage.show(context, 'Language added successfully');
                } else {
                  ToastMessage.show(context, 'Please enter a language name');
                }
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                languageCon.clear();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
