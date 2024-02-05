// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print
// ignore_for_file: use_build_context_synchronously, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:musikat_web_admin/controller/categories_controller.dart';
import 'package:musikat_web_admin/services/playlist_service.dart';

import 'package:musikat_web_admin/utils/constants.dart';
import 'package:musikat_web_admin/widgets/custom_appbar.dart';
import 'package:musikat_web_admin/widgets/custom_text_field.dart';
import 'package:musikat_web_admin/widgets/toast_msg.dart';

class CreatePlaylistScreen extends StatefulWidget {
  const CreatePlaylistScreen({super.key});

  @override
  State<CreatePlaylistScreen> createState() => _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends State<CreatePlaylistScreen> {
  final CategoriesController _categoriesCon = CategoriesController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleCon = TextEditingController();
  final TextEditingController _descCon = TextEditingController();
  html.File? selectedPlaylistCover;
  List<String> genres = [];
  String? selectedGenre;
  late StreamSubscription<List<String>> _streamSubscription;

  @override
  void initState() {
    super.initState();
    _streamSubscription =
        _categoriesCon.getGenresStream().listen((fetchedGenres) {
      setState(() {
        genres = fetchedGenres;
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

 void _pickPlaylistCover() {
    final html.FileUploadInputElement uploadInput =
        html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files!.isNotEmpty) {
        final reader = html.FileReader();
        reader.readAsDataUrl(files[0]);

        reader.onLoadEnd.listen((e) {
          setState(() {
            selectedPlaylistCover = files[0];
          });
        });
      } else {
        ToastMessage.show(context, 'No image selected');
      }
    });
  }

    void _onCreatePlaylist() async {
    await PlaylistService.createPlaylist(
        context, _titleCon, _descCon, selectedPlaylistCover, selectedGenre);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: musikatBackgroundColor,
        appBar: const CustomAppBar(),
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Form(
            onChanged: () {
              _formKey.currentState?.validate();
              if (mounted) {
                setState(() {});
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title(),
                Row(
                  children: [
                    albumCover(),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, top: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Title',
                            style: TextStyle(
                              color: Colors.white,
                              height: 2,
                              fontSize: 16,
                            ),
                          ),
                          InputTextField(
                            controller: _titleCon,
                            hintText: 'Title',
                            validator: (value) {
                              if (value!.isEmpty) {
                                return null;
                              }
                              return null;
                            },
                          ),
                          const Text(
                            'Description',
                            style: TextStyle(
                              color: Colors.white,
                              height: 2,
                              fontSize: 16,
                            ),
                          ),
                          InputTextField(
                            controller: _descCon,
                            hintText: 'Description',
                            validator: (value) {
                              if (value!.isEmpty) {
                                return null;
                              }
                              return null;
                            },
                          ),
                          const Text(
                            'Genre',
                            style: TextStyle(
                              color: Colors.white,
                              height: 2,
                              fontSize: 16,
                            ),
                          ),
                          dropdown(),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                            width: 300,
                            height: 50,
                            decoration: BoxDecoration(
                                color: musikatColor,
                                borderRadius: BorderRadius.circular(60)),
                            child: TextButton(
                              onPressed: () {
                                _onCreatePlaylist();
                              },
                              child: Text(
                                'Create',
                                style: buttonStyle,
                              ),
                            ),
                          ),
                          
                        ],
                        
                      ),
                    )
                  ],
                ),
                
              ],
            ),
          ),
        ));
  }

  Container dropdown() {
    return Container(
      width: 350,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButton<String>(
          value: selectedGenre,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
          ),
          hint: const Text('Select a genre'),
          onChanged: (String? newValue) {
            setState(() {
              selectedGenre = newValue;
            });
          },
          underline: const SizedBox(),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          items: genres.map<DropdownMenuItem<String>>((String genre) {
            return DropdownMenuItem<String>(
              value: genre,
              child: Text(genre),
            );
          }).toList(),
        ),
      ),
    );
  }

  Padding title() {
    return Padding(
      padding: const EdgeInsets.only(left: 110, right: 30),
      child: Text(
        'Create a playlist',
        style: welcomeStyle,
      ),
    );
  }

  Padding albumCover() {
    return Padding(
      padding: const EdgeInsets.only(left: 110, right: 30, top: 30, bottom: 10),
      child: InkWell(
        onTap: _pickPlaylistCover,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(10),
            image: selectedPlaylistCover != null
                ? DecorationImage(
                    image: Image.network(html.Url.createObjectUrlFromBlob(
                            selectedPlaylistCover!))
                        .image,
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          width: 180,
          height: 170,
          child: selectedPlaylistCover == null
              ? const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 40,
                )
              : null,
        ),
      ),
    );
  }
}
