// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skin_app/l10n/app_localizations.dart';

import '../session.dart';
import '../colors.dart';
import '../widgets.dart';
import '../main.dart';
import '../services/api_service.dart';
import '../services/locale_service.dart';
import '../services/translation_service.dart';
import 'role_select_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String username;
  final String role;

  const ProfileScreen({
    super.key,
    required this.username,
    required this.role,
  });

  // ✅ On logout: clear session AND locale — returns to RoleSelectScreen
  void logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('role');
    await prefs.remove('app_locale');

    UserSession.username = '';
    UserSession.role = '';

    MyApp.setLocale(context, const Locale('en'));

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
      (route) => false,
    );
  }

  void changePassword(BuildContext context, AppLocalizations l10n) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.changePassword),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(labelText: l10n.newPassword),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              final res =
                  await ApiService.changePassword(username, controller.text);
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(res['message'] ?? res['error'] ?? 'Updated')),
              );
            },
            child: Text(l10n.update),
          ),
        ],
      ),
    );
  }

  void changeLanguage(BuildContext context) async {
    final current = await LocaleService.getSavedLocale();
    String selected = current.languageCode;

    final languages = [
      {'code': 'en', 'label': 'English', 'native': 'English'},
      {'code': 'ml', 'label': 'Malayalam', 'native': 'മലയാളം'},
    ];

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.language, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Language / ഭാഷ'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((lang) {
              final isSelected = selected == lang['code'];
              return GestureDetector(
                onTap: () => setDialogState(() => selected = lang['code']!),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lang['label']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textDark,
                                )),
                            Text(lang['native']!,
                                style: const TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle,
                            color: AppColors.primary, size: 20),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
              onPressed: () async {
                await LocaleService.saveLocale(selected);
                await TranslationService.clearCache();
                if (!ctx.mounted) return;
                MyApp.setLocale(ctx, Locale(selected));
                Navigator.pop(ctx);
              },
              child: const Text('Save',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Translate the role value using l10n so it shows in Malayalam when needed
  String _localizedRole(String role, AppLocalizations l10n) {
    if (role == 'user') return l10n.roleUser;
    if (role == 'admin') return l10n.roleAdmin;
    return role;
  }

  Widget tile(IconData icon, String title, VoidCallback onTap) {
    return AppWidgets.card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppWidgets.appBar(context, l10n.profileTitle),

      body: Column(
        children: [
          // Gradient header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(
              gradient: AppColors.aquaGradient,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 35,
                  child: Icon(Icons.person, size: 30),
                ),
                const SizedBox(height: 10),
                Text(username,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                // ✅ role value now goes through l10n so it shows in Malayalam
                Text('${l10n.role}: ${_localizedRole(role, l10n)}',
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                tile(Icons.lock, l10n.changePassword,
                    () => changePassword(context, l10n)),

                tile(Icons.language, 'Language / ഭാഷ',
                    () => changeLanguage(context)),

                const SizedBox(height: 10),

                AppWidgets.button(
                  text: l10n.logout,
                  icon: Icons.logout,
                  onPressed: () => logout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}