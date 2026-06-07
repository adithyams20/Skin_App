// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:skin_app/l10n/app_localizations.dart';

import '../services/api_service.dart';
import '../colors.dart';
import '../widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final u = TextEditingController();
  final p = TextEditingController();

  bool loading = false;
  bool showPassword = false;

  void register() async {
    if (u.text.isEmpty || p.text.isEmpty) return;

    setState(() => loading = true);

    final res = await ApiService.register(u.text, p.text);

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? res['error'])));

    if (res['message'] != null) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppWidgets.appBar(context, l10n.registerTitle),

      body: Padding(
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
              child: const Icon(Icons.person_add,
                  size: 45, color: Colors.white),
            ),

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
                    text: l10n.registerButton,
                    icon: Icons.app_registration,
                    onPressed: register,
                  ),
          ],
        ),
      ),
    );
  }
}