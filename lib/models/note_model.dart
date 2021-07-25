import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'database_model.dart';

class Note implements DatabaseModel {
  String id = '';
  String title = '';
  String description = '';
  // final DateTime? dateTime;
  List<String> category = [];
  bool isFavorite = false;

  Note({
    required this.id,
    required this.title,
    required this.description,
    // @required this.dateTime,
    required this.category,
    required this.isFavorite,
  });

  Note.fromMap(Map<String, dynamic> map) {
    log(map['category']);
    List<String> data = List<String>.from(json.decode(map['category']));
    this.id = map['id'];
    this.title = map['title'];
    this.description = map['body'];
    this.category = data;
    this.isFavorite = map['isFavorite'] == 0 ? false : true;
  }

  @override
  String? database() {
    return 'notes_database';
  }

  @override
  String? getId() {
    return this.id;
  }

  @override
  String? table() {
    return 'notes';
  }

  @override
  Map<String, dynamic>? toMap() {
    return {
      'id': this.id,
      'title': this.title,
      'body': this.description,
      'category': json.encode(this.category),
      'isFavorite': isFavorite ? 1 : 0,
    };
  }
}
