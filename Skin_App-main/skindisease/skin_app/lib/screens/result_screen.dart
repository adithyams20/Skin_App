// lib/screens/result_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:skin_app/l10n/app_localizations.dart';

import '../colors.dart';
import '../services/translation_service.dart';
import '../services/locale_service.dart';

class ResultScreen extends StatefulWidget {
  final Map data;

  const ResultScreen({super.key, required this.data});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;

  double confidence = 0;
  String _description = '';
  String _recommendation = '';
  String _skincare = '';
  String _diseaseDisplayName = '';

  // ✅ Complete map including previously missing diseases
  static const Map<String, String> _diseaseNamesMl = {
    'Psoriasis': 'സോറിയാസിസ്',
    'Eczema': 'എക്‌സിമ',
    'Acne': 'ആക്നേ',
    'Rosacea': 'റോസേഷ്യ',
    'Melanoma': 'മെലനോമ',
    'Vitiligo': 'വിറ്റിലിഗോ',
    'Ringworm': 'റിംഗ്‌വേം',
    'Chickenpox': 'ചിക്കൻ പോക്സ്',
    'Shingles': 'ഷിംഗ്ൾസ്',
    'Hives': 'ഹൈവ്സ്',
    'Dermatitis': 'ഡെർമറ്റൈറ്റിസ്',
    'Seborrheic Dermatitis': 'സെബോറിക് ഡെർമറ്റൈറ്റിസ്',
    'Contact Dermatitis': 'കോൺടാക്ട് ഡെർമറ്റൈറ്റിസ്',
    'Athlete-Foot': 'അത്‌ലറ്റ്സ് ഫൂട്ട്',
    'Nail Fungus': 'നെയിൽ ഫംഗസ്',
    'Cutaneous Larva Migrans': 'ക്യൂട്ടേനിയസ് ലാർവ മൈഗ്രൻസ്',
    'Warts': 'വോർട്സ്',
    'Scabies': 'സ്കേബീസ്',
    'Impetigo': 'ഇംപെറ്റൈഗോ',
    'Cellulitis': 'സെല്ലുലൈറ്റിസ്',
    'Folliculitis': 'ഫോളിക്കുലൈറ്റിസ്',
    'Basal Cell Carcinoma': 'ബേസൽ സെൽ കാർസിനോമ',
    'Squamous Cell Carcinoma': 'സ്ക്വാമസ് സെൽ കാർസിനോമ',
    'Actinic Keratosis': 'ആക്‌ടിനിക് കെരറ്റോസിസ്',
    'Tinea Versicolor': 'ടിനിയ വേഴ്‌സിക്കളർ',
    'Lupus': 'ലൂപ്പസ്',
    'Alopecia': 'അലോപ്പേഷ്യ',
    'Hyperpigmentation': 'ഹൈപ്പർ പിഗ്മെന്റേഷൻ',
    'Healthy': 'ആരോഗ്യകരം',
    'Disease Unidentified': 'രോഗം തിരിച്ചറിഞ്ഞില്ല',
  };

  @override
  void initState() {
    super.initState();
    confidence = (widget.data['Confidence'] ?? 0).toDouble();
    _description    = widget.data['Description'] ?? '';
    _recommendation = widget.data['Medical Recommendation'] ?? '';
    _skincare       = widget.data['Skincare Advice'] ?? '';
    _diseaseDisplayName = widget.data['Disease'] ?? 'Unknown';

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0, end: confidence / 100)
        .animate(_controller)
      ..addListener(() => setState(() {}));
    _controller.forward();

    _translateIfNeeded();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _translateIfNeeded() async {
    final isMl = await LocaleService.isMalayalam();
    if (!isMl || !mounted) return;

    final englishName = widget.data['Disease'] ?? 'Unknown';
    final mlName = _diseaseNamesMl[englishName];

    // Translate content fields for ALL diseases including Healthy and
    // Disease Unidentified so their description/recommendation/skincare
    // also appear in Malayalam. Only skip if the fields are actually empty.
    final hasContent = _description.trim().isNotEmpty ||
        _recommendation.trim().isNotEmpty ||
        _skincare.trim().isNotEmpty;

    if (!hasContent) {
      if (mounted && mlName != null) {
        setState(() => _diseaseDisplayName = mlName);
      }
      return;
    }

    final translated = await TranslationService.translateDiseaseFields(
      description:    _description,
      recommendation: _recommendation,
      skincare:       _skincare,
    );

    if (mounted) {
      setState(() {
        if (mlName != null) _diseaseDisplayName = mlName;
        _description    = translated['description']    ?? _description;
        _recommendation = translated['recommendation'] ?? _recommendation;
        _skincare       = translated['skincare']       ?? _skincare;
      });
    }
  }

  Color _severityColor(double c) {
    if (c > 90) return Colors.red;
    if (c > 75) return Colors.orange;
    return AppColors.primary;
  }

  String _severityText(double c, AppLocalizations l10n) {
    if (c > 90) return l10n.severe;
    if (c > 75) return l10n.moderate;
    return l10n.mild;
  }

  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) return const SizedBox();
    if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.cover);
    } else {
      return Image.file(File(path), fit: BoxFit.cover);
    }
  }

  Widget _section(IconData icon, String title, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark)),
                const SizedBox(height: 6),
                Text(
                  text.isNotEmpty ? text : '...',
                  style: const TextStyle(color: AppColors.textLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final englishName = widget.data['Disease'] ?? 'Unknown';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.diagnosisResult),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: _buildImage(widget.data['image']),
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.aquaGradient,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Column(
              children: [
                Text(
                  _diseaseDisplayName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_diseaseDisplayName != englishName) ...[
                  const SizedBox(height: 4),
                  Text(
                    englishName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],

                const SizedBox(height: 14),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _animation.value,
                    minHeight: 8,
                    backgroundColor: Colors.white30,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  '${l10n.confidence}: ${confidence.toStringAsFixed(2)}%',
                  style: const TextStyle(color: Colors.white),
                ),

                const SizedBox(height: 14),

                if (englishName != 'Healthy' &&
                    englishName != 'Disease Unidentified') ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 6),
                    decoration: BoxDecoration(
                      color: _severityColor(confidence),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _severityText(confidence, l10n),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          _section(Icons.info, l10n.description, _description),
          _section(Icons.medical_services, l10n.medicalRecommendation,
              _recommendation),
          _section(Icons.spa, l10n.skincareAdvice, _skincare),
        ],
      ),
    );
  }
}