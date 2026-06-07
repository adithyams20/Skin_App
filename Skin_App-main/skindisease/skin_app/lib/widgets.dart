import 'package:flutter/material.dart';
import 'colors.dart';

class AppWidgets {

  // =====================================
  // 🌿 CARD (MODERN CLEAN)
  // =====================================
  static Widget card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // =====================================
  // 🌿 INPUT FIELD
  // =====================================
  static Widget input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool showPassword = false,
    VoidCallback? togglePassword,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? !showPassword : false,
        style: const TextStyle(color: AppColors.textDark),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.textLight),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    showPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: AppColors.textLight,
                  ),
                  onPressed: togglePassword,
                )
              : null,
          hintText: label,
          hintStyle: const TextStyle(color: AppColors.textLight),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // =====================================
  // 🌿 PRIMARY BUTTON (AQUA GRADIENT)
  // =====================================
  static Widget button({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: AppColors.aquaGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 10,
          ),
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // =====================================
  // 🌱 SECONDARY BUTTON
  // =====================================
  static Widget softButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.border),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // =====================================
  // 🌿 APP BAR (GLOBAL AQUA GRADIENT)
  // =====================================
  static PreferredSizeWidget appBar(
      BuildContext context, String title) {
    return AppBar(
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.aquaGradient,
        ),
      ),
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  // =====================================
  // 🌿 ICON BADGE
  // =====================================
  static Widget iconBadge(IconData icon) {
    return CircleAvatar(
      backgroundColor: AppColors.primary.withOpacity(0.15),
      child: Icon(icon, color: AppColors.primary),
    );
  }

  // =====================================
  // 🌿 LOADER
  // =====================================
  static Widget loader() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }
}