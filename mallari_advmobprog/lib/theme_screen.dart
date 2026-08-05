import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme_model.dart';

/// Screen for changing the application theme to dark or light theme.
class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("App State Example")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SwitchListTile(
          title: const Text("Dark Mode"),
          subtitle: const Text("Toggle the application theme."),
          value: themeModel.isDark,
          onChanged: (_) => themeModel.toggleTheme(),
        ),
      ),
    );
  }
}
