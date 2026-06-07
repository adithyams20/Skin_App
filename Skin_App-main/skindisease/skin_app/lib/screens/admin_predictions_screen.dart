import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../colors.dart';
import '../widgets.dart';

class AdminPredictionsScreen extends StatefulWidget {
  const AdminPredictionsScreen({super.key});

  @override
  State<AdminPredictionsScreen> createState() =>
      _AdminPredictionsScreenState();
}

class _AdminPredictionsScreenState extends State<AdminPredictionsScreen> {
  List data = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    var res = await ApiService.getAdminHistory();
    setState(() {
      data = res;
      loading = false;
    });
  }

  void _confirmDelete(BuildContext context, int id, String disease, String user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text("Delete Prediction"),
          ],
        ),
        content: Text(
          "Delete \"$disease\" by $user?\nThis cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await ApiService.deletePrediction(id);
              load(); // refresh list
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget card(Map h, int index) {
    // Safe id
    int id = h["id"] is int ? h["id"] : int.tryParse(h["id"].toString()) ?? 0;

    // Safe disease
    String disease = h["disease"] ?? h["disease_name"] ?? "Unknown";

    // Safe username
    String user = (h["username"] != null &&
                   h["username"].toString().trim().isNotEmpty &&
                   h["username"].toString().trim() != "unknown")
        ? h["username"].toString()
        : "Unknown User";

    // Safe confidence
    double conf = 0.0;
    if (h["confidence"] is num) {
      conf = (h["confidence"] as num).toDouble();
    }

    // Safe timestamp
    String timestamp = (h["timestamp"] != null &&
                        h["timestamp"].toString().trim().isNotEmpty)
        ? h["timestamp"].toString()
        : "";

    // Confidence color: green if high, red if low
    Color confColor = conf >= 70
        ? const Color(0xFF2E7D32)  // green
        : const Color(0xFFC62828); // red

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), // uniform light green for all cards
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // USER row
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: Text(
                    user[0].toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  user,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87, // black text
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Divider(height: 1, color: Colors.green.withOpacity(0.3)),
            const SizedBox(height: 10),

            // DISEASE row
            Row(
              children: [
                const Icon(Icons.medical_services_outlined,
                    size: 16, color: Color(0xFF388E3C)),
                const SizedBox(width: 8),
                Text(
                  disease,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87, // black text
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // CONFIDENCE row
            Row(
              children: [
                Icon(Icons.bar_chart, size: 16, color: confColor),
                const SizedBox(width: 8),
                Text(
                  "${conf.toStringAsFixed(2)}% confidence",
                  style: TextStyle(
                    fontSize: 14,
                    color: confColor, // green or red based on value
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            // TIMESTAMP row
            if (timestamp.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 14, color: Color(0xFF66BB6A)),
                  const SizedBox(width: 8),
                  Text(
                    timestamp,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],

            // DELETE icon only
            const SizedBox(height: 6),
            Divider(height: 1, color: Colors.red.withOpacity(0.2)),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                tooltip: "Delete",
                onPressed: () => _confirmDelete(context, id, disease, user),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppWidgets.appBar(context, "Predictions"),

      body: loading
          ? AppWidgets.loader()
          : data.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 60, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        "No predictions yet",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Total count banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      color: const Color(0xFFE8F5E9),
                      child: Text(
                        "Total predictions: ${data.length}",
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: data.length,
                        itemBuilder: (_, i) => card(data[i], i),
                      ),
                    ),
                  ],
                ),
    );
  }
}