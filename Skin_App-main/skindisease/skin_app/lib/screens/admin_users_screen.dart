import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../colors.dart';
import '../widgets.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List users = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    var res = await ApiService.getUsers();
    setState(() => users = res);
  }

  void deleteUser(String username) async {
    await ApiService.deleteUser(username);
    load();
  }

  void promoteUser(String username) async {
    await ApiService.promoteUser(username);
    load();
  }

  void demoteUser(String username) async {
    await ApiService.demoteUser(username);
    load();
  }

  Widget userCard(Map u) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      decoration: BoxDecoration(
        color: const Color(0xFFF1FAF4), // very light green, lighter than prediction screen
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: const Icon(Icons.person, color: Color(0xFF388E3C)),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(u["username"] ?? "",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  Text("Role: ${u["role"] ?? ""}",
                      style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),

            if (u["role"] == "user")
              IconButton(
                icon: const Icon(Icons.arrow_upward, color: Colors.blue),
                onPressed: () => promoteUser(u["username"]),
              ),

            if (u["role"] == "admin" && u["username"] != "admin")
              IconButton(
                icon: const Icon(Icons.arrow_downward, color: Colors.orange),
                onPressed: () => demoteUser(u["username"]),
              ),

            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => deleteUser(u["username"]),
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
      appBar: AppWidgets.appBar(context, "Users"),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (_, i) => userCard(users[i]),
      ),
    );
  }
}