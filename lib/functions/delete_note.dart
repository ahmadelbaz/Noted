import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted/providers/notes_provider.dart';

void deleteNote(
  BuildContext context,
  NotesProvider _notesProvider,
  StateController<String> _noteIdProvider,
) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text(
        'Delete Note ?',
      ),
      content: Text(
        'You will delete "${_notesProvider.getNoteById(_noteIdProvider.state).title}" note\nAre you sure ?',
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
            _notesProvider.deleteNote(_noteIdProvider.state);
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}
