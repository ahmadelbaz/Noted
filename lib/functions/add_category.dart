import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted/models/category.dart';
import 'package:noted/providers/category_provider.dart';

import 'generate_random_id.dart';

final errorStateProvider = StateProvider<String>((ref) => '');
final validationStateProvider = StateProvider<bool>((ref) => true);
final addingStateProvider = StateProvider<bool>((ref) => true);

class AddCategory extends StatelessWidget {
  final CategoryProvider catProvider;
  var newCategoryController = TextEditingController();

  AddCategory(this.catProvider);
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) => ListTile(
        leading:
            Icon(watch(addingStateProvider).state ? Icons.add : Icons.close),
        title: watch(addingStateProvider).state
            ? const Text('Add Category')
            : TextField(
                decoration: InputDecoration(
                  labelText: 'Category name',
                  errorText: watch(validationStateProvider).state
                      ? null
                      : watch(errorStateProvider).state,
                ),
                autofocus: true,
                controller: newCategoryController,
              ),
        trailing: watch(addingStateProvider).state
            ? null
            : IconButton(
                onPressed: () {
                  if (newCategoryController.text.isEmpty) {
                    watch(errorStateProvider).state = 'Empty field';
                    watch(validationStateProvider).state = false;
                  } else if (catProvider
                      .checkCategoryExistence(newCategoryController.text)) {
                    watch(errorStateProvider).state = 'Alredy exists';
                    watch(validationStateProvider).state = false;
                  } else {
                    watch(validationStateProvider).state = true;
                    Category newCategory = Category(
                        id: generateRandomNum(),
                        name: newCategoryController.text.toString());
                    catProvider.addCategory(newCategory);
                    watch(addingStateProvider).state =
                        !watch(addingStateProvider).state;
                  }
                },
                icon: const Icon(Icons.check_outlined)),
        onTap: () {
          watch(addingStateProvider).state = !watch(addingStateProvider).state;
        },
      ),
    );
  }
}
