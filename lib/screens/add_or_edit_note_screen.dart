import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted/models/note_model.dart';
import 'package:noted/screens/categories_screen.dart';
import 'package:noted/screens/notes_list_screen.dart';
import 'package:uuid/uuid.dart';

final lockStateProvider = StateProvider<bool>((ref) => false);

class AddOrEditNoteScreen extends ConsumerWidget {
  // global key for the form
  final _formKey = GlobalKey<FormState>();
  // we use this node to easily tavel from textfield to another
  final _descriptionFocusNode = FocusNode();
  @override
  Widget build(BuildContext context, watch) {
    final _notesProvider = watch(notesChangeNotifierProvider);
    final _categoriesProvider = watch(categoriesChangeNotifierProvider);
    final _fetchingData = watch(categoriesFutureProvider);
    var _lockProvider = watch(lockStateProvider);

    // get the arguments from navigation
    final _args = ModalRoute.of(context)!.settings.arguments as int;
    log('$_args');
    // mediaquery for responsive sizes
    final _size = MediaQuery.of(context).size;

    // method to handle back button
    Future<bool> _onWillPop() async {
      if (_notesProvider.showedNotes[_args].title.isEmpty &&
          _notesProvider.showedNotes[_args].description.isEmpty) {
        _notesProvider.deleteNote(_notesProvider.showedNotes[_args].id);
        final snackBar = SnackBar(content: Text('Note is Empty !'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      return true;
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backwardsCompatibility: false,
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Theme.of(context).canvasColor,
              statusBarIconBrightness: Brightness.light),
          backgroundColor: Theme.of(context).canvasColor,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              onPressed: () {
                _lockProvider.state = !_lockProvider.state;
              },
              icon: Icon(_lockProvider.state ? Icons.lock : Icons.lock_open),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(
                height: _size.height * 0.025,
              ),
              Padding(
                padding: EdgeInsets.all(_size.width * 0.025),
                child: TextFormField(
                  // check if the arguments in range or not
                  initialValue: _notesProvider.showedNotes.length - 1 >= _args
                      ? _notesProvider.showedNotes[_args].title
                      : '',
                  enabled: _lockProvider.state ? false : true,
                  onChanged: (value) {
                    _notesProvider.editNote(
                        Note(
                            id: _notesProvider.showedNotes[_args].id,
                            title: value,
                            description:
                                _notesProvider.showedNotes[_args].description,
                            category:
                                _notesProvider.showedNotes[_args].category,
                            isFavorite:
                                _notesProvider.showedNotes[_args].isFavorite),
                        _args);
                  },
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: const BorderSide(),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_descriptionFocusNode);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(_size.width * 0.025),
                child: TextFormField(
                  enabled: _lockProvider.state ? false : true,
                  // check if the arguments in range or not
                  initialValue: _notesProvider.showedNotes.length - 1 >= _args
                      ? _notesProvider.showedNotes[_args].description
                      : '',
                  onChanged: (value) {
                    _notesProvider.editNote(
                        Note(
                            id: _notesProvider.showedNotes[_args].id,
                            title: _notesProvider.showedNotes[_args].title,
                            description: value,
                            category:
                                _notesProvider.showedNotes[_args].category,
                            isFavorite:
                                _notesProvider.showedNotes[_args].isFavorite),
                        _args);
                  },
                  decoration: InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: const BorderSide(),
                    ),
                  ),
                  textInputAction: TextInputAction.newline,
                  textCapitalization: TextCapitalization.sentences,
                  focusNode: _descriptionFocusNode,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
              ),
              IconButton(
                tooltip: 'Toggle Favorite',
                icon: Icon(
                  // check if the arguments in range or not
                  _notesProvider.showedNotes.length - 1 >= _args
                      ? _notesProvider.showedNotes[_args].isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border
                      : Icons.favorite_border,
                ),
                onPressed: () {
                  _notesProvider.toggleFavorite(_args);
                },
              ),
              _fetchingData.when(
                  data: (data) {
                    return _categoriesProvider.categories.isEmpty
                        ? const Center(
                            child: Text('No categories .. create one'),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _categoriesProvider.categories.length,
                            itemBuilder: (context, index) {
                              return CheckboxListTile(
                                // check if the arguments in range or not
                                value: _notesProvider.showedNotes.length - 1 >=
                                        _args
                                    ? _notesProvider.showedNotes[_args].category
                                            .contains(
                                                '${_categoriesProvider.categories[index].name}')
                                        ? true
                                        : false
                                    : false,
                                title: Text(
                                    '${_categoriesProvider.categories[index].name}'),
                                onChanged: (value) {
                                  // should add this category to the note or remove it
                                  _notesProvider.toggleCategory(
                                      _notesProvider.showedNotes[_args].id,
                                      _categoriesProvider.categories[index]);
                                },
                              );
                            });
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Error: $e'))),
            ],
          ),
        ),
      ),
    );
  }
}
