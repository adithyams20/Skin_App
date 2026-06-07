import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../colors.dart';
import '../widgets.dart';

class AdminDiseaseScreen extends StatefulWidget {
  const AdminDiseaseScreen({super.key});

  @override
  State<AdminDiseaseScreen> createState() =>
      _AdminDiseaseScreenState();
}

class _AdminDiseaseScreenState extends State<AdminDiseaseScreen> {
  List diseases = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    var res = await ApiService.getDiseases();
    setState(() => diseases = res);
  }

  void editDisease(Map d) {
    TextEditingController desc =
        TextEditingController(text: d["description"] ?? "");
    TextEditingController rec =
        TextEditingController(text: d["recommendation"] ?? "");
    TextEditingController skin =
        TextEditingController(text: d["skincare"] ?? "");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(d["name"] ?? ""),
        content: SingleChildScrollView(
          child: Column(
            children: [
              AppWidgets.input(controller: desc, label: "Description", icon: Icons.info),
              const SizedBox(height: 10),
              AppWidgets.input(controller: rec, label: "Recommendation", icon: Icons.medical_services),
              const SizedBox(height: 10),
              AppWidgets.input(controller: skin, label: "Skincare", icon: Icons.spa),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await ApiService.updateDisease({
                "name": d["name"],
                "description": desc.text,
                "recommendation": rec.text,
                "skincare": skin.text,
              });

              Navigator.pop(context);
              load();
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  Widget card(Map d) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      decoration: BoxDecoration(
        color: const Color(0xFFF1FAF4), // same very light green as users screen
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        child: Row(
          children: [
            const Icon(Icons.medical_services_outlined,
                size: 22, color: Color(0xFF388E3C)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                d["name"] ?? "",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF388E3C)),
              onPressed: () => editDisease(d),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppWidgets.appBar(context, "Diseases"),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: diseases.length,
        itemBuilder: (_, i) => card(diseases[i]),
      ),
    );
  }
}