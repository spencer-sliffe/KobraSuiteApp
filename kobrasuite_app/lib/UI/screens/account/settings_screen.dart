// lib/screens/account/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/general/theme_notifier.dart';
import '../../../models/general/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    AppTheme currentTheme = themeNotifier.currentTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text(
              'Choose Theme',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          RadioListTile<AppTheme>(
            title: const Text('Light Green Theme'),
            value: AppTheme.LightGreen,
            groupValue: currentTheme,
            onChanged: (AppTheme? value) {
              if (value != null) {
                themeNotifier.setTheme(value);
              }
            },
          ),
          RadioListTile<AppTheme>(
            title: const Text('Dark Green Theme'),
            value: AppTheme.DarkGreen,
            groupValue: currentTheme,
            onChanged: (AppTheme? value) {
              if (value != null) {
                themeNotifier.setTheme(value);
              }
            },
          ),
          RadioListTile<AppTheme>(
            title: const Text('Light Blue Theme'),
            value: AppTheme.LightBlue,
            groupValue: currentTheme,
            onChanged: (AppTheme? value) {
              if (value != null) {
                themeNotifier.setTheme(value);
              }
            },
          ),
          RadioListTile<AppTheme>(
            title: const Text('Dark Blue Theme'),
            value: AppTheme.DarkBlue,
            groupValue: currentTheme,
            onChanged: (AppTheme? value) {
              if (value != null) {
                themeNotifier.setTheme(value);
              }
            },
          ),
          RadioListTile<AppTheme>(
            title: const Text('Psychedelic Theme'),
            value: AppTheme.Psychedelic,
            groupValue: currentTheme,
            onChanged: (AppTheme? value) {
              if (value != null) {
                themeNotifier.setTheme(value);
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Primary Color'),
            onTap: () {
              // Future color picking logic
            },
          ),
        ],
      ),
    );
  }
}