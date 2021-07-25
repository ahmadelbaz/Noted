import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted/models/category.dart';
import 'package:noted/models/database_model.dart';
import 'package:noted/models/note_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final dbProvider = ChangeNotifierProvider<MyDatabase>((ref) {
  return MyDatabase();
});

class MyDatabase extends ChangeNotifier {
  // MyDatabase() {
  //   noteDatabase();
  // }
  Future<Database> noteDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'notes_database.db'),
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        notifyListeners();
        return db.execute(
          "CREATE TABLE notes(id TEXT PRIMARY KEY, title TEXT, body Text, isFavorite INTEGER, category JSON)", //
        );
      },
      version: 1,
    ).whenComplete(() {
      notifyListeners();
    });
  }

  Future<Database> categoryeDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'categories_database.db'),
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          "CREATE TABLE categories(id TEXT PRIMARY KEY, name TEXT)",
        );
      },
      version: 1,
    );
  }

  // try to use it
  Future<Database> getDatabase(DatabaseModel model) async {
    return await getDatabaseByName('${model.database()}');
  }

  Future<Database> getDatabaseByName(String db_name) {
    switch (db_name) {
      case 'notes_database':
        return noteDatabase();
        break;
      case 'categories_database':
        return categoryeDatabase();
        break;
      default:
        return null!;
        break;
    }
  }

  Future<void> insert(DatabaseModel model) async {
    // final db = await dogDatabase();
    final db = await getDatabase(model);
    db.insert(
      model.table()!,
      model.toMap()!,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    log('added to database');
    // db.close();
  }

  Future<void> update(DatabaseModel model) async {
    final db = await getDatabase(model);
    log('this is note we want to store ${model.getId()}');
    db.update(
      model.table()!,
      model.toMap()!,
      where: 'id = ?',
      whereArgs: [model.getId()],
    );
    notifyListeners();
    log('note updated in database');
    // db.close();
  }

  Future<void> delete(DatabaseModel model) async {
    final db = await getDatabase(model);
    db.delete(
      model.table()!,
      where: 'id = ?',
      whereArgs: [model.getId()],
    );
    log('deleted from database');
    // db.close();
  }

  Future<List<DatabaseModel>> getAll(String table, String db_name) async {
    final db = await getDatabaseByName(db_name);
    final List<Map<String, dynamic>> maps = await db.query(table);
    log('this is dataase we chose $db_name');
    log('this is the map $maps');
    List<Note> notesModels = [];
    List<Category> categoriesModels = [];
    for (var item in maps) {
      switch (table) {
        case 'notes':
          notesModels.add(Note.fromMap(item));
          break;
        case 'categories':
          categoriesModels.add(Category.fromMap(item));
          break;
      }
    }
    return table == 'notes' ? notesModels : categoriesModels;
  }
}
