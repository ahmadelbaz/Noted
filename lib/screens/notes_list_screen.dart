import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted/database/database.dart';
import 'package:noted/functions/generate_random_id.dart';
import 'package:noted/models/note_model.dart';
import 'package:noted/providers/notes_provider.dart';
import 'package:noted/screens/categories_screen.dart';
import 'package:noted/widgets/drawer.dart';
import 'package:uuid/uuid.dart';

// riverpod initiation
final notesChangeNotifierProvider =
    ChangeNotifierProvider<NotesProvider>((ref) => NotesProvider());

final notesFutureProvider = FutureProvider(
  (ref) async {
    final selected = ref.read(notesChangeNotifierProvider).getAllNotes();
    return selected;
  },
);
// state provider for search Icon
final searchStateProvider = StateProvider<bool>((ref) => false);

class NotesListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, watch) {
    // mediaquery for responsive sizes
    final _size = MediaQuery.of(context).size;
    // watching the providers
    final _notesProvider = watch(notesChangeNotifierProvider);
    final _fetchingData = watch(notesFutureProvider);
    // final _fetchingData = context.read(categoriesFutureProvider);
    var _searchProvider = watch(searchStateProvider);
    return Scaffold(
      drawer: DrawerList(),
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
              _searchProvider.state = !_searchProvider.state;
              if (!_searchProvider.state) {
                _notesProvider.showCurrent();
                log('${_notesProvider.selected}');
              }
            },
            icon: _searchProvider.state
                ? const Icon(Icons.cancel)
                : const Icon(Icons.search),
          ),
        ],
        title: _searchProvider.state
            ? TextField(
                autofocus: true,
                onChanged: (value) {
                  _notesProvider.search(value);
                },
              )
            : const Text(''),
      ),
      body: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).primaryColor,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.symmetric(horizontal: _size.width * .06),
          child: _fetchingData.when(
            data: (data) {
              return _notesProvider.showedNotes.isEmpty
                  ? const Center(
                      child: Text('No Notes... Write One!'),
                    )
                  : ListView.builder(
                      itemCount: _notesProvider.showedNotes.length,
                      itemBuilder: ((ctx, index) {
                        return Column(
                          children: [
                            Container(
                              margin: EdgeInsets.all(_size.width * 0.02),
                              padding: EdgeInsets.all(_size.width * 0.009),
                              child: ListTile(
                                title: Text(
                                  _notesProvider.showedNotes[index].title,
                                  maxLines: 1,
                                ),
                                subtitle: Text(
                                  _notesProvider.showedNotes[index].description,
                                  maxLines: 1,
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    _notesProvider.toggleFavorite(index);
                                  },
                                  icon: Icon(
                                    _notesProvider.showedNotes[index].isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                  ),
                                ),
                                onTap: () {
                                  // navigate to edit the note
                                  // log('this is title ${_notesProvider.notes[index].title}\n and this is desc ${_notesProvider.notes[index].description}');
                                  // log('this is when we travel ${_notesProvider.notes[index].isFavorite}');
                                  Navigator.of(context).pushNamed('edit_screen',
                                      arguments:
                                          // we want to change it to the index only, so we use future builder there
                                          // to get data of that index
                                          // _notesProvider.notes[index].title,
                                          // _notesProvider.notes[index].description,
                                          // _notesProvider.notes[index].isFavorite,
                                          index);
                                },
                                onLongPress: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text(
                                        'Delete Note ?',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      content: Text(
                                        'You will delete "${_notesProvider.showedNotes[index].title}" note\nAre you sure ?',
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          child: const Text('Delete'),
                                          onPressed: () {
                                            _notesProvider.deleteNote(
                                                _notesProvider
                                                    .showedNotes[index].id);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Divider to separate between items
                            const Divider(),
                          ],
                        );
                      }),
                    );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
          )),
      floatingActionButton: FloatingActionButton(
        child: const Text('+'),
        onPressed: () {
          Note nN = Note(
              id: generateRandomNum(),
              title: '',
              description: '',
              category: [],
              isFavorite: false); //, isFavorite: false
          _notesProvider.addNote(nN);
          Navigator.of(context).pushNamed('edit_screen',
              arguments: _notesProvider.showedNotes.length - 1);
        },
      ),
    );
  }
}
