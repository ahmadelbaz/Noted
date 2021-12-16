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
  Future<Database> noteDatabase() async {
    void _createNotesTablesV1(Batch batch) {
      batch.execute(
        "CREATE TABLE notes(id TEXT PRIMARY KEY, title TEXT, body Text, isFavorite INTEGER, datetime INTEGER, category JSON)", //
      );
    }

    return openDatabase(
      join(await getDatabasesPath(), 'notes_database.db'),
      onCreate: (db, version) async {
        var batch = db.batch();
        _createNotesTablesV1(batch);
        await batch.commit();
      },
      version: 1,
      onDowngrade: onDatabaseDowngradeDelete,
    );
  }

  Future<Database> categoryeDatabase() async {
    void _createCatTablesV1(Batch batch) {
      batch.execute(
        "CREATE TABLE categories(id TEXT PRIMARY KEY, name TEXT)",
      );
    }

    return openDatabase(
      join(await getDatabasesPath(), 'categories_database.db'),
      onCreate: (db, version) async {
        var batch = db.batch();
        _createCatTablesV1(batch);
        await batch.commit();
      },
      version: 1,
      onDowngrade: onDatabaseDowngradeDelete,
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
    // db.close();
  }

  Future<void> update(DatabaseModel model) async {
    final db = await getDatabase(model);
    db.update(
      model.table()!,
      model.toMap()!,
      where: 'id = ?',
      whereArgs: [model.getId()],
    );
    notifyListeners();
    // db.close();
  }

  Future<void> delete(DatabaseModel model) async {
    final db = await getDatabase(model);
    db.delete(
      model.table()!,
      where: 'id = ?',
      whereArgs: [model.getId()],
    );
    // db.close();
  }

  Future<List<DatabaseModel>> getAll(String table, String db_name) async {
    final db = await getDatabaseByName(db_name);
    final List<Map<String, dynamic>> maps = await db.query(table);
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
