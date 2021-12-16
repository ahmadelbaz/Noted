import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:noted/database/database.dart';
import 'package:noted/models/category.dart';

class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];
  MyDatabase myDatabase = MyDatabase();

  UnmodifiableListView get categories => UnmodifiableListView(_categories);

  void addCategory(Category category) async {
    _categories.add(category);
    await myDatabase.categoryeDatabase();
    await myDatabase.insert(category);
    notifyListeners();
  }

  void editCategory(String newName, int index) async {
    _categories[index].name = newName;
    await myDatabase.categoryeDatabase();
    await myDatabase.update(_categories[index]);
    notifyListeners();
  }

  void deleteCategory(String id) async {
    var deletedCat = _categories.firstWhere((element) => element.id == id);
    _categories.removeWhere((element) => element.id == id);
    await myDatabase.categoryeDatabase();
    await myDatabase.delete(deletedCat);
    // we should remove this category from notes using it
    notifyListeners();
  }

  Future<void> getAllCategories() async {
    await myDatabase.noteDatabase();
    _categories = await myDatabase.getAll('categories', 'categories_database')
        as List<Category>;
    if (!_categories.isEmpty) {}
    notifyListeners();
  }

  bool checkCategoryExistence(String name) {
    for (var catName in _categories) {
      if (name == catName.name) {
        return true;
      }
    }
    return false;
  }

  // Future<void> fetchData() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   List<String> catList = [];
  //   List<Category> fetchingList = [];
  //   if (prefs.getStringList('catList') != null) {
  //     catList = (await prefs.getStringList('catList'))!;
  //     for (int n = 0; n < catList.length; n++) {
  //       Category newCat = Category(
  //         name: catList[n],
  //       );
  //       fetchingList.add(newCat);
  //     }
  //     _categories = fetchingList;
  //   } else {}
  //   notifyListeners();
  // }

  // Future<void> addToSharedPref() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   List<String> catList = [];
  //   for (int n = 0; n < _categories.length; n++) {
  //     catList.add('${_categories[n].name}');
  //   }
  //   if (prefs.getStringList('catList') != null) {
  //     await prefs.setStringList('catList_backup',
  //         catList); // if this worked here fine, apply it on notes too
  //     await prefs.remove('catList');
  //   }
  //   await prefs.setStringList('catList', catList);
  //   await prefs.remove('catList_backup');
  //   log('stored !');
  // }
}
