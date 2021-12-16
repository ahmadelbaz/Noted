import 'dart:developer';
// import 'package:auto_direction/auto_direction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted/functions/generate_random_id.dart';
import 'package:noted/models/note_model.dart';
import 'package:noted/providers/notes_provider.dart';
import 'package:noted/screens/categories_screen.dart';
import 'package:noted/widgets/drawer.dart';
import 'package:noted/widgets/fav_widget.dart';
import 'package:noted/widgets/tab_widget.dart';

import '../main.dart';

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
// provider to take note id when its selected
final noteIdStateProvider = StateProvider<String>((ref) => '');

class NotesListScreen extends ConsumerWidget {
  // const NotesListScreen({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

  @override
  Widget build(BuildContext context, watch) {
    // mediaquery for responsive sizes
    final _size = MediaQuery.of(context).size;
    // watching the providers
    final _notesProvider = watch(notesChangeNotifierProvider);
    var _searchProvider = watch(searchStateProvider);
    var _isFirstTabProvider = watch(isFirstTabStateProvider);
    return DefaultTabController(
      length: 3,
      child: Builder(builder: (context) {
        final TabController tabController = DefaultTabController.of(context)!;
        tabController.addListener(() {
          if (tabController.index == 0) {
            // Your code goes here.
            // To get index of current tab use tabController.index
            _isFirstTabProvider.state = true;
          } else {
            _isFirstTabProvider.state = false;
          }
        });
        return Scaffold(
          key: _key,
          drawer: DrawerList(),
          drawerEdgeDragWidth: _size.width,
          // _isFirstTabProvider.state ? _size.width * 0.2 : 0.0,
          bottomNavigationBar: TabBar(
            padding: const EdgeInsets.only(bottom: 10),
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(
                text: 'All Notes',
              ),
              Tab(text: 'Favorites'),
              Tab(text: 'Categories'),
            ],
          ),
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Theme.of(context).canvasColor,
                statusBarIconBrightness: Brightness.light),
            backgroundColor: Theme.of(context).canvasColor,
            iconTheme: const IconThemeData(color: Colors.white),
            // bottom: TabBar(
            //   labelColor: Theme.of(context).primaryColor,
            //   unselectedLabelColor: Colors.grey,
            //   tabs: const [
            //     Tab(
            //       text: 'All Notes',
            //     ),
            //     Tab(text: 'Favorites'),
            //   ],
            // ),
            actions: [
              IconButton(
                onPressed: () {
                  _searchProvider.state = !_searchProvider.state;
                  if (!_searchProvider.state) {
                    _notesProvider.showCurrent();
                  }
                },
                icon: _searchProvider.state
                    ? const Icon(Icons.cancel)
                    : const Icon(Icons.search),
              ),
            ],
            title: _searchProvider.state
                ? TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search',
                    ),
                    autofocus: true,
                    onChanged: (value) {
                      _notesProvider.searchText = value;
                      if (tabController.index == 1) {
                        _notesProvider.search(value, true, context);
                      } else {
                        _notesProvider.search(value, false, context);
                      }
                    },
                  )
                : const Text(''),
          ),
          body: const TabBarView(
            children: [
              TabWidget(),
              FavWidget(),
              CategoriesScreen(),
            ],
          ),
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
                      ? [(_notesProvider.selected)]
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
      }),
    );
  }
}
