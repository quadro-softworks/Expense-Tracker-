import 'package:flutter/material.dart';
import 'models/expense.dart';
import 'models/category.dart';
import 'screens/add_expense_screen.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Expense> _expenses = [];
  final List<Category> _categories = Category.getDefaultCategories();

  void _addExpense(Expense expense) {
    setState(() {
      _expenses.add(expense);
    });
  }

  void _editExpense(Expense updatedExpense) {
    setState(() {
      final index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
      if (index != -1) {
        _expenses[index] = updatedExpense;
      }
    });
  }

  void _deleteExpense(String id) {
    setState(() {
      _expenses.removeWhere((expense) => expense.id == id);
    });
  }

  List<Widget> get _screens => [
    ExpenseListScreen(
      expenses: _expenses,
      categories: _categories,
      onDeleteExpense: _deleteExpense,
      onEditExpense: (expense) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddExpenseScreen(
              onExpenseAdded: (updatedExpense) {
                _editExpense(updatedExpense);
              },
              initialExpense: expense,
            ),
          ),
        );
      },
    ),
    StatisticsScreen(expenses: _expenses, categories: _categories), // Pass expenses and categories
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Expenses'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        AddExpenseScreen(onExpenseAdded: _addExpense),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class ExpenseListScreen extends StatelessWidget {
  final List<Expense> expenses;
  final List<Category> categories;
  final Function(String) onDeleteExpense;
  final Function(Expense) onEditExpense;

  const ExpenseListScreen({
    super.key,
    required this.expenses,
    required this.categories,
    required this.onDeleteExpense,
    required this.onEditExpense,
  });

  Category? _getCategoryById(String categoryId) {
    try {
      return categories.firstWhere((cat) => cat.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: expenses.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No expenses yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first expense',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                final category = _getCategoryById(expense.categoryId);

                return Dismissible(
                  key: Key(expense.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    onDeleteExpense(expense.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${expense.title} deleted')),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: category != null
                            ? Color(category.color).withAlpha(50)
                            : Colors.grey.withAlpha(50),
                        child: Text(
                          category?.icon ?? '📦',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      title: Text(
                        expense.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(category?.name ?? 'Unknown'),
                          Text(
                            DateFormat('MMM dd, yyyy').format(expense.date),
                            style: const TextStyle(fontSize: 12),
                          ),
                          if (expense.description != null)
                            Text(
                              expense.description!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '\$${expense.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => onEditExpense(expense),
                            tooltip: 'Edit',
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class StatisticsScreen extends StatelessWidget {
  final List<Expense> expenses;
  final List<Category> categories;

  const StatisticsScreen({
    super.key,
    required this.expenses,
    required this.categories,
  });

  Map<String, double> _calculateCategoryTotals() {
    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      categoryTotals.update(
        expense.categoryId,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return categoryTotals;
  }

  Category? _getCategoryById(String categoryId) {
    try {
      return categories.firstWhere((cat) => cat.id == categoryId);
    } catch (e) {
      return null; // Should not happen if data is consistent
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryTotals = _calculateCategoryTotals();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: expenses.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No expenses to show statistics for',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add some expenses to see your spending summary',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : categoryTotals.isEmpty // Also check if categoryTotals is empty, though expenses.isEmpty should cover this
              ? const Center( // This case might be redundant if expenses.isEmpty is handled first
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No category spending to display',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: categoryTotals.length,
                  itemBuilder: (context, index) {
                    final categoryId = categoryTotals.keys.elementAt(index);
                    final totalAmount = categoryTotals[categoryId]!;
                    final category = _getCategoryById(categoryId);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Text(
                              category?.icon ?? '❓',
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                category?.name ?? 'Unknown Category',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              '\\$${totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Settings will appear here',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
