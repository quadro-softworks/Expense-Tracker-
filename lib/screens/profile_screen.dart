import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> _currencies = [
    'ETB',
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'CAD',
    'AUD',
  ]; // ETB is now the main/default
  String _selectedCurrency = 'ETB'; // Default to ETB

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('userName') ?? '';
      _selectedCurrency =
          prefs.getString('preferredCurrency') ?? 'ETB'; // Default to ETB
    });
  }

  void _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', _nameController.text);
    prefs.setString('preferredCurrency', _selectedCurrency);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            DropdownButton<String>(
              value: _selectedCurrency,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCurrency = newValue!;
                });
              },
              items:
                  _currencies.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
            ),
            ElevatedButton(
              onPressed: () {
                _saveProfileData();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Profile updated')));
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
