import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted/functions/delete_note.dart';
import 'package:noted/functions/generate_random_id.dart';
import 'package:noted/models/note_model.dart';
import 'package:noted/providers/notes_provider.dart';
import 'package:noted/widgets/drawer.dart';

// riverpod initiation
final notesChangeNotifierProvider =
    ChangeNotifierProvider<NotesProvider>((ref) => NotesProvider());
// futureProvider to get notes from database
final notesFutureProvider = FutureProvider(
  (ref) async {
    final selected = ref.read(notesChangeNotifierProvider).getAllNotes();
    return selected;
  },
);
// state provider for search Icon
final searchStateProvider = StateProvider<bool>((ref) => false);
//stateProvider to select notes and change UI for it
final isSelectedStateProvider = StateProvider<bool>((ref) => false);
// provider to take note id when its selected
final noteIdStateProvider = StateProvider<String>((ref) => '');

class NotesListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, watch) {
    // mediaquery for responsive sizes
    final _size = MediaQuery.of(context).size;
    // watching the providers
    final _notesProvider = watch(notesChangeNotifierProvider);
    final _fetchingData = watch(notesFutureProvider);
    var _searchProvider = watch(searchStateProvider);
    var _isSelectedProvider = watch(isSelectedStateProvider);
    var _noteIdProvider = watch(noteIdStateProvider);
    return Scaffold(
      drawer: DrawerList(),
      appBar: _isSelectedProvider.state
          ? AppBar(
              backwardsCompatibility: false,
              systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Theme.of(context).canvasColor,
                  statusBarIconBrightness: Brightness.light),
              backgroundColor: Theme.of(context).canvasColor,
              iconTheme: const IconThemeData(color: Colors.white),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _isSelectedProvider.state = false;
                },
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    deleteNote(context, _notesProvider, _noteIdProvider,
                        _isSelectedProvider);
                  },
                  icon: const Icon(Icons.delete),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('note_categories_screen',
                        arguments: _noteIdProvider.state);
                  },
                  icon: const Icon(Icons.category),
                ),
                IconButton(
                  onPressed: () {
                    _notesProvider.shareNote(context, _noteIdProvider.state);
                  },
                  icon: const Icon(Icons.share),
                ),
              ],
            )
          : AppBar(
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
                                    _notesProvider.toggleFavorite(
                                        _notesProvider.showedNotes[index].id);
                                  },
                                  icon: Icon(
                                    _notesProvider.showedNotes[index].isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                  ),
                                ),
                                onTap: () {
                                  // navigate to edit the note
                                  Navigator.of(context).pushNamed('edit_screen',
                                      arguments:
                                          _notesProvider.showedNotes[index].id);
                                },
                                onLongPress: () {
                                  _isSelectedProvider.state = true;
                                  _noteIdProvider.state =
                                      _notesProvider.showedNotes[index].id;
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
          // _notesProvider.showAllNotes();
          Note newNote = Note(
              id: generateRandomNum(),
              title: '',
              description: '',
              category: _notesProvider.selected != 'all' &&
                      _notesProvider.selected != 'fav'
                  ? ['${_notesProvider.selected}']
                  : [],
              dateTime: DateTime.now(),
              isFavorite: false); //, isFavorite: false
          _notesProvider.addNote(newNote);
          Navigator.of(context).pushNamed('edit_screen',
              // arguments: _notesProvider.allNotes.isEmpty
              //     ? 0
              //     : _notesProvider.allNotes.length - 1);
              arguments: newNote.id); //_notesProvider.allNotes.last.id
        },
      ),
    );
  }
}
