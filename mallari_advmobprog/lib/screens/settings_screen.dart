import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SwitchListTile(
          // ENHANCEMENT 3: Dark/light mode switch in Settings.
          title: const Text('Dark Mode'),
          subtitle: const Text('Toggle the application theme.'),
          value: themeModel.isDark,
          onChanged: (_) {
            // Changes the application theme.
            themeModel.toggleTheme();
          },
        ),
      ),
    );
  }
}