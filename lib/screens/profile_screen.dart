import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  String _selectedCurrency = 'USD';

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD']; // Sample currencies

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('userName') ?? '';
      _selectedCurrency = prefs.getString('preferredCurrency') ?? 'USD';
    });
  }

  void _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', _nameController.text);
    prefs.setString('preferredCurrency', _selectedCurrency);
  }

  @override
  void dispose() {
    _nameController.dispose(); // TODO: Consider saving data on every change instead of just dispose
    _saveProfileData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
 children: [
            // Name Field (already added above, this was a duplicate)

            // Preferred Currency Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Preferred Currency',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_exchange),
              ),
              value: _selectedCurrency,
              items: _currencies.map((String currency) {
                return DropdownMenuItem<String>(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCurrency = newValue;
                  });
                  _saveProfileData();
                }
              },
            ),
            const SizedBox(height: 24),

            // TODO: Implement real spending summary
            Text(
              'Spending Summary (Coming Soon)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Detailed spending statistics will appear here.'),
          ],
        ),
      ),
    );
  }
}