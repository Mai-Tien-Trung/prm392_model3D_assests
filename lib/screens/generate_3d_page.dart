// generate_3d_page.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/3d_viewer.dart';
import '../data/services/glb_download_service.dart';
import 'history_page.dart';

class Generate3DPage extends StatefulWidget {
  const Generate3DPage({super.key});

  @override
  State<Generate3DPage> createState() => _Generate3DPageState();
}

class _Generate3DPageState extends State<Generate3DPage> {
  File? _selectedImage;
  File? _generatedModel;
  bool _isGenerating = false;
  final BackblazeDownloader _downloader = BackblazeDownloader();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _generatedModel = null; // Reset model khi đổi ảnh
      });
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _generateModel() async {
    if (_selectedImage == null || _isGenerating) return;

    setState(() => _isGenerating = true);

    try {
      // 1. Đọc ảnh → Base64
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      // 2. Lấy token
      final token = await _getToken();
      if (token == null) {
        throw Exception('Vui lòng đăng nhập lại');
      }

      // 3. Gửi POST request
      final response = await http.post(
        Uri.parse('https://prm392-api.onrender.com/api/Model3D'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"image": base64Image}),
      );

      print('API Response: ${response.statusCode} - ${response.body}');

      // 4. Xử lý response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Tạo mô hình thất bại');
        }

        final String filePath = data['model']['filePath'];
        if (filePath.isEmpty) {
          throw Exception('Không tìm thấy đường dẫn file');
        }

        // 5. Tải file GLB về thư mục tạm
        final modelFile = await _downloader.downloadFromUrl(filePath);

        setState(() {
          _generatedModel = modelFile;
        });

        final remaining = data['remainingGenerations'] ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Thành công! Còn $remaining lượt tạo"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      print('Generate error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _downloadModel() async {
    if (_generatedModel == null) return;

    try {
      final savedFile = await _downloader.saveToDocuments(_generatedModel!);
      if (savedFile != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Đã lưu vào Documents: ${savedFile.path.split('/').last}"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không thể lưu file")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi lưu file: $e"), backgroundColor: Colors.red),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final bool canGenerate = _selectedImage != null && !_isGenerating;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate 3D Model"),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ThreeDViewer(filePath: _generatedModel?.path, height: 350),
            const SizedBox(height: 30),

            _buildActionButton(
              text: _selectedImage == null ? "Chọn ảnh" : "Đổi ảnh",
              icon: Icons.image,
              onTap: _pickImage,
              color: Colors.blue,
            ),

            if (_selectedImage != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedImage!,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 20),

            _buildActionButton(
              text: _isGenerating ? "Đang tạo..." : "Generate",
              icon: Icons.auto_awesome,
              onTap: canGenerate ? _generateModel : null,
              color: Colors.green,
              highlight: canGenerate,
            ),
            const SizedBox(height: 20),

            _buildActionButton(
              text: "Download",
              icon: Icons.download,
              onTap: _generatedModel != null ? _downloadModel : null,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),

            _buildActionButton(
              text: "History",
              icon: Icons.history,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryPage()),
                );
              },
              color: Colors.purple,
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required VoidCallback? onTap,
    required Color color,
    bool highlight = false,
  }) {
    final bool isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 60,
        decoration: BoxDecoration(
          color: isDisabled
              ? Colors.grey[300]
              : highlight
              ? color.withOpacity(0.2)
              : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDisabled ? Colors.grey : color,
            width: highlight ? 2.5 : 1.5,
          ),
          boxShadow: highlight
              ? [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isDisabled ? Colors.grey : color,
              size: highlight ? 28 : 24,
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: highlight ? FontWeight.w900 : FontWeight.bold,
                color: isDisabled ? Colors.grey : color,
              ),
            ),
            if (_isGenerating && text == "Generate")
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child:
                  CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
