import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted/screens/add_or_edit_note_screen.dart';
import 'package:noted/screens/categories_screen.dart';
import 'package:noted/screens/notes_list_screen.dart';

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
      },
    );
  }
}
