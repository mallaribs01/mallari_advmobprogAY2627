import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../services/user_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    try {
      final userService = UserService();

      // Check whether the current account is a Firebase account.
      if (userService.isFirebaseLoggedIn()) {
        await userService.signOut();
      } else {
        // DummyJSON logout.
        await userService.logout();
      }

      if (!context.mounted) return;

      // Remove all previous screens and return to Sign In.
      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // =====================================================
          // APPEARANCE
          // =====================================================
          Card(
            elevation: 0,
            child: SwitchListTile(
              title: const Text(
                'Dark Mode',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Toggle the application theme.'),
              secondary: Icon(
                themeModel.isDark ? Icons.dark_mode : Icons.light_mode,
              ),
              value: themeModel.isDark,
              onChanged: (_) {
                themeModel.toggleTheme();
              },
            ),
          ),

          const SizedBox(height: 16),

          // =====================================================
          // ACCOUNT
          // =====================================================
          Card(
            elevation: 0,
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Logout',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              subtitle: const Text('Sign out of your current account.'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _logout(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
