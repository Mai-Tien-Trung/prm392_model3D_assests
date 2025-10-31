import 'dart:convert';
import 'package:day12_login/data/models/current_subscription.dart';
import 'package:day12_login/data/models/subscription_history.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MembershipService {
  final String baseUrl = "https://prm392-api.onrender.com/api/MembershipPackage";

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
      // API trả null nếu chưa có gói nào
      if (jsonData == null || jsonData.isEmpty) return null;
      return CurrentSubscription.fromJson(jsonData);
    } else {
      throw Exception("Failed to load current subscription");
    }
  }
}
