// lib/screens/upload_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skin_app/l10n/app_localizations.dart';

import '../colors.dart';
import '../widgets.dart';
import 'predict_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? image;
  bool _picking = false; // ✅ guard against double-tap crash

  Future pickImage(ImageSource source) async {
    // ✅ If picker is already open, ignore the second tap
    if (_picking) return;
    setState(() => _picking = true);

    try {
      final picked = await ImagePicker().pickImage(source: source);
      if (picked != null) setState(() => image = File(picked.path));
    } catch (e) {
      // silently ignore — e.g. user cancelled or already_active edge case
      debugPrint('ImagePicker error: $e');
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void goToPredict(AppLocalizations l10n) {
    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectImage)),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PredictScreen(image: image!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppWidgets.appBar(context, l10n.uploadTitle),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            Text(
              l10n.uploadTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              l10n.uploadSubtitle,
              style: const TextStyle(color: AppColors.textLight),
            ),

            const SizedBox(height: 20),

            // Image preview card
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: image != null
                    ? Image.file(image!, fit: BoxFit.cover)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image,
                              size: 60, color: AppColors.textLight),
                          const SizedBox(height: 10),
                          Text(
                            l10n.noImageSelected,
                            style:
                                const TextStyle(color: AppColors.textLight),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 25),

            Row(
              children: [
                Expanded(
                  child: AppWidgets.button(
                    text: l10n.gallery,
                    icon: Icons.photo,
                    onPressed:
                        _picking ? () {} : () => pickImage(ImageSource.gallery),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppWidgets.button(
                    text: l10n.camera,
                    icon: Icons.camera_alt,
                    onPressed:
                        _picking ? () {} : () => pickImage(ImageSource.camera),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            AppWidgets.button(
              text: l10n.continuePrediction,
              icon: Icons.arrow_forward,
              onPressed: () => goToPredict(l10n),
            ),
          ],
        ),
      ),
    );
  }
}