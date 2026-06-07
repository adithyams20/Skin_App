// lib/screens/role_select_screen.dart

import 'package:flutter/material.dart';
import '../colors.dart';
import '../widgets.dart';
import 'login_screen.dart';
import 'language_select_screen.dart';

// ✅ "Continue as User" → Language Select → Login
// ✅ "Continue as Admin" → Login directly (no language select needed)

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  Widget _roleButton(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: AppWidgets.button(
        text: title,
        icon: icon,
        onPressed: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Column(
        children: [

          // 🔥 TOP GRADIENT HEADER — always English (before locale chosen)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 80, bottom: 40),
            decoration: const BoxDecoration(
              gradient: AppColors.aquaGradient,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: Column(
              children: const [
                Icon(Icons.health_and_safety,
                    size: 60, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  "DERMASENSE",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ✅ User: go to language select first
                _roleButton(
                  context,
                  "Continue as User",
                  Icons.person,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LanguageSelectScreen(role: 'user'),
                    ),
                  ),
                ),

                // ✅ Admin: skip language select, go straight to login
                _roleButton(
                  context,
                  "Continue as Admin",
                  Icons.admin_panel_settings,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(role: 'admin'),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}