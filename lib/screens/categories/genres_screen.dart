// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:musikat_web_admin/controller/categories_controller.dart';
import 'package:musikat_web_admin/utils/constants.dart';
import 'package:musikat_web_admin/widgets/custom_appbar.dart';
import 'package:musikat_web_admin/widgets/custom_dialog.dart';
import 'package:musikat_web_admin/widgets/display_tiles.dart';
import 'package:musikat_web_admin/widgets/toast_msg.dart';

class GenresScreen extends StatefulWidget {
  const GenresScreen({Key? key}) : super(key: key);

  @override
  State<GenresScreen> createState() => _GenresScreenState();
}

class _GenresScreenState extends State<GenresScreen> {
  final CategoriesController _categoriesCon = CategoriesController();
  TextEditingController searchController = TextEditingController(),
      genreCon = TextEditingController();
  List<String> genres = [];
  List<String> filteredGenres = [];
  late StreamSubscription<List<String>> _streamSubscription;

  @override
  void initState() {
    super.initState();
    _streamSubscription =
        _categoriesCon.getGenresStream().listen((fetchedGenres) {
      setState(() {
        genres = fetchedGenres;
        filteredGenres = genres;
      });
    }, onError: (error) {
      print('Error fetching genres: $error');
      ToastMessage.show(context, 'Error fetching genres: $error');
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
              'Genres',
              style: welcomeStyle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 110),
            child: Text(
              'Different genres that might suit the listener\'s taste.',
              style: sideNavStyle,
            ),
          ),
          Row(
            children: [
              searchBar(),
              addGenreButton(context),
            ],
          ),
          genreList(),
        ],
      ),
    );
  }

  SizedBox addGenreButton(BuildContext context) {
    return SizedBox(
      height: 35,
      child: ElevatedButton(
        onPressed: () {
          _showAddGenreDialog(context);
        },
        child: const Row(
          children: [
            Icon(Icons.add),
            SizedBox(
              width: 5,
            ),
            Text('Add Genre'),
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
            hintText: 'Search for a genre...',
            controller: searchController,
            onChanged: (value) {
              setState(() {
                filteredGenres = genres
                    .where((genre) =>
                        genre.toLowerCase().contains(value.toLowerCase()))
                    .toList();
              });
            }),
      ),
    );
  }

  Expanded genreList() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 80, right: 80),
        child: GridView.count(
          physics: const BouncingScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 9,
          children: List.generate(filteredGenres.length, (index) {
            return DisplayTiles(
              text: filteredGenres[index],
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomDialog(
                      title: 'Delete',
                      content: Text(
                        'Are you sure you want to delete this genre?',
                        style: sideNavStyle,
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              _categoriesCon.deleteGenre(filteredGenres[index]);
                              Navigator.of(context).pop();
                              ToastMessage.show(
                                  context, 'Genre deleted successfully');
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

  void _showAddGenreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: 'Add Genre',
          content: SearchBar(
            hintText: 'Enter genre name...',
            controller: genreCon,
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (genreCon.text.isNotEmpty) {
                  _categoriesCon.addGenre(genreCon.text);
                  Navigator.of(context).pop();
                  genreCon.clear();
                  ToastMessage.show(context, 'Genre added successfully');
                } else {
                  ToastMessage.show(context, 'Please enter a genre name');
                }
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                genreCon.clear();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
