import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/category.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expense_tracker.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date INTEGER NOT NULL,
        categoryId TEXT NOT NULL,
        description TEXT,
        imageUrl TEXT,
        recurrenceType INTEGER NOT NULL DEFAULT 0,
        nextDueDate INTEGER,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');

    final defaultCategories = Category.getDefaultCategories();
    for (final category in defaultCategories) {
      await db.insert('categories', category.toMap());
    }
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(String id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Expense>> getExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<List<Expense>> getExpensesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<List<Expense>> getExpensesByCategory(String categoryId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(String id) async {
    final db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalExpenses() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses',
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<double> getTotalExpensesForMonth(DateTime month) async {
    final db = await database;
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE date >= ? AND date <= ?',
      [startOfMonth.millisecondsSinceEpoch, endOfMonth.millisecondsSinceEpoch],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<Map<String, double>> getCategoryTotals() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT c.name, SUM(e.amount) as total 
      FROM expenses e 
      JOIN categories c ON e.categoryId = c.id 
      GROUP BY c.id, c.name
    ''');

    Map<String, double> categoryTotals = {};
    for (final row in result) {
      categoryTotals[row['name'] as String] = row['total'] as double;
    }
    return categoryTotals;
  }

  Future<List<Map<String, dynamic>>> getMonthlyExpenses() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        strftime('%Y-%m', datetime(date/1000, 'unixepoch')) as month,
        SUM(amount) as total
      FROM expenses 
      GROUP BY strftime('%Y-%m', datetime(date/1000, 'unixepoch'))
      ORDER BY month DESC
      LIMIT 12
    ''');
    return result;
  }

  Future<List<Expense>> searchExpenses(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
