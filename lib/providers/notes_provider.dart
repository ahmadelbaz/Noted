import 'dart:collection';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:noted/database/database.dart';
import 'package:noted/models/category.dart';
import 'package:noted/models/note_model.dart';
import 'package:share/share.dart';

class NotesProvider extends ChangeNotifier {
  // all notes we have
  List<Note> _allNotes = [];
  // only notes we want to display
  List<Note> _showedNotes = [];
  // favorite notes only
  List<Note> _favNotes = [];
  // notes in specific category
  List<Note> _catNotes = [];
  // list of notes on search
  List<Note> _searchNotes = [];
  // variable to know which list is selected
  String selected = 'all';
  MyDatabase myDatabase = MyDatabase();
  // String for search bar
  String searchText = '';

  UnmodifiableListView get showedNotes => UnmodifiableListView(_showedNotes);
  UnmodifiableListView get allNotes => UnmodifiableListView(_allNotes);
  UnmodifiableListView get favNotes => UnmodifiableListView(_favNotes);

  void showAllNotes() {
    _showedNotes = _allNotes;
    selected = 'all';
    notifyListeners();
  }

  // show favoritre notes only when user select it
  void showFavNotes() {
    _favNotes =
        _allNotes.where((element) => element.isFavorite == true).toList();
    // _showedNotes = _favNotes;
    // selected = 'fav';
    // notifyListeners();
  }

  // show specific category which user selected
  void showCategoryNotes(String category) {
    _catNotes = _allNotes
        .where((element) => element.category.contains(category))
        .toList();
    _showedNotes = _catNotes;
    selected = category;
    notifyListeners();
  }

  // show current mode based on selected list
  void showCurrent() {
    if (selected == 'all') {
      showAllNotes();
    } else {
      showCategoryNotes(selected);
    }
  }

