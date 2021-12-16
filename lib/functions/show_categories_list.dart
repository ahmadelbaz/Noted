// import 'package:auto_direction/auto_direction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted/functions/delete_category.dart';
import 'package:noted/providers/category_provider.dart';
import 'package:noted/providers/notes_provider.dart';

final errorStateProvider = StateProvider<String>((ref) => '');
final editCategoryControllerStateProvider =
    StateProvider<TextEditingController>((ref) => TextEditingController());
final catIndexStateProvider = StateProvider<int>((ref) => 0);
final validationStateProvider = StateProvider<bool>((ref) => true);
final isEditableStateProvider = StateProvider<bool>((ref) => false);

class ShowCategoriesList extends StatelessWidget {
  final CategoryProvider _categoriesProvider;
  final NotesProvider _notesProvider;
  final AsyncValue<void> _fetchingData;
  // var editCategoryController = TextEditingController();

  ShowCategoriesList(
      this._categoriesProvider, this._notesProvider, this._fetchingData);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) => _categoriesProvider.categories.isEmpty
          ? const Center(
              child: Text('No categories .. create one'),
            )
          : ListView.builder(
              // key to save where we scrolled if we left the tab
              key: const PageStorageKey<String>('categories'),
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,
              itemCount: _categoriesProvider.categories.length,
              itemBuilder: (context, index) {
                return Container(
                  child: _fetchingData.when(
                    data: (data) {
                      return ListTile(
                        leading: watch(isEditableStateProvider).state &&
                                watch(catIndexStateProvider).state == index
                            ? IconButton(
                                onPressed: () {
                                  watch(isEditableStateProvider).state = false;
                                  if (watch(editCategoryControllerStateProvider)
                                      .state
                                      .text
                                      .isEmpty) {
                                    watch(errorStateProvider).state =
                                        'Empty field';
                                    watch(validationStateProvider).state =
                                        false;
                                  } else if (_categoriesProvider
                                      .checkCategoryExistence(watch(
                                              editCategoryControllerStateProvider)
                                          .state
                                          .text)) {
                                    watch(errorStateProvider).state =
                                        'Alredy exists';
                                    watch(validationStateProvider).state =
                                        false;
                                  } else {
                                    _categoriesProvider.editCategory(
                                        watch(editCategoryControllerStateProvider)
                                            .state
                                            .text,
                                        index);
                                  }
                                },
                                icon: const Icon(Icons.check_outlined),
                              )
                            : null,
                        tileColor: _notesProvider.selected ==
                                '${_categoriesProvider.categories[index].name}'
                            ? Colors.blueGrey
                            : Theme.of(context).canvasColor,
                        title: watch(isEditableStateProvider).state &&
                                watch(catIndexStateProvider).state == index
                            ? TextFormField(
                                // initialValue: _categoriesProvider
                                //     .categories[index].name,
                                decoration: InputDecoration(
                                  labelText: 'Category name',
                                  errorText: context
                                          .read(validationStateProvider)
                                          .state
                                      ? null
                                      : context.read(errorStateProvider).state,
                                ),
                                autofocus: true,
                                controller:
                                    watch(editCategoryControllerStateProvider)
                                        .state,
                              )
                            : Text(
                                '${_categoriesProvider.categories[index].name}'),
                        onLongPress: () {
                          watch(isEditableStateProvider).state =
                              !watch(isEditableStateProvider).state;
                          watch(editCategoryControllerStateProvider)
                                  .state
                                  .text =
                              _categoriesProvider.categories[index].name;
                          watch(catIndexStateProvider).state = index;
                        },
                        onTap: () {
                          _notesProvider.showCategoryNotes(
                              _categoriesProvider.categories[index].name);
                          // Navigator.of(context).pop();
                          // DefaultTabController.of(context)?.animateTo(0);
                          Navigator.of(context).pushReplacementNamed('/');
                        },
                        trailing: watch(isEditableStateProvider).state &&
                                watch(catIndexStateProvider).state == index
                            ? IconButton(
                                onPressed: () {
                                  deleteCategory(context, _categoriesProvider,
                                      _notesProvider, index);
                                },
                                icon: const Icon(Icons.delete),
                              )
                            : IconButton(
                                onPressed: () {
                                  watch(isEditableStateProvider).state = true;
                                  watch(editCategoryControllerStateProvider)
                                          .state
                                          .text =
                                      _categoriesProvider
                                          .categories[index].name;
                                  watch(catIndexStateProvider).state = index;
                                },
                                icon: const Icon(Icons.edit),
                              ),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(child: Text('Error: $e')),
                  ),
                );
              }),
    );
  }
}
