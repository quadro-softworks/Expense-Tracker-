import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer2<ExpenseProvider, SettingsProvider>(
        builder: (context, expenseProvider, settingsProvider, child) {
          if (expenseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (expenseProvider.expenses.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No expenses to analyze',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add some expenses to see statistics',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMonthSelector(),
                const SizedBox(height: 20),

                _buildSummaryCards(expenseProvider, settingsProvider),
                const SizedBox(height: 20),

                _buildCategoryChart(expenseProvider),
                const SizedBox(height: 20),

                _buildMonthlyTrend(expenseProvider, settingsProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedMonth = DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month - 1,
                  );
                });
              },
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              DateFormat('MMMM yyyy').format(_selectedMonth),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () {
                final nextMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month + 1,
                );
                if (nextMonth.isBefore(DateTime.now()) ||
                    nextMonth.month == DateTime.now().month) {
                  setState(() {
                    _selectedMonth = nextMonth;
                  });
                }
              },
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(
    ExpenseProvider expenseProvider,
    SettingsProvider settingsProvider,
  ) {
    final monthExpenses = expenseProvider.getExpensesForMonth(_selectedMonth);
    final monthTotal = expenseProvider.getTotalForMonth(_selectedMonth);
    final totalExpenses = expenseProvider.totalExpenses;
    final averagePerDay =
        monthExpenses.isNotEmpty ? monthTotal / DateTime.now().day : 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'This Month',
            settingsProvider.formatAmount(monthTotal),
            Icons.calendar_month,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Total',
            settingsProvider.formatAmount(totalExpenses),
            Icons.account_balance_wallet,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Daily Avg',
            settingsProvider.formatAmount(averagePerDay),
            Icons.trending_up,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart(ExpenseProvider expenseProvider) {
    final categoryData = expenseProvider.expensesByCategory;

    if (categoryData.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No category data available')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expenses by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(
                    categoryData,
                    expenseProvider,
                  ),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildCategoryLegend(categoryData, expenseProvider),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<String, double> categoryData,
    ExpenseProvider expenseProvider,
  ) {
    final total = categoryData.values.fold(0.0, (sum, value) => sum + value);
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.brown,
    ];

    return categoryData.entries.map((entry) {
      final index = categoryData.keys.toList().indexOf(entry.key);
      final percentage = (entry.value / total * 100);

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildCategoryLegend(
    Map<String, double> categoryData,
    ExpenseProvider expenseProvider,
  ) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.brown,
    ];

    return Column(
      children:
          categoryData.entries.map((entry) {
            final index = categoryData.keys.toList().indexOf(entry.key);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(entry.key)),
                  Text(
                    context.read<SettingsProvider>().formatAmount(entry.value),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildMonthlyTrend(
    ExpenseProvider expenseProvider,
    SettingsProvider settingsProvider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Expenses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...expenseProvider.expenses.take(5).map((expense) {
              final category = expenseProvider.getCategoryById(
                expense.categoryId,
              );
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      category != null
                          ? Color(category.color).withAlpha(50)
                          : Colors.grey.withAlpha(50),
                  child: Text(
                    category?.icon ?? '📦',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                title: Text(expense.title),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(expense.date)),
                trailing: Text(
                  settingsProvider.formatAmount(expense.amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
