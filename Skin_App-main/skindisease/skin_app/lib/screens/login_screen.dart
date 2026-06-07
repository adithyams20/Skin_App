// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skin_app/l10n/app_localizations.dart';

import '../services/api_service.dart';
import '../session.dart';
import '../colors.dart';
import '../widgets.dart';
import 'home_screen.dart';
import 'admin_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final String role;

  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final u = TextEditingController();
  final p = TextEditingController();

  bool showPassword = false;
  bool loading = false;

  void login() async {
    if (u.text.isEmpty || p.text.isEmpty) return;

    setState(() => loading = true);

    final res = await ApiService.login(u.text.trim(), p.text.trim());

    setState(() => loading = false);

    if (res['message'] == 'Login successful') {
      UserSession.username = u.text.trim();
      UserSession.role = res['role'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', u.text.trim());
      await prefs.setString('role', res['role']);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => res['role'] == 'admin'
              ? const AdminScreen()
              : const HomeScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res['error'] ?? 'Login failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppWidgets.appBar(context, l10n.loginTitle),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.aquaGradient,
              ),
              child: const Icon(Icons.health_and_safety,
                  size: 45, color: Colors.white),
            ),

            const SizedBox(height: 20),

            Text(l10n.welcomeBack,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),

            const SizedBox(height: 30),

            AppWidgets.input(
              controller: u,
              label: l10n.username,
              icon: Icons.person,
            ),

            const SizedBox(height: 15),

            AppWidgets.input(
              controller: p,
              label: l10n.password,
              icon: Icons.lock,
              isPassword: true,
              showPassword: showPassword,
              togglePassword: () =>
                  setState(() => showPassword = !showPassword),
            ),

            const SizedBox(height: 25),

            loading
                ? const CircularProgressIndicator()
                : AppWidgets.button(
                    text: l10n.loginButton,
                    icon: Icons.login,
                    onPressed: login,
                  ),

            if (widget.role == 'user') ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                child: Text(l10n.noAccount),
              ),
            ],
          ],
        ),
      ),
    );
  }
}