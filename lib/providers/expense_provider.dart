import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/category.dart' as models;
import '../services/database_service.dart';

class ExpenseProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<Expense> _expenses = [];
  List<models.Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Expense> get expenses => _expenses;
  List<models.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    await loadCategories();
    await loadExpenses();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    try {
      _setLoading(true);
      _setError(null);
      _categories = await _databaseService.getCategories();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load categories: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addCategory(models.Category category) async {
    try {
      _setError(null);
      await _databaseService.insertCategory(category);
      _categories.add(category);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add category: $e');
    }
  }

  Future<void> updateCategory(models.Category category) async {
    try {
      _setError(null);
      await _databaseService.updateCategory(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      _setError(null);
      await _databaseService.deleteCategory(categoryId);
      _categories.removeWhere((c) => c.id == categoryId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete category: $e');
    }
  }

  Future<void> loadExpenses() async {
    try {
      _setLoading(true);
      _setError(null);
      _expenses = await _databaseService.getExpenses();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load expenses: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      _setError(null);
      await _databaseService.insertExpense(expense);
      _expenses.insert(0, expense);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add expense: $e');
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      _setError(null);
      await _databaseService.updateExpense(expense);
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = expense;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update expense: $e');
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      _setError(null);
      await _databaseService.deleteExpense(expenseId);
      _expenses.removeWhere((e) => e.id == expenseId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete expense: $e');
    }
  }

  Future<void> searchExpenses(String query) async {
    try {
      _setLoading(true);
      _setError(null);
      if (query.isEmpty) {
        await loadExpenses();
      } else {
        _expenses = await _databaseService.searchExpenses(query);
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to search expenses: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> filterExpensesByCategory(String? categoryId) async {
    try {
      _setLoading(true);
      _setError(null);
      if (categoryId == null) {
        await loadExpenses();
      } else {
        _expenses = await _databaseService.getExpensesByCategory(categoryId);
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to filter expenses: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> filterExpensesByDateRange(DateTime start, DateTime end) async {
    try {
      _setLoading(true);
      _setError(null);
      _expenses = await _databaseService.getExpensesByDateRange(start, end);
      notifyListeners();
    } catch (e) {
      _setError('Failed to filter expenses by date: $e');
    } finally {
      _setLoading(false);
    }
  }

  models.Category? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((cat) => cat.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  double get totalExpenses {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> get expensesByCategory {
    Map<String, double> categoryTotals = {};
    for (final expense in _expenses) {
      final category = getCategoryById(expense.categoryId);
      final categoryName = category?.name ?? 'Unknown';
      categoryTotals[categoryName] =
          (categoryTotals[categoryName] ?? 0) + expense.amount;
    }
    return categoryTotals;
  }

  List<Expense> getExpensesForMonth(DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    return _expenses.where((expense) {
      return expense.date.isAfter(
            startOfMonth.subtract(const Duration(days: 1)),
          ) &&
          expense.date.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();
  }

  double getTotalForMonth(DateTime month) {
    final monthExpenses = getExpensesForMonth(month);
    return monthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }
}
