// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../colors.dart';
import 'role_select_screen.dart';
import 'home_screen.dart';
import 'admin_screen.dart';
import '../session.dart';

// ✅ Splash always goes to RoleSelectScreen.
// Language selection now happens INSIDE role_select_screen after user taps "Continue as User".
// Admin never needs language selection.

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();

    Future.delayed(const Duration(seconds: 2), _navigate);
  }

  Future<void> _navigate() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final role = prefs.getString('role') ?? '';

    if (username.isNotEmpty && role.isNotEmpty) {
      // ✅ Active session — go straight in (locale was saved at login time)
      UserSession.username = username;
      UserSession.role = role;
      _go(role == 'admin' ? const AdminScreen() : const HomeScreen());
    } else {
      // ✅ No session — always go to RoleSelectScreen first (in English)
      _go(const RoleSelectScreen());
    }
  }

  void _go(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Splash screen always shows in English (before locale is known)
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.aquaGradient),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.health_and_safety, size: 90, color: Colors.white),
                SizedBox(height: 20),
                Text(
                  'DERMASENSE',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Skin Disease Detection',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}