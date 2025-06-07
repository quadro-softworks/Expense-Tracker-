import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _currencyKey = 'currency';
  static const String _firstLaunchKey = 'first_launch';

  ThemeMode _themeMode = ThemeMode.system;
  String _currency = 'USD';
  bool _isFirstLaunch = true;

  ThemeMode get themeMode => _themeMode;
  String get currency => _currency;
  bool get isFirstLaunch => _isFirstLaunch;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeIndex];

    _currency = prefs.getString(_currencyKey) ?? 'USD';

    _isFirstLaunch = prefs.getBool(_firstLaunchKey) ?? true;

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  Future<void> setCurrency(String currency) async {
    if (_currency == currency) return;

    _currency = currency;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency);
  }

  Future<void> setFirstLaunchCompleted() async {
    _isFirstLaunch = false;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, false);
  }

  String get currencySymbol {
    switch (_currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'INR':
        return '₹';
      default:
        return '\$';
    }
  }

  static const List<Map<String, String>> availableCurrencies = [
    {'code': 'USD', 'name': 'US Dollar', 'symbol': '\$'},
    {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
    {'code': 'GBP', 'name': 'British Pound', 'symbol': '£'},
    {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': '¥'},
    {'code': 'INR', 'name': 'Indian Rupee', 'symbol': '₹'},
  ];

  String formatAmount(double amount) {
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _themeMode = ThemeMode.system;
    _currency = 'USD';
    _isFirstLaunch = true;

    notifyListeners();
  }
}
