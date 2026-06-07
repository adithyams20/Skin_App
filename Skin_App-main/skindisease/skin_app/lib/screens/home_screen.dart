// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:skin_app/l10n/app_localizations.dart';

import '../colors.dart';
import '../session.dart';
import 'upload_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'admin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final screens = [
      const UploadScreen(),
      const HistoryScreen(),
      ProfileScreen(
        username: UserSession.username,
        role: UserSession.role,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: Text(l10n.appTitle),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.aquaGradient),
        ),
      ),

      body: screens[index],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: AppColors.primary,
        onTap: (i) => setState(() => index = i),
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.camera_alt), label: l10n.scanTab),
          BottomNavigationBarItem(
              icon: const Icon(Icons.history), label: l10n.historyTab),
          BottomNavigationBarItem(
              icon: const Icon(Icons.person), label: l10n.profileTab),
        ],
      ),

      floatingActionButton: UserSession.role == 'admin'
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminScreen()),
                );
              },
            )
          : null,
    );
  }
}