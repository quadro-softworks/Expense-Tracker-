import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/expense.dart';
import 'dart:convert';
import 'models/category.dart';
import 'screens/add_expense_screen.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
class ThemeNotifier with ChangeNotifier {
  final String key = "theme";
  SharedPreferences? _prefs;
  bool _darkTheme = false;

  bool get darkTheme => _darkTheme;

  ThemeNotifier() {
    _loadFromPrefs();
  }

  _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();
    _darkTheme = _prefs?.getBool(key) ?? false;
    notifyListeners();
  }

  _saveToPrefs() async {
    await _initPrefs();
    _prefs?.setBool(key, _darkTheme);
  }

  void toggleTheme() {
    _saveToPrefs();
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(),
      child: const ExpenseTrackerApp(),
    ),
  );
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
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
          themeMode: themeNotifier.darkTheme ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
        );
      },
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
  final List<Category> _categories = Category.getDefaultCategories(); // TODO: Load categories from persistent storage

  @override
  void initState() {
    _loadExpenses();
  }

  // Load expenses from SharedPreferences
  void _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesString = prefs.getString('expenses');
    if (expensesString != null) {
      final List<dynamic> jsonList = jsonDecode(expensesString);
      setState(() {
        _expenses = jsonList.map((json) => Expense.fromMap(json)).toList();
      });
    }
  }

  // Save expenses to SharedPreferences
  void _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = _expenses.map((expense) => expense.toMap()).toList();
    prefs.setString('expenses', jsonEncode(expensesJson));
  }

  void _addExpense(Expense expense) {
    setState(() {
      _expenses.add(expense);
    });
    _saveExpenses();
  }

  void _editExpense(Expense updatedExpense) {
    setState(() {
      final index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
      if (index != -1) _expenses[index] = updatedExpense;
    });
  }

  void _deleteExpense(String id) {
    setState(() { // TODO: Add confirmation dialog for deletion
      _expenses.removeWhere((expense) => expense.id == id);
    });

    _saveExpenses();
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
    StatisticsScreen(expenses: _expenses, categories: _categories),
    const SettingsScreen(), // TODO: Implement more settings options
    const ProfileScreen(), // Add ProfileScreen here
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
            icon: Icon(Icons.settings), // TODO: Use a more appropriate icon if needed
            label: 'Settings',
          ),
          BottomNavigationBarItem( // Add new BottomNavigationBarItem
            icon: Icon(Icons.person),
            label: 'Profile',
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
                          if (expense.paymentMethod != null ||
                              expense.location != null ||
                              expense.currency != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                '${expense.paymentMethod != null ? 'Paid with: ${expense.paymentMethod}' : ''}'
                                '${expense.paymentMethod != null && expense.location != null ? ' | ' : ''}'
                                '${expense.location != null ? 'At: ${expense.location}' : ''}'
                                '${(expense.paymentMethod != null ||
                                            expense.location != null) &&
                                        expense.currency != null
                                    ? ' | '
                                    : ''}'
                                '${expense.currency != null ? 'Currency: ${expense.currency}' : ''}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                              fontSize: 16, // TODO: Use consistent text styles
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

  const StatisticsScreen({ // TODO: Add more options for filtering and sorting
    super.key,
    required this.expenses,
    required this.categories,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // Define possible time periods for statistics
  final Map<String, Duration> _timePeriods = {
    'This Month': const Duration(days: 30), // Approximation
    'Last 3 Months': const Duration(days: 90), // Approximation
    'This Year': const Duration(days: 365), // Approximation
    'All Time': const Duration(days: 365 * 100), // Essentially all time
  };

  String _selectedTimePeriod = 'This Month'; // Default selected period

  // Filter expenses based on the selected time period
  List<Expense> _getFilteredExpenses() {
    final now = DateTime.now();
    final startDate = now.subtract(_timePeriods[_selectedTimePeriod]!);

    return widget.expenses.where((expense) => expense.date.isAfter(startDate)).toList();
  }

  Map<String, double> _calculateCategoryTotals(List<Expense> expenses) {
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
      return widget.categories.firstWhere((cat) => cat.id == categoryId);
    } catch (e) { // TODO: Handle case where category is not found
      return null; 
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredExpenses = _getFilteredExpenses();
    final categoryTotals = _calculateCategoryTotals(filteredExpenses);
    final totalExpenses = filteredExpenses.fold<double>(0, (sum, item) => sum + item.amount);

    List<PieChartSectionData> showingSections() {
      return categoryTotals.entries.map((entry) {
        final category = _getCategoryById(entry.key);
        final percentage = (entry.value / totalExpenses) * 100;
        return PieChartSectionData(
          color: category != null ? Color(category.color) : Colors.grey,
          value: entry.value,
          title: '${percentage.toStringAsFixed(1)}%\n${category?.icon ?? ""}',
          radius: 100,
          titleStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
          ),
          badgeWidget: Text(
            category?.name ?? 'Unknown',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54,
            ),
          ),
          badgePositionPercentageOffset: .98,
        );
      }).toList();
    }

    Map<String, double> _calculateMonthlyTotals(List<Expense> expenses) {
      final monthlyTotals = <String, double>{};
      final dateFormat = DateFormat('MMM yyyy');

      for (final expense in expenses) {
        final monthYear = dateFormat.format(expense.date);
        monthlyTotals.update(
          monthYear,
          (value) => value + expense.amount,
          ifAbsent: () => expense.amount,
        );
      }
      return monthlyTotals;
    }


    // Generate data for the monthly spending bar chart
    List<BarChartGroupData> showingBarGroups() {
      final sortedMonths = monthlyTotals.keys.toList()
        ..sort((a, b) => DateFormat('MMM yyyy').parse(a).compareTo(DateFormat('MMM yyyy').parse(b)));

      return sortedMonths.asMap().entries.map((entry) {
        final index = entry.key;
        final monthYear = entry.value;
        final total = monthlyTotals[monthYear]!;
        return BarChartGroupData(x: index, barRods: [BarChartRodData(toY: total, color: Theme.of(context).colorScheme.primary)]);
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Statistics'),
      ),
      body: expenses.isEmpty
          ? const Center(
              child: Column( // TODO: Improve empty state message and design
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
                children: [
                  // Time Period Selection
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Time Period',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedTimePeriod,
                    items: _timePeriods.keys.map((String period) {
                      return DropdownMenuItem<String>(
                        value: period,
                        child: Text(period),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedTimePeriod = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Total Spent (${_selectedTimePeriod}): \$${totalExpenses.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              padding: const EdgeInsets.all(16.0),
              child: Column( // Wrapped content in a Column
                children: [
                  SizedBox(
                    height: 250, // Define height for PieChart
                    child: PieChart( // TODO: Add tooltips or interactions to PieChart sections
                      PieChartData(
                        sections: showingSections(),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            // Handle touch events if needed
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Spending by Month:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200, // Height for the bar chart
                    child: BarChart( // TODO: Customize bar chart appearance (e.g., colors, labels)
                      BarChartData(
                        barGroups: showingBarGroups(),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < monthlyTotals.keys.length) {
                                  final sortedMonths = monthlyTotals.keys.toList()
                                    ..sort((a, b) => DateFormat('MMM yyyy').parse(a).compareTo(DateFormat('MMM yyyy').parse(b)));
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(sortedMonths[index], style: const TextStyle(fontSize: 10)),
                                  );
                                }
                                return const Text('');
                              },
                              reservedSize: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Spending by Category:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true, // Important for ListView inside Column
                    physics: const NeverScrollableScrollPhysics(), // Disable scrolling for this ListView
                    itemCount: categoryTotals.length,
                    itemBuilder: (context, index) {
                      final categoryId = categoryTotals.keys.elementAt(index);
                      final totalAmount = categoryTotals[categoryId]!;
                      final category = _getCategoryById(categoryId);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          leading: Text(
                            category?.icon ?? '❓',
                            style: const TextStyle(fontSize: 20),
                          ),
                          title: Text(
                            category?.name ?? 'Unknown Category',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Text(
                            '\$${totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
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
      ), // TODO: Customize app bar colors and style
      body: ListView( // Changed to ListView for more settings options later
        children: [
          Consumer<ThemeNotifier>(
            builder: (context, themeNotifier, child) {
              return ListTile(
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: themeNotifier.darkTheme,
                  onChanged: (value) {
                    themeNotifier.toggleTheme();
                  },
                ),
              );
            },
          ), // TODO: Add more settings options (e.g., currency, date format, notifications)
        ],
      ),
    );
  }
}
