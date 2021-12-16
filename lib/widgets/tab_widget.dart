// import 'package:auto_direction/auto_direction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted/functions/delete_note.dart';
import 'package:noted/screens/notes_list_screen.dart';

import '../main.dart';

class TabWidget extends ConsumerWidget {
  const TabWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    // mediaquery for responsive sizes
    final _size = MediaQuery.of(context).size;
    // watching the providers
    final _notesProvider = watch(notesChangeNotifierProvider);
    final _fetchingData = watch(notesFutureProvider);
    var _noteIdProvider = watch(noteIdStateProvider);
    // WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
    //   watch(isFirstTabStateProvider).state = true;
    // });
    return Container(
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
                                _noteIdProvider.state =
                                    _notesProvider.showedNotes[index].id;
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Choose an action'),
                                    content: SizedBox(
                                      height: _size.height * 0.2,
                                      child: ListView(
                                        children: [
                                          ListTile(
                                            leading: IconButton(
                                              onPressed: () {
                                                _notesProvider.shareNote(
                                                    context,
                                                    _noteIdProvider.state);
                                              },
                                              icon: const Icon(Icons.share),
                                            ),
                                            title: const Text('Share Note'),
                                            onTap: () {
                                              _notesProvider.shareNote(context,
                                                  _noteIdProvider.state);
                                            },
                                          ),
                                          ListTile(
                                            leading: IconButton(
                                              onPressed: () {
                                                Navigator.of(context).pushNamed(
                                                    'note_categories_screen',
                                                    arguments:
                                                        _noteIdProvider.state);
                                              },
                                              icon: const Icon(Icons.category),
                                            ),
                                            title:
                                                const Text('Edit Categories'),
                                            onTap: () {
                                              Navigator.of(context).pushNamed(
                                                  'note_categories_screen',
                                                  arguments:
                                                      _noteIdProvider.state);
                                            },
                                          ),
                                          ListTile(
                                            leading: IconButton(
                                              onPressed: () {
                                                deleteNote(
                                                  context,
                                                  _notesProvider,
                                                  _noteIdProvider,
                                                );
                                              },
                                              icon: const Icon(Icons.delete),
                                            ),
                                            title: const Text('Delete Note'),
                                            onTap: () {
                                              deleteNote(
                                                context,
                                                _notesProvider,
                                                _noteIdProvider,
                                              );
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Done'),
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
        ));
  }
}