  void search(String value, bool isFav, BuildContext context) {
    log('$isFav');
    if (isFav) {
      _searchNotes = _favNotes
          .where((element) =>
              element.title.toUpperCase().contains(value.toUpperCase()) ||
              element.description.toUpperCase().contains(value.toUpperCase()))
          .toList();
      // _favNotes = _searchNotes;
      // log('fav now : ${_favNotes.length}');
      if (_searchNotes.isEmpty) {
        final snackBar = SnackBar(content: Text('No result'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        // do something to show what user search about
      }
    } else if (selected == 'all') {
      _searchNotes = _allNotes
          .where((element) =>
              element.title.toUpperCase().contains(value.toUpperCase()) ||
              element.description.toUpperCase().contains(value.toUpperCase()))
          .toList();
      _showedNotes = _searchNotes;
      log('showed now : ${_showedNotes.length}');
    } else {
      _searchNotes = _catNotes
          .where((element) =>
              element.title.toUpperCase().contains(value.toUpperCase()) ||
              element.description.contains(value.toUpperCase()))
          .toList();
      _showedNotes = _searchNotes;
    }
    notifyListeners();
  }

  Note getNoteById(String id) {
    Note getNote = _allNotes.firstWhere((element) => element.id == id);
    return getNote;
  }

  void addNote(Note note) async {
    _allNotes.add(note);
    await myDatabase.noteDatabase();
    await myDatabase.insert(note);
    notifyListeners();
  }

  void editNote(Note note, String id) async {
    Note fN = _allNotes.firstWhere((element) => element.id == id);
    int index = _allNotes.indexOf(fN);
    _allNotes[index] = note;
    await myDatabase.noteDatabase();
    myDatabase.update(note);
    showCurrent();
    notifyListeners();
  }

  void toggleCategory(String id, Category category) async {
    await myDatabase.noteDatabase();
    var specificNote = _allNotes.firstWhere((element) => element.id == id);
    if (specificNote.category.contains(category.name)) {
      specificNote.category.remove(category.name);
    } else {
      specificNote.category.add(category.name);
    }
    await myDatabase.update(specificNote);
    showCurrent();
    notifyListeners();
  }

  void toggleFavorite(String id) async {
    Note fN = _allNotes.firstWhere((element) => element.id == id);
    int index = _allNotes.indexOf(fN);
    _allNotes[index].isFavorite = !_allNotes[index].isFavorite;
    await myDatabase.noteDatabase();
    myDatabase.update(_allNotes[index]);
    if (selected == 'fav') {
      showFavNotes();
    }
    notifyListeners();
  }

  void deleteNote(String id) async {
    var deletedNote = _allNotes.firstWhere((element) => element.id == id);
    _allNotes.removeWhere((element) => element.id == id);
    await myDatabase.noteDatabase();
    await myDatabase.delete(deletedNote);
    showCurrent();
    notifyListeners();
  }

  // void deleteAllNotes() async{
  //   _allNotes.clear();
  //   await myDatabase.noteDatabase();
  //   notifyListeners();
  // }

  void shareNote(BuildContext context, String id) {
    Note shareNote = _allNotes.firstWhere((element) => element.id == id);
    final RenderBox box = context.findRenderObject() as RenderBox;
    Share.share(shareNote.description,
        subject: shareNote.title,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    notifyListeners();
  }

  void shareAllNote(BuildContext context) {
    String text = '';
    final RenderBox box = context.findRenderObject() as RenderBox;
    for (int n = 0; n < _allNotes.length; n++) {
      text +=
          'Note#${n + 1} : \n${_allNotes[n].title}\n${_allNotes[n].description}\n\n';
    }
    text += 'By \"NOTED\" App';
    Share.share(text,
        subject: 'My All Notes',
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    log(text);
    notifyListeners();
  }

  void checkEmptyNotes() async {
    for (int n = 0; n < _allNotes.length; n++) {
      if (_allNotes[n].title.isEmpty && _allNotes[n].description.isEmpty) {
        deleteNote(_allNotes[n].id);
      }
    }
  }

  void checkusedCategoriesBeforeDelete(String name) async {
    for (int n = 0; n < _allNotes.length; n++) {
      if (_allNotes[n].category.contains(name)) {
        _allNotes[n].category.remove(name);
        await myDatabase.noteDatabase();
        await myDatabase.update(_allNotes[n]);
        notifyListeners();
      }
    }
  }

  Future<void> getAllNotes() async {
    await myDatabase.noteDatabase();
    _allNotes =
        await myDatabase.getAll('notes', 'notes_database') as List<Note>;
    _showedNotes = _allNotes;
    checkEmptyNotes();
    notifyListeners();
  }

  // Future<void> addToSharedPref() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   List<String> titleList = [];
  //   List<String> descriptionList = [];
  //   List<String> favoriteList = [];
  //   favoriteList = _notes.map((n) => n.isFavorite.toString()).toList();
  //   log('this is favorite list $favoriteList');
  //   for (int n = 0; n < _notes.length; n++) {
  //     titleList.add('${_notes[n].title}');
  //     descriptionList.add('${_notes[n].description}');
  //   }
  //   if (prefs.getStringList('titleList') != null) {
  //     await prefs.setStringList('titleListBackup', titleList);
  //     await prefs.remove('titleList');
  //   }
  //   if (prefs.getStringList('descriptionList') != null) {
  //     await prefs.setStringList('descriptionListBackup', descriptionList);
  //     await prefs.remove('descriptionList');
  //   }
  //   if (prefs.getStringList('favoriteList') != null) {
  //     await prefs.setStringList('favoriteListBackup', favoriteList);
  //     await prefs.remove('favoriteList');
  //   }
  //   await prefs.setStringList('titleList', titleList);
  //   await prefs.setStringList('descriptionList', descriptionList);
  //   await prefs.setStringList('favoriteList', favoriteList);
  //   log('stored !');
  // }

  // add method to get notes from backup if any bug happens
  // Future<void> fetchNotesFromBackup() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   List<String> titleList = [];
  //   List<String> descriptionList = [];
  //   List<String> favoriteList = [];
  //   List<bool> favoriteListBool = [];
  //   List<Note> fetchingList = [];
  //   if (prefs.getStringList('titleListBackup') != null &&
  //       prefs.getStringList('descriptionListBackup') != null) {
  //     titleList = (await prefs.getStringList('titleListBackup'))!;
  //     descriptionList = prefs.getStringList('descriptionListBackup')!;
  //     favoriteList = prefs.getStringList('favoriteListBackup')!;
  //     favoriteListBool =
  //         favoriteList.map((e) => e.toLowerCase() == 'true').toList();
  //     for (int n = 0; n < titleList.length; n++) {
  //       Note newNote = Note(
  //           title: titleList[n],
  //           description: descriptionList[n],
  //           isFavorite: favoriteListBool[n]);
  //       fetchingList.add(newNote);
  //     }
  //     _notes = fetchingList;
  //   } else {}
  //   checkEmptyNotes();
  //   notifyListeners();
  // }
}
