import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted/functions/add_category.dart';
import 'package:noted/functions/show_categories_list.dart';
import 'package:noted/providers/category_provider.dart';
import 'package:noted/screens/notes_list_screen.dart';

final categoriesChangeNotifierProvider =
    ChangeNotifierProvider<CategoryProvider>((ref) => CategoryProvider());

final categoriesFutureProvider = FutureProvider(
  (ref) async {
    final selected =
        ref.read(categoriesChangeNotifierProvider).getAllCategories();
    return selected;
  },
);

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    // mediaquery for responsive sizes
    final _size = MediaQuery.of(context).size;
    // watching the providers
    final _categoriesProvider = watch(categoriesChangeNotifierProvider);
    final _fetchingData = watch(categoriesFutureProvider);
    return WillPopScope(
      onWillPop: () async {
        // if (_key.currentState.isDrawerOpen) {
        //   Navigator.of(context).pop();
        // Navigator.of(context).pushReplacementNamed('/');
        DefaultTabController.of(context)?.animateTo(0);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          // backwardsCompatibility: false,
          elevation: 0.0,
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Theme.of(context).canvasColor,
              statusBarIconBrightness: Brightness.light),
          backgroundColor: Theme.of(context).canvasColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Categories'),
          // actions: [
          //   IconButton(
          //       onPressed: () {
          //         addCategory(context, watch(categoriesChangeNotifierProvider));
          //       },
          //       icon: const Icon(Icons.add))
          // ],
        ),
        body: ListView(
          children: [
            AddCategory(_categoriesProvider),
            ShowCategoriesList(_categoriesProvider,
                watch(notesChangeNotifierProvider), _fetchingData),
          ],
        ),
      ),
    );
  }
}

//onTap: () {
            //   addCategory(context, watch(categoriesChangeNotifierProvider));
            // },
