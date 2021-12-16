import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted/functions/add_category.dart';
import 'package:noted/functions/show_categories_list.dart';
import 'package:noted/screens/categories_screen.dart';
import 'package:noted/screens/notes_list_screen.dart';

class DrawerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // screen size
    final _size = MediaQuery.of(context).size;
    return Drawer(
      child: ListView(
        // key to save where we scrolled if we left the tab
        key: const PageStorageKey<String>('drawerlist'),
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: EdgeInsets.only(top: _size.height * 0.06),
            child: Consumer(
              builder: (context, watch, child) => ListTile(
                tileColor: watch(notesChangeNotifierProvider).selected == 'all'
                    ? Colors.blueGrey
                    : Theme.of(context).canvasColor,
                leading: const Icon(Icons.note),
                title: const Text(
                  'All Notes',
                ),
                onTap: () {
                  // we should add here to select all notes and show it
                  watch(notesChangeNotifierProvider).showAllNotes();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          // divider to split between items
          Divider(
            thickness: _size.height * 0.004,
          ),
          // Consumer(
          //   builder: (context, watch, child) => ListTile(
          //     tileColor: watch(notesChangeNotifierProvider).selected == 'fav'
          //         ? Colors.blueGrey
          //         : Theme.of(context).canvasColor,
          //     leading: const Icon(Icons.favorite),
          //     title: const Text(
          //       'Favorites',
          //     ),
          //     onTap: () {
          //       watch(notesChangeNotifierProvider).showFavNotes();
          //       Navigator.of(context).pop();
          //     },
          //   ),
          // ),
          // Divider(
          //   thickness: _size.height * 0.004,
          // ),
          ListTile(
            leading: const Icon(
              Icons.category,
            ),
            title: const Text(
              'Categories',
            ),
            onTap: () {
              // it should navigate us to category screen (maybe)
              Navigator.of(context).pop();
              // Navigator.of(context).pushNamed('categories_screen');
              DefaultTabController.of(context)?.animateTo(2);
            },
          ),
          Divider(
            thickness: _size.height * 0.004,
          ),
          Consumer(
            builder: (context, watch, child) => AddCategory(
              watch(categoriesChangeNotifierProvider),
            ),
          ),
          Consumer(
            // replace it with consumer widget
            builder: (context, watch, child) {
              // watching the providers
              final _categoriesProvider =
                  watch(categoriesChangeNotifierProvider);
              final _fetchingData = context.read(categoriesFutureProvider);
              return ShowCategoriesList(_categoriesProvider,
                  watch(notesChangeNotifierProvider), _fetchingData);
            },
          ),
          Divider(
            thickness: _size.height * 0.004,
          ),
          Consumer(
            builder: (context, watch, child) => ListTile(
              tileColor: watch(notesChangeNotifierProvider).selected == 'fav'
                  ? Colors.blueGrey
                  : Theme.of(context).canvasColor,
              leading: const Icon(Icons.delete),
              title: const Text(
                'Trash',
              ),
              onTap: () {
                watch(notesChangeNotifierProvider).showFavNotes();
                Navigator.of(context).pop();
              },
            ),
          ),
          Divider(
            thickness: _size.height * 0.004,
          ),
          Consumer(
            builder: (context, watch, child) => ListTile(
              leading: const Icon(Icons.share),
              title: const Text(
                'Share All Notes',
              ),
              onTap: () {
                watch(notesChangeNotifierProvider).shareAllNote(context);
              },
            ),
          ),
          Divider(
            thickness: _size.height * 0.004,
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text(
              'Settings',
            ),
            onTap: () {
              // add new screen for us
              Navigator.of(context).pushNamed('settings_screen');
            },
          ),
          Divider(
            thickness: _size.height * 0.004,
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text(
              'About us',
            ),
            onTap: () {
              // add new screen for us
              Navigator.of(context).pushNamed('about_us_screen');
            },
          ),
        ],
      ),
    );
  }
}
