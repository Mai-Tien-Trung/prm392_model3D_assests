import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../core/constants/api_constants.dart';

class UserService {
  Future<UserModel?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.profile),
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print(" Status: ${response.statusCode}");
      print(" Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserModel.fromJson(data);
      } else {
        print(" Failed to load profile");
        return null;
      }
    } catch (e) {
      print(" Exception: $e");
      return null;
    }
  }
}
