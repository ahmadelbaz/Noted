import 'dart:convert';

import 'database_model.dart';

class Note implements DatabaseModel {
  String id = '';
  String title = '';
  String description = '';
  DateTime dateTime = DateTime.now();
  List<String> category = [];
  bool isFavorite = false;

  Note({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.category,
    required this.isFavorite,
  });

  Note.fromMap(Map<String, dynamic> map) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(map['datetime']);
    List<String> categoryFromJson =
        List<String>.from(json.decode(map['category']));
    id = map['id'];
    title = map['title'];
    description = map['body'];
    dateTime = dateTime;
    category = categoryFromJson;
    isFavorite = map['isFavorite'] == 0 ? false : true;
  }

  @override
  String? database() {
    return 'notes_database';
  }

  @override
  String? getId() {
    return id;
  }

  @override
  String? table() {
    return 'notes';
  }

  @override
  Map<String, dynamic>? toMap() {
    int storedDateTime = dateTime.millisecondsSinceEpoch;
    return {
      'id': id,
      'title': title,
      'body': description,
      'datetime': storedDateTime,
      'category': json.encode(category),
      'isFavorite': isFavorite ? 1 : 0,
    };
  }
}
