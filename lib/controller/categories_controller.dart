// ignore_for_file: avoid_print

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoriesController with ChangeNotifier {
  Future<List<String>> getLanguages() async {
    List<String> languages = [];

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('languages').get();

    for (var doc in querySnapshot.docs) {
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        var language = data['language'];
        if (language != null) {
          languages.add(language);
        }
      }
    }
    languages.sort();
    return languages;
  }

  Future<List<String>> getDescriptions() async {
    List<String> descriptions = [];

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('descriptions').get();

    for (var doc in querySnapshot.docs) {
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        var description = data['description'];
        if (description != null) {
          descriptions.add(description);
        }
      }
    }

    descriptions.sort();

    return descriptions;
  }

  Stream<List<String>> getGenresStream() {
    StreamController<List<String>> controller =
        StreamController<List<String>>();

    FirebaseFirestore.instance.collection('genres').snapshots().listen(
        (querySnapshot) {
      List<String> genres = [];

      for (var doc in querySnapshot.docs) {
        if (doc.exists) {
          var data = doc.data();
          var genre = data['genre'];
          if (genre != null) {
            genres.add(genre);
          }
        }
      }

      genres.sort();

      controller.add(genres);
    }, onError: (error) {
      controller.addError(error);
    });

    return controller.stream;
  }

  Stream<List<String>> getLanguagesStream() {
    StreamController<List<String>> controller =
        StreamController<List<String>>();

    FirebaseFirestore.instance.collection('languages').snapshots().listen(
        (querySnapshot) {
      List<String> languages = [];

      for (var doc in querySnapshot.docs) {
        if (doc.exists) {
          var data = doc.data();
          var language = data['language'];
          if (language != null) {
            languages.add(language);
          }
        }
      }

      languages.sort();

      controller.add(languages);
    }, onError: (error) {
      controller.addError(error);
    });

    return controller.stream;
  }

  Stream<List<String>> getDescriptionStream() {
    StreamController<List<String>> controller =
        StreamController<List<String>>();

    FirebaseFirestore.instance.collection('descriptions').snapshots().listen(
        (querySnapshot) {
      List<String> descriptions = [];

      for (var doc in querySnapshot.docs) {
        if (doc.exists) {
          var data = doc.data();
          var description = data['description'];
          if (description != null) {
            descriptions.add(description);
          }
        }
      }

      descriptions.sort();

      controller.add(descriptions);
    }, onError: (error) {
      controller.addError(error);
    });

    return controller.stream;
  }

  Future<void> addGenre(String genre) async {
    try {
      await FirebaseFirestore.instance
          .collection('genres')
          .add({'genre': genre});
      print('Genre added successfully');
    } catch (error) {
      print('Error adding genre: $error');
    }
  }

  Future<void> deleteGenre(String genre) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('genres')
          .where('genre', isEqualTo: genre)
          .get();

      if (querySnapshot.size > 0) {
        List<DocumentSnapshot> documents = querySnapshot.docs;
        for (var document in documents) {
          await document.reference.delete();
        }
        print('Genre(s) deleted successfully');
      } else {
        print('Genre not found');
      }
    } catch (error) {
      print('Error deleting genre: $error');
    }
  }

  Future<void> addLanguage(String language) async {
    try {
      await FirebaseFirestore.instance
          .collection('languages')
          .add({'language': language});
      print('Language added successfully');
    } catch (error) {
      print('Error adding language: $error');
    }
  }

  Future<void> deleteLanguage(String language) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('languages')
          .where('language', isEqualTo: language)
          .get();

      if (querySnapshot.size > 0) {
        List<DocumentSnapshot> documents = querySnapshot.docs;
        for (var document in documents) {
          await document.reference.delete();
        }
        print('Language(s) deleted successfully');
      } else {
        print('Language not found');
      }
    } catch (error) {
      print('Error deleting language: $error');
    }
  }

  Future<void> addDescription(String description) async {
    try {
      await FirebaseFirestore.instance
          .collection('descriptions')
          .add({'description': description});
      print('Description added successfully');
    } catch (error) {
      print('Error adding description: $error');
    }
  }

   Future<void> deleteDescription(String description) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('descriptions')
          .where('description', isEqualTo: description)
          .get();

      if (querySnapshot.size > 0) {
        List<DocumentSnapshot> documents = querySnapshot.docs;
        for (var document in documents) {
          await document.reference.delete();
        }
        print('Description(s) deleted successfully');
      } else {
        print('Description not found');
      }
    } catch (error) {
      print('Error deleting description: $error');
    }
  }
}
