import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted/screens/about_us_screen.dart';
import 'package:noted/screens/add_or_edit_note_screen.dart';
import 'package:noted/screens/categories_screen.dart';
import 'package:noted/screens/note_categories_screen.dart';
import 'package:noted/screens/notes_list_screen.dart';
import 'package:noted/screens/settings_screen.dart';

// state provider to know if we in the fiest Tab or not
final isFirstTabStateProvider = StateProvider<bool>((ref) => true);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.cyan,
        colorScheme: ColorScheme.fromSwatch(
          brightness: Brightness.dark,
        ).copyWith(
          primary: Colors.cyan,
          secondary: Colors.cyan,
        ),
      ),
      routes: {
        '/': (ctx) => NotesListScreen(),
        'edit_screen': (ctx) => AddOrEditNoteScreen(),
        'categories_screen': (ctx) => CategoriesScreen(),
        'note_categories_screen': (ctx) => NoteCategoriesScreen(),
        'about_us_screen': (ctx) => AboutUsScreen(),
        'settings_screen': (ctx) => SettingsScreen(),
      },
    );
  }
}
