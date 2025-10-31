import 'dart:convert';
import 'package:day12_login/data/models/current_subscription.dart';
import 'package:day12_login/data/models/membership_package.dart';
import 'package:day12_login/data/models/subscription_history.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class MembershipService {
  final String baseUrl = "https://prm392-api.onrender.com/api/MembershipPackage";

  /// 🔹 Lấy toàn bộ danh sách gói từ server
  Future<List<MembershipPackage>> getAllPackages() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List values = decoded['\$values'];
      return values.map((e) => MembershipPackage.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch packages");
    }
  }

  /// 🔹 Lấy gói hiện tại của user
  Future<CurrentSubscription?> getCurrentSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/my-subscription'),
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData == null || jsonData.isEmpty) return null;
      return CurrentSubscription.fromJson(jsonData);
    } else {
      throw Exception("Failed to load current subscription");
    }
  }

  /// 🔹 Lấy lịch sử các gói user từng đăng ký
  Future<List<SubscriptionHistory>> getMySubscriptionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/my-subscription/history'),
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List values = decoded["\$values"];
      return values.map((e) => SubscriptionHistory.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load subscription history");
    }
  }

  /// 🔹 Đăng ký / mua gói (Free hoặc Paid qua VNPAY)
  Future<Map<String, dynamic>> purchasePackage(int packageId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$baseUrl/purchase'),
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'packageId': packageId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to purchase package: ${response.statusCode}');
    }
  }
}
