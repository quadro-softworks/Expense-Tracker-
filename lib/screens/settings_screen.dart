import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/expense_provider.dart';
import 'category_management_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer2<SettingsProvider, ExpenseProvider>(
        builder: (context, settingsProvider, expenseProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader('Appearance'),
              _buildThemeSelector(context, settingsProvider),
              const SizedBox(height: 20),

              _buildSectionHeader('Currency'),
              _buildCurrencySelector(context, settingsProvider),
              const SizedBox(height: 20),

              _buildSectionHeader('Categories'),
              _buildCategoryOptions(context, expenseProvider),
              const SizedBox(height: 20),

              _buildSectionHeader('Data'),
              _buildDataOptions(context, expenseProvider),
              const SizedBox(height: 20),

              _buildSectionHeader('About'),
              _buildAboutOptions(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme'),
            subtitle: Text(_getThemeName(settingsProvider.themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(context, settingsProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.attach_money),
        title: const Text('Currency'),
        subtitle: Text(
          '${settingsProvider.currency} (${settingsProvider.currencySymbol})',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showCurrencyDialog(context, settingsProvider),
      ),
    );
  }

  Widget _buildCategoryOptions(
    BuildContext context,
    ExpenseProvider expenseProvider,
  ) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.category),
        title: const Text('Manage Categories'),
        subtitle: Text('${expenseProvider.categories.length} categories'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CategoryManagementScreen(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataOptions(
    BuildContext context,
    ExpenseProvider expenseProvider,
  ) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            subtitle: const Text('Export expenses to CSV'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showExportDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Import Data'),
            subtitle: const Text('Import expenses from CSV'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showImportDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Clear All Data',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('Delete all expenses and categories'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showClearDataDialog(context, expenseProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutOptions(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: const Text('Version 1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            subtitle: const Text('Get help using the app'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showHelpDialog(context),
          ),
        ],
      ),
    );
  }

  String _getThemeName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showThemeDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Choose Theme'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  ThemeMode.values.map((mode) {
                    return RadioListTile<ThemeMode>(
                      title: Text(_getThemeName(mode)),
                      value: mode,
                      groupValue: settingsProvider.themeMode,
                      onChanged: (value) {
                        if (value != null) {
                          settingsProvider.setThemeMode(value);
                          Navigator.of(context).pop();
                        }
                      },
                    );
                  }).toList(),
            ),
          ),
    );
  }

  void _showCurrencyDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Choose Currency'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: SettingsProvider.availableCurrencies.length,
                itemBuilder: (context, index) {
                  final currency = SettingsProvider.availableCurrencies[index];
                  return RadioListTile<String>(
                    title: Text('${currency['name']} (${currency['symbol']})'),
                    subtitle: Text(currency['code']!),
                    value: currency['code']!,
                    groupValue: settingsProvider.currency,
                    onChanged: (value) {
                      if (value != null) {
                        settingsProvider.setCurrency(value);
                        Navigator.of(context).pop();
                      }
                    },
                  );
                },
              ),
            ),
          ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Export Data'),
            content: const Text(
              'Export functionality will be implemented in a future update.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Import Data'),
            content: const Text(
              'Import functionality will be implemented in a future update.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showClearDataDialog(
    BuildContext context,
    ExpenseProvider expenseProvider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear All Data'),
            content: const Text(
              'This will permanently delete all your expenses and custom categories. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Clear data functionality will be implemented soon',
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Clear All'),
              ),
            ],
          ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Expense Tracker',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.account_balance_wallet, size: 48),
      children: const [
        Text(
          'A comprehensive expense tracking application built with Flutter.',
        ),
        SizedBox(height: 16),
        Text('Features:'),
        Text('• Track daily expenses'),
        Text('• Categorize expenses'),
        Text('• View statistics and charts'),
        Text('• Dark/Light theme support'),
        Text('• Local data storage'),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Help & Support'),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'How to use Expense Tracker:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('1. Tap the + button to add a new expense'),
                  Text('2. Fill in the expense details and select a category'),
                  Text('3. View your expenses in the Expenses tab'),
                  Text('4. Check statistics in the Statistics tab'),
                  Text('5. Customize settings in the Settings tab'),
                  SizedBox(height: 16),
                  Text('Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('• Swipe left on an expense to delete it'),
                  Text('• Tap on an expense to edit it'),
                  Text('• Use the search feature to find specific expenses'),
                  Text('• Change themes in Settings for better visibility'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it'),
              ),
            ],
          ),
    );
  }
}
