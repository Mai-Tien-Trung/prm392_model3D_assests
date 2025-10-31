import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/3d_viewer.dart';
import '../data/services/glb_download_service.dart';

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
      });
    }
  }

  Future<void> _generateModel() async {
    if (_selectedImage == null) return;

    setState(() => _isGenerating = true);
    // TODO: Gọi API generate 3D từ ảnh
    await Future.delayed(const Duration(seconds: 3)); // Giả lập

    // Giả lập: Tải model mẫu từ Backblaze
    final file = await _downloader.downloadFile();
    setState(() {
      _generatedModel = file;
      _isGenerating = false;
    });
  }

  Future<void> _downloadModel() async {
    if (_generatedModel == null) return;
    // TODO: Lưu vào Downloads
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Đã lưu: ${_generatedModel!.path.split('/').last}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate 3D Model"),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 3D VIEWER
            ThreeDViewer(filePath: _generatedModel?.path, height: 350),
            const SizedBox(height: 30),

            // CHỌN ẢNH
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
                child: Image.file(_selectedImage!, height: 150, fit: BoxFit.cover),
              ),
            ],
            const SizedBox(height: 20),

            // NÚT GENERATE
            _buildActionButton(
              text: _isGenerating ? "Đang tạo..." : "Generate",
              icon: Icons.auto_awesome,
              onTap: _isGenerating ? null : _generateModel,
              color: Colors.green,
            ),
            const SizedBox(height: 20),

            // NÚT DOWNLOAD
            _buildActionButton(
              text: "Download",
              icon: Icons.download,
              onTap: _generatedModel != null ? _downloadModel : null,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),

            // NÚT HISTORY
            _buildActionButton(
              text: "History",
              icon: Icons.history,
              onTap: () {
                // TODO: Chuyển đến trang History
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("History Page (Coming Soon)")),
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey[300] : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: onTap == null ? Colors.grey : color),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: onTap == null ? Colors.grey : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}