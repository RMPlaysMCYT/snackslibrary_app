import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('App Theme', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            RadioListTile<ThemeMode>(
              title: Text('Follow System'),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                themeProvider.setTheme(value!);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text('Light Mode'),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                themeProvider.setTheme(value!);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text('Dark Mode'),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                themeProvider.setTheme(value!);
              },
            ),
          ],
        ),
      ),
    );
  }
}
