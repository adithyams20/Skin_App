import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {

  static const baseUrl = "https://skinapp.onrender.com";
  static const _timeout = Duration(seconds: 60);

  // ── Check if response is valid JSON ──
  static bool _isJson(http.Response res) {
    final ct = res.headers['content-type'] ?? '';
    return ct.contains('application/json');
  }

  // ── Wake the server up if sleeping, retry once ──
  static Future<http.Response?> _getWithRetry(String url) async {
    try {
      var res = await http.get(Uri.parse(url)).timeout(_timeout);
      if (!_isJson(res)) {
        print("Server waking up, retrying in 10s...");
        await Future.delayed(const Duration(seconds: 10));
        res = await http.get(Uri.parse(url)).timeout(_timeout);
      }
      return res;
    } catch (e) {
      print("GET ERROR [$url]: $e");
      return null;
    }
  }

  // 🔐 LOGIN
  static Future login(String username, String password) async {
    try {
      var res = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      ).timeout(_timeout);
      if (!_isJson(res)) return {"error": "Server is waking up. Please try again in a moment."};
      return jsonDecode(res.body);
    } catch (e) {
      print("LOGIN ERROR: $e");
      return {"error": "Server unreachable. Please wait and try again."};
    }
  }

  // 📝 REGISTER
  static Future register(String username, String password) async {
    try {
      var res = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      ).timeout(_timeout);
      if (!_isJson(res)) return {"error": "Server is waking up. Please try again in a moment."};
      return jsonDecode(res.body);
    } catch (e) {
      print("REGISTER ERROR: $e");
      return {"error": "Server unreachable. Please wait and try again."};
    }
  }

  // 🔑 CHANGE PASSWORD
  static Future changePassword(String username, String password) async {
    try {
      var res = await http.put(
        Uri.parse("$baseUrl/change_password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      ).timeout(_timeout);
      if (!_isJson(res)) return {"error": "Server is waking up. Please try again in a moment."};
      return jsonDecode(res.body);
    } catch (e) {
      print("CHANGE PASSWORD ERROR: $e");
      return {"error": "Password update failed."};
    }
  }

  // 🤖 PREDICT
  static Future predictImage(File image, String username) async {
    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/predict"),
      );
      request.fields["username"] = username;
      request.files.add(
        await http.MultipartFile.fromPath("image", image.path),
      );
      var response = await request.send().timeout(_timeout);
      var res = await http.Response.fromStream(response);
      if (!_isJson(res)) return {"error": "Server is waking up. Please try again in a moment."};
      return jsonDecode(res.body);
    } catch (e) {
      print("PREDICT ERROR: $e");
      return {"error": "Prediction failed. Please try again."};
    }
  }

  // 📜 USER HISTORY
  static Future<List> getHistory(String username) async {
    final res = await _getWithRetry("$baseUrl/history?username=$username");
    if (res == null || !_isJson(res)) return [];
    try {
      return jsonDecode(res.body);
    } catch (e) {
      print("HISTORY ERROR: $e");
      return [];
    }
  }

  // 🗑️ DELETE USER HISTORY RECORD
  static Future deleteHistory(int id) async {
    try {
      var res = await http.delete(
        Uri.parse("$baseUrl/history/delete?id=$id"),
      ).timeout(_timeout);
      if (!_isJson(res)) return {"error": "Server is waking up. Please try again."};
      return jsonDecode(res.body);
    } catch (e) {
      print("DELETE HISTORY ERROR: $e");
      return {"error": "Delete failed."};
    }
  }

  // ─── ADMIN ────────────────────────────────────────────────────────────────

  // 👥 GET ALL USERS
  static Future<List> getUsers() async {
    final res = await _getWithRetry("$baseUrl/admin/users");
    if (res == null || !_isJson(res)) return [];
    try {
      return jsonDecode(res.body);
    } catch (e) {
      print("GET USERS ERROR: $e");
      return [];
    }
  }

  // 🗑️ DELETE USER
  static Future deleteUser(String username) async {
    try {
      var res = await http.delete(
        Uri.parse("$baseUrl/admin/delete_user?username=$username"),
      ).timeout(_timeout);
      if (!_isJson(res)) return {"error": "Server is waking up. Please try again."};
      return jsonDecode(res.body);
    } catch (e) {
      print("DELETE USER ERROR: $e");
      return {"error": "Delete failed."};
    }
  }

  // ⬆️ PROMOTE USER
  static Future promoteUser(String username) async {
    try {
      var res = await http.put(
        Uri.parse("$baseUrl/admin/promote_user"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username}),
      ).timeout(_timeout);
      if (!_isJson(res)) return {"error": "Server is waking up. Please try again."};
      return jsonDecode(res.body);
    } catch (e) {
      print("PROMOTE USER ERROR: $e");
      return {"error": "Promote failed."};
    }
  }

  // ⬇️ DEMOTE USER
  static Future demoteUser(String username) async {
    try {
      var res = await http.put(
        Uri.parse("$baseUrl/admin/demote_user"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username}),
      ).timeout(_timeout);
      if (!_isJson(res)) return {"error": "Server is waking up. Please try again."};
      return jsonDecode(res.body);
    } catch (e) {
      print("DEMOTE USER ERROR: $e");
      return {"error": "Demote failed."};
    }
  }

  // 📊 ADMIN HISTORY
  static Future<List> getAdminHistory() async {
    final res = await _getWithRetry("$baseUrl/admin/history");
    if (res == null || !_isJson(res)) return [];
    try {
      return jsonDecode(res.body);
    } catch (e) {
      print("ADMIN HISTORY ERROR: $e");
      return [];
    }
  }

  // 🗑️ DELETE PREDICTION (Admin)
  static Future deletePrediction(int id) async {
    try {
      var res = await http.delete(
        Uri.parse("$baseUrl/admin/delete_prediction?id=$id"),
      ).timeout(_timeout);
      if (!_isJson(res)) return {"error": "Server is waking up. Please try again."};
      return jsonDecode(res.body);
    } catch (e) {
      print("DELETE PREDICTION ERROR: $e");
      return {"error": "Delete failed."};
    }
  }

  // 🦠 GET DISEASES
  static Future<List> getDiseases() async {
    final res = await _getWithRetry("$baseUrl/admin/diseases");
    if (res == null || !_isJson(res)) return [];
    try {
      return jsonDecode(res.body);
    } catch (e) {
      print("GET DISEASES ERROR: $e");
      return [];
    }
  }

  // ✏️ UPDATE DISEASE
  static Future updateDisease(Map data) async {
    try {
      var res = await http.put(
        Uri.parse("$baseUrl/admin/update_disease"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      ).timeout(_timeout);
      if (!_isJson(res)) return {"error": "Server is waking up. Please try again."};
      return jsonDecode(res.body);
    } catch (e) {
      print("UPDATE DISEASE ERROR: $e");
      return {"error": "Update failed."};
    }
  }
}