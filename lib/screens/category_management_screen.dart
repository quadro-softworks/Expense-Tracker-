import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/expense_provider.dart';
import '../models/category.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          if (expenseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: expenseProvider.categories.length,
            itemBuilder: (context, index) {
              final category = expenseProvider.categories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(category.color).withAlpha(50),
                    child: Text(
                      category.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Color: #${category.color.toRadixString(16).toUpperCase()}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed:
                            () => _showEditCategoryDialog(context, category),
                        tooltip: 'Edit Category',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed:
                            () => _showDeleteCategoryDialog(context, category),
                        tooltip: 'Delete Category',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        tooltip: 'Add Category',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    _showCategoryDialog(context, null);
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    _showCategoryDialog(context, category);
  }

  void _showCategoryDialog(BuildContext context, Category? category) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    final iconController = TextEditingController(text: category?.icon ?? '');
    int selectedColor = category?.color ?? 0xFF2196F3;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(isEditing ? 'Edit Category' : 'Add Category'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Category Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: iconController,
                          decoration: const InputDecoration(
                            labelText: 'Icon (Emoji)',
                            border: OutlineInputBorder(),
                            hintText: '🍔',
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Select Color:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              _getColorOptions().map((color) {
                                final isSelected = selectedColor == color;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedColor = color;
                                    });
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Color(color),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? Colors.black
                                                : Colors.grey,
                                        width: isSelected ? 3 : 1,
                                      ),
                                    ),
                                    child:
                                        isSelected
                                            ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                            )
                                            : null,
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a category name'),
                            ),
                          );
                          return;
                        }

                        final newCategory = Category(
                          id: category?.id ?? const Uuid().v4(),
                          name: nameController.text.trim(),
                          icon:
                              iconController.text.trim().isEmpty
                                  ? '📦'
                                  : iconController.text.trim(),
                          color: selectedColor,
                        );

                        if (isEditing) {
                          context.read<ExpenseProvider>().updateCategory(
                            newCategory,
                          );
                        } else {
                          context.read<ExpenseProvider>().addCategory(
                            newCategory,
                          );
                        }

                        Navigator.of(context).pop();
                      },
                      child: Text(isEditing ? 'Update' : 'Add'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showDeleteCategoryDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Category'),
            content: Text(
              'Are you sure you want to delete "${category.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<ExpenseProvider>().deleteCategory(category.id);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  List<int> _getColorOptions() {
    return [
      0xFFFF5722, // Deep Orange
      0xFF2196F3, // Blue
      0xFF4CAF50, // Green
      0xFF9C27B0, // Purple
      0xFFE91E63, // Pink
      0xFF607D8B, // Blue Grey
      0xFFFFC107, // Amber
      0xFF795548, // Brown
      0xFFFF9800, // Orange
      0xFF3F51B5, // Indigo
      0xFF009688, // Teal
      0xFF8BC34A, // Light Green
      0xFFCDDC39, // Lime
      0xFFFFEB3B, // Yellow
      0xFF00BCD4, // Cyan
      0xFF673AB7, // Deep Purple
    ];
  }
}
