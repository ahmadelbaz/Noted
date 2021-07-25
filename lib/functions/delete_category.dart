import 'package:flutter/material.dart';
import 'package:noted/providers/category_provider.dart';
import 'package:noted/providers/notes_provider.dart';

void deleteCategory(BuildContext context, CategoryProvider _categoriesProvider,
    NotesProvider _notesProvider, int index) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text(
        'Delete Category ?',
        style: TextStyle(color: Colors.black),
      ),
      content: Text(
        'You will delete "${_categoriesProvider.categories[index].name}" Category\nAre you sure ?',
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
            // check if we dldte selected category
            if (_notesProvider.selected ==
                _categoriesProvider.categories[index].name) {
              _notesProvider.showAllNotes();
            }
            _categoriesProvider
                .deleteCategory(_categoriesProvider.categories[index].id);
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}
