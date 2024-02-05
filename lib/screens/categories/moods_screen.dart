// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:musikat_web_admin/controller/categories_controller.dart';
import 'package:musikat_web_admin/utils/constants.dart';
import 'package:musikat_web_admin/widgets/custom_appbar.dart';
import 'package:musikat_web_admin/widgets/custom_dialog.dart';
import 'package:musikat_web_admin/widgets/display_tiles.dart';
import 'package:musikat_web_admin/widgets/toast_msg.dart';

class MoodsScreen extends StatefulWidget {
  const MoodsScreen({Key? key}) : super(key: key);

  @override
  State<MoodsScreen> createState() => _MoodsScreenState();
}

class _MoodsScreenState extends State<MoodsScreen> {
  final CategoriesController _categoriesCon = CategoriesController();
  TextEditingController searchController = TextEditingController(),
      moodCon = TextEditingController();
  List<String> moods = [];
  List<String> filteredMoods = [];
  late StreamSubscription<List<String>> _streamSubscription;

  @override
  void initState() {
    super.initState();
    _streamSubscription =
        _categoriesCon.getDescriptionStream().listen((fetchedMoods) {
      setState(() {
        moods = fetchedMoods;
        filteredMoods = moods;
      });
    }, onError: (error) {
      print('Error fetching moods: $error');
      ToastMessage.show(context, 'Error fetching moods: $error');
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
              'Moods',
              style: welcomeStyle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 110),
            child: Text(
              'Different moods for different songs',
              style: sideNavStyle,
            ),
          ),
          Row(
            children: [
              searchBar(),
              addMoodButton(context),
            ],
          ),
          moodList(),
        ],
      ),
    );
  }

  SizedBox addMoodButton(BuildContext context) {
    return SizedBox(
      height: 35,
      child: ElevatedButton(
        onPressed: () {
          _showAddMoodDialog(context);
        },
        child: const Row(
          children: [
            Icon(Icons.add),
            SizedBox(
              width: 5,
            ),
            Text('Add Mood'),
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
            hintText: 'Search for a description...',
            controller: searchController,
            onChanged: (value) {
              setState(() {
                filteredMoods = moods
                    .where((mood) =>
                        mood.toLowerCase().contains(value.toLowerCase()))
                    .toList();
              });
            }),
      ),
    );
  }

  Expanded moodList() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 80, right: 80),
        child: GridView.count(
          physics: const BouncingScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 9,
          children: List.generate(filteredMoods.length, (index) {
            return DisplayTiles(
              text: filteredMoods[index],
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomDialog(
                      title: 'Delete',
                      content: Text(
                        'Are you sure you want to delete this description?',
                        style: sideNavStyle,
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              _categoriesCon.deleteDescription(filteredMoods[index]);
                              Navigator.of(context).pop();
                              ToastMessage.show(
                                  context, 'Description deleted successfully');
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

  void _showAddMoodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: 'Add Mood',
          content: SearchBar(
            hintText: 'Enter a description name...',
            controller: moodCon,
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (moodCon.text.isNotEmpty) {
                  _categoriesCon.addDescription(moodCon.text);
                  Navigator.of(context).pop();
                  moodCon.clear();
                  ToastMessage.show(context, 'Description added successfully');
                } else {
                  ToastMessage.show(context, 'Please enter a description name');
                }
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                moodCon.clear();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
