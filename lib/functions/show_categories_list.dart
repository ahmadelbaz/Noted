import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted/functions/delete_category.dart';
import 'package:noted/providers/category_provider.dart';
import 'package:noted/providers/notes_provider.dart';

class ShowCategoriesList extends StatelessWidget {
  final CategoryProvider _categoriesProvider;
  final NotesProvider _notesProvider;
  final AsyncValue<void> _fetchingData;

  ShowCategoriesList(
      this._categoriesProvider, this._notesProvider, this._fetchingData);

  @override
  Widget build(BuildContext context) {
    return _categoriesProvider.categories.isEmpty
        ? const Center(
            child: Text('No categories .. create one'),
          )
        : ListView.builder(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: _categoriesProvider.categories.length,
            itemBuilder: (context, index) {
              return Container(
                child: _fetchingData.when(
                  data: (data) {
                    return ListTile(
                      tileColor: _notesProvider.selected ==
                              '${_categoriesProvider.categories[index].name}'
                          ? Colors.grey
                          : Theme.of(context).canvasColor,
                      title:
                          Text('${_categoriesProvider.categories[index].name}'),
                      onLongPress: () {
                        deleteCategory(context, _categoriesProvider,
                            _notesProvider, index);
                      },
                      onTap: () {
                        _notesProvider.showCategoryNotes(
                            _categoriesProvider.categories[index].name);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Error: $e')),
                ),
              );
            });
  }
}
