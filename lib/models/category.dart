import 'package:flutter/material.dart';

import 'database_model.dart';

class Category implements DatabaseModel {
  String id = '';
  String name = '';

  Category({
    required this.id,
    required this.name,
  });

  Category.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.name = map['name'];
  }

  @override
  String? database() {
    return 'categories_database';
  }

  @override
  String? getId() {
    return this.id;
  }

  @override
  String? table() {
    return 'categories';
  }

  @override
  Map<String, dynamic>? toMap() {
    return {
      'id': this.id,
      'name': this.name,
    };
  }
}
