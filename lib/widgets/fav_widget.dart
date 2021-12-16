// import 'package:auto_direction/auto_direction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted/functions/delete_note.dart';
import 'package:noted/screens/notes_list_screen.dart';

class FavWidget extends ConsumerWidget {
  const FavWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    watch(notesChangeNotifierProvider).showFavNotes();
    // mediaquery for responsive sizes
    final _size = MediaQuery.of(context).size;
    // watching the providers
    final _notesProvider = watch(notesChangeNotifierProvider);
    final _fetchingData = watch(notesFutureProvider);
    var _noteIdProvider = watch(noteIdStateProvider);
    return WillPopScope(
      onWillPop: () async {
        // if (_key.currentState.isDrawerOpen) {
        //   Navigator.of(context).pop();
        // Navigator.of(context).pushReplacementNamed('/');
        DefaultTabController.of(context)?.animateTo(0);
        return false;
      },
      child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).primaryColor,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.symmetric(horizontal: _size.width * .06),
          child: _fetchingData.when(
            data: (data) {
              return _notesProvider.favNotes.isEmpty
                  ? const Center(
                      child: Text('No Notes... Write One!'),
                    )
                  : ListView.builder(
                      itemCount: _notesProvider.favNotes.length,
                      itemBuilder: ((ctx, index) {
                        return Column(
                          children: [
                            Container(
                              margin: EdgeInsets.all(_size.width * 0.02),
                              padding: EdgeInsets.all(_size.width * 0.009),
                              child: ListTile(
                                title: Text(
                                  _notesProvider.favNotes[index].title,
                                  maxLines: 1,
                                ),
                                subtitle: Text(
                                  _notesProvider.favNotes[index].description,
                                  maxLines: 1,
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    _notesProvider.toggleFavorite(
                                        _notesProvider.favNotes[index].id);
                                  },
                                  icon: Icon(
                                    _notesProvider.favNotes[index].isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                  ),
                                ),
                                onTap: () {
                                  // navigate to edit the note
                                  Navigator.of(context).pushNamed('edit_screen',
                                      arguments:
                                          _notesProvider.favNotes[index].id);
                                },
                                onLongPress: () {
                                  _noteIdProvider.state =
                                      _notesProvider.favNotes[index].id;
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
                                                _notesProvider.shareNote(
                                                    context,
                                                    _noteIdProvider.state);
                                              },
                                            ),
                                            ListTile(
                                              leading: IconButton(
                                                onPressed: () {
                                                  Navigator.of(context).pushNamed(
                                                      'note_categories_screen',
                                                      arguments: _noteIdProvider
                                                          .state);
                                                },
                                                icon:
                                                    const Icon(Icons.category),
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
          )),
    );
  }
}
