// lib/screens/history_screen.dart

import 'package:flutter/material.dart';
import 'package:skin_app/l10n/app_localizations.dart';

import '../services/api_service.dart';
import '../services/locale_service.dart';
import '../colors.dart';
import '../widgets.dart';
import '../session.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List history = [];
  bool loading = true;
  bool _isMalayalam = false;

  // ✅ Same transliteration map as result_screen — keeps disease names
  // consistent between history cards and the result detail screen.
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
    'Warts': 'വോർട്സ്',
    'Scabies': 'സ്കേബീസ്',
    'Impetigo': 'ഇംപെറ്റൈഗോ',
    'Cellulitis': 'സെല്ലുലൈറ്റിസ്',
    'Folliculitis': 'ഫോളിക്കുലൈറ്റിസ്',
    'Basal Cell Carcinoma': 'ബേസൽ സെൽ കാർസിനോമ',
    'Squamous Cell Carcinoma': 'സ്ക്വാമസ് സെൽ കാർസിനോമ',
    'Actinic Keratosis': 'ആക്‌ടിനിക് കെരറ്റോസിസ്',
    'Tinea Versicolor': 'ടിനിയ വേഴ്‌സിക്കളർ',
    'Cutaneous Larva Migrans': 'ക്യൂട്ടേനിയസ് ലാർവ മൈഗ്രൻസ്',
    'Lupus': 'ലൂപ്പസ്',
    'Alopecia': 'അലോപ്പേഷ്യ',
    'Hyperpigmentation': 'ഹൈപ്പർ പിഗ്മെന്റേഷൻ',
    'Healthy': 'ആരോഗ്യകരം',
    'Disease Unidentified': 'രോഗം തിരിച്ചറിഞ്ഞില്ല',
  };

  String _displayName(String englishName) {
    if (!_isMalayalam) return englishName;
    return _diseaseNamesMl[englishName] ?? englishName;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    // ✅ Use UserSession directly — no need to re-read SharedPreferences
    final isMl = await LocaleService.isMalayalam();
    final res = await ApiService.getHistory(UserSession.username);
    if (!mounted) return;
    setState(() {
      _isMalayalam = isMl;
      history = res;
      loading = false;
    });
  }

  Widget _historyCard(Map h, AppLocalizations l10n) {
    int id = h['id'] is int ? h['id'] : int.tryParse(h['id'].toString()) ?? 0;
    final englishName = h['disease'] ?? 'Unknown';
    final displayName = _displayName(englishName);

    return Dismissible(
      key: Key(id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.delete_outline, color: Colors.white, size: 26),
            const SizedBox(height: 4),
            Text(
              l10n.deleteRecord,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        bool confirmed = false;
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.delete_outline, color: Colors.red),
                const SizedBox(width: 8),
                // ✅ Wrap in Flexible to prevent overflow in the dialog title
                Flexible(child: Text(l10n.deleteRecord)),
              ],
            ),
            content: Text(l10n.deleteConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  confirmed = true;
                  Navigator.pop(context);
                },
                child: Text(l10n.delete,
                    style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        return confirmed;
      },
      onDismissed: (_) async {
        setState(() {
          history.removeWhere((item) => item['id'] == id);
        });
        await ApiService.deleteHistory(id);
        if (!mounted) return;
        // ✅ Show localized snackbar after deletion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.recordDeleted,
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResultScreen(
                data: {
                  'Disease': englishName,
                  'Confidence': h['confidence'] ?? 0,
                  'Description': h['description'] ?? '',
                  'Medical Recommendation': h['recommendation'] ?? '',
                  'Skincare Advice': h['skincare'] ?? '',
                  'image': h['image'] ?? '',
                },
              ),
            ),
          );
        },
        child: AppWidgets.card(
          child: Row(
            children: [
              // Image thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  h['image'] ?? '',
                  height: 70,
                  width: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.image,
                        size: 32, color: AppColors.textLight),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // ✅ Expanded prevents overflow — text is constrained to available width
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Disease name in Malayalam if locale is ml
                    Text(
                      displayName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    // ✅ Show English name below if transliterated
                    if (_isMalayalam && displayName != englishName) ...[
                      Text(
                        englishName,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textLight),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.confidence}: ${(h["confidence"] ?? 0).toStringAsFixed(2)}%',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textLight),
                    ),
                    if ((h['timestamp'] ?? '').toString().trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 11, color: AppColors.textLight),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              h['timestamp'].toString(),
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textLight),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios,
                  size: 14, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFEDF7EE),
      appBar: AppWidgets.appBar(context, l10n.historyTitle),
      body: loading
          ? AppWidgets.loader()
          : history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history,
                          size: 64, color: AppColors.textLight),
                      const SizedBox(height: 12),
                      Text(l10n.noHistory,
                          style:
                              const TextStyle(color: AppColors.textLight)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: history.length,
                  itemBuilder: (_, i) => _historyCard(history[i], l10n),
                ),
    );
  }
}