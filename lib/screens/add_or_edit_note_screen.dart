import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted/functions/formate_date_time.dart';
import 'package:noted/models/note_model.dart';
import 'package:noted/screens/categories_screen.dart';
import 'package:noted/screens/notes_list_screen.dart';
import 'package:uuid/uuid.dart';
// import 'package:auto_direction/auto_direction.dart';

final lockStateProvider = StateProvider<bool>((ref) => false);

class AddOrEditNoteScreen extends ConsumerWidget {
  // global key for the form
  final _formKey = GlobalKey<FormState>();
  // we use this node to easily tavel from textfield to another
  final _descriptionFocusNode = FocusNode();
  // variable to check if we deleted the note or not
  bool _isDeleted = false;
  @override
  Widget build(BuildContext context, watch) {
    final _notesProvider = watch(notesChangeNotifierProvider);
    final _categoriesProvider = watch(categoriesChangeNotifierProvider);
    final _fetchingData = watch(categoriesFutureProvider);
    var _lockProvider = watch(lockStateProvider);

    // get the arguments from navigation
    final _args = ModalRoute.of(context)!.settings.arguments as String;
    log('$_args');
    // mediaquery for responsive sizes
    final _size = MediaQuery.of(context).size;
    // variable to fotmat date and time
    DateTime _noteTime = _isDeleted
        ? DateTime.now()
        : _notesProvider.getNoteById(_args).dateTime;

    // method to handle back button
    Future<bool> _onWillPop() async {
      if (_notesProvider.getNoteById(_args).title.isEmpty &&
          _notesProvider.getNoteById(_args).description.isEmpty) {
        _notesProvider.deleteNote(_args);
        _isDeleted = true;
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        const snackBar = SnackBar(content: Text('Note is Empty !'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      return true;
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          // backwardsCompatibility: false,
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
            IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed('note_categories_screen', arguments: _args);
              },
              icon: const Icon(Icons.category),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    SizedBox(
                      height: _size.height * 0.025,
                    ),
                    Padding(
                      padding: EdgeInsets.all(_size.width * 0.025),
                      child: TextFormField(
                        // check if the note got deleted or not
                        initialValue: _isDeleted
                            ? ''
                            : _notesProvider.getNoteById(_args).title,
                        enabled: _lockProvider.state ? false : true,
                        onChanged: (value) {
                          _notesProvider.editNote(
                              Note(
                                  id: _args,
                                  title: value,
                                  description: _notesProvider
                                      .getNoteById(_args)
                                      .description,
                                  dateTime: _notesProvider
                                      .getNoteById(_args)
                                      .dateTime,
                                  category: _notesProvider
                                      .getNoteById(_args)
                                      .category,
                                  isFavorite: _notesProvider
                                      .getNoteById(_args)
                                      .isFavorite),
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
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(_size.width * 0.025),
                      child: TextFormField(
                        enabled: _lockProvider.state ? false : true,
                        // check if the note got deleted or not
                        initialValue: _isDeleted
                            ? ''
                            : _notesProvider.getNoteById(_args).description,
                        onChanged: (value) {
                          _notesProvider.editNote(
                              Note(
                                  id: _notesProvider.getNoteById(_args).id,
                                  title:
                                      _notesProvider.getNoteById(_args).title,
                                  description: value,
                                  dateTime: _notesProvider
                                      .getNoteById(_args)
                                      .dateTime,
                                  category: _notesProvider
                                      .getNoteById(_args)
                                      .category,
                                  isFavorite: _notesProvider
                                      .getNoteById(_args)
                                      .isFavorite),
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
                        // check if the note got deleted or not
                        _isDeleted
                            ? Icons.favorite_border
                            : _notesProvider.getNoteById(_args).isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                      ),
                      onPressed: () {
                        _notesProvider.toggleFavorite(_args);
                      },
                    ),
                    // _fetchingData.when(
                    //     data: (data) {
                    //       return _categoriesProvider.categories.isEmpty
                    //           ? const Center(
                    //               child: Text('No categories .. create one'),
                    //             )
                    //           : ListView.builder(
                    //               scrollDirection: Axis.vertical,
                    //               shrinkWrap: true,
                    //               physics: const NeverScrollableScrollPhysics(),
                    //               itemCount:
                    //                   _categoriesProvider.categories.length,
                    //               itemBuilder: (context, index) {
                    //                 return CheckboxListTile(
                    //                   // check if the note got deleted or not
                    //                   value: _isDeleted
                    //                       ? false
                    //                       : _notesProvider
                    //                               .getNoteById(_args)
                    //                               .category
                    //                               .contains(
                    //                                   '${_categoriesProvider.categories[index].name}')
                    //                           ? true
                    //                           : false,
                    //                   title: Text(
                    //                       '${_categoriesProvider.categories[index].name}'),
                    //                   onChanged: (value) {
                    //                     // should add this category to the note or remove it
                    //                     _notesProvider.toggleCategory(
                    //                         _args,
                    //                         _categoriesProvider
                    //                             .categories[index]);
                    //                   },
                    //                 );
                    //               });
                    //     },
                    //     loading: () =>
                    //         const Center(child: CircularProgressIndicator()),
                    //     error: (e, st) => Center(child: Text('Error: $e'))),
                    // SizedBox(
                    //   height: _size.height * 0.025,
                    // ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  formatDateTime(_noteTime),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
