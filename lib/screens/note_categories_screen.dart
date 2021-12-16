import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted/functions/add_category.dart';
import 'package:noted/screens/categories_screen.dart';
import 'package:noted/screens/notes_list_screen.dart';

class NoteCategoriesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, watch) {
    final _args = ModalRoute.of(context)!.settings.arguments as String;
    final _notesProvider = watch(notesChangeNotifierProvider);
    final _categoriesProvider = watch(categoriesChangeNotifierProvider);
    final _fetchingData = watch(categoriesFutureProvider);
    return Scaffold(
      appBar: AppBar(
        // backwardsCompatibility: false,
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Theme.of(context).canvasColor,
            statusBarIconBrightness: Brightness.light),
        backgroundColor: Theme.of(context).canvasColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          AddCategory(_categoriesProvider),
          _fetchingData.when(
              data: (data) {
                return _categoriesProvider.categories.isEmpty
                    ? const Center(
                        child: Text('No categories .. create one'),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _categoriesProvider.categories.length,
                        itemBuilder: (context, index) {
                          return CheckboxListTile(
                            value: _notesProvider
                                    .getNoteById(_args)
                                    .category
                                    .contains(
                                        '${_categoriesProvider.categories[index].name}')
                                ? true
                                : false,
                            title: Text(
                                '${_categoriesProvider.categories[index].name}'),
                            onChanged: (value) {
                              // should add this category to the note or remove it
                              _notesProvider.toggleCategory(
                                  _args, _categoriesProvider.categories[index]);
                            },
                          );
                        });
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e'))),
        ],
      ),
    );
  }
}
