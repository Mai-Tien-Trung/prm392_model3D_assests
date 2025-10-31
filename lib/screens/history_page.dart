import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'model_3d_page.dart'; // Trang hiển thị mô hình 3D

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _isLoading = true;
  List<dynamic> _models = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Token không tồn tại. Vui lòng đăng nhập lại.');
      }

      final response = await http.get(
        Uri.parse('https://prm392-api.onrender.com/api/Model3D'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // Nếu API trả về {"$id": "...", "$values": [...]}
        List<dynamic> values;
        if (decoded is Map && decoded.containsKey(r'$values')) {
          values = decoded[r'$values'];
        } else if (decoded is List) {
          values = decoded;
        } else {
          throw Exception('Dữ liệu trả về không hợp lệ');
        }

        setState(() {
          _models = values;
          _isLoading = false;
        });
      } else {
        throw Exception('Lỗi ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Colors.indigo,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Lỗi: $_error'))
          : _models.isEmpty
          ? const Center(child: Text('Không có lịch sử tạo mô hình'))
          : RefreshIndicator(
        onRefresh: _fetchHistory,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _models.length,
          itemBuilder: (context, index) {
            final model = _models[index];
            final String date = model['creationDate'] ?? '';
            final String status = model['status'] ?? '';
            final String filePath = model['filePath'] ?? '';
            final int id = model['modelId'] ?? 0;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.threed_rotation, color: Colors.indigo),
                title: Text(
                  'Model #$id',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Ngày tạo: ${DateTime.tryParse(date)?.toLocal() ?? date}\nTrạng thái: $status',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Model3DPage(filePath: filePath),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
