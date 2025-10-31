import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/3d_viewer.dart';
import '../data/services/glb_download_service.dart';

class Model3DPage extends StatefulWidget {
  final String filePath;

  const Model3DPage({super.key, required this.filePath});

  @override
  State<Model3DPage> createState() => _Model3DPageState();
}

class _Model3DPageState extends State<Model3DPage> {
  final BackblazeDownloader _downloader = BackblazeDownloader();
  File? _localModel;
  bool _isLoading = true;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _loadModelFromBackblaze();
  }

  /// 🔄 Tải file GLB từ đường dẫn Backblaze về bộ nhớ tạm
  Future<void> _loadModelFromBackblaze() async {
    try {
      setState(() => _isLoading = true);
      final file = await _downloader.downloadFromUrl(widget.filePath);
      setState(() {
        _localModel = file;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải file: $e')),
      );
    }
  }

  /// 💾 Lưu file vào thư mục Documents
  Future<void> _saveModelToDocuments() async {
    if (_localModel == null || _isDownloading) return;

    try {
      setState(() => _isDownloading = true);
      final savedFile = await _downloader.saveToDocuments(_localModel!);
      if (savedFile != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã lưu vào Documents: ${savedFile.path.split('/').last}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể lưu file')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu file: $e')),
      );
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final modelName = widget.filePath.split('/').last;

    return Scaffold(
      appBar: AppBar(
        title: Text(modelName),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Tải lại mô hình",
            onPressed: _loadModelFromBackblaze,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _localModel == null
          ? const Center(child: Text("Không thể tải mô hình"))
          : Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ThreeDViewer(
                filePath: _localModel!.path,
                height: 450,
              ),
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: _isDownloading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.download),
              label: Text(
                _isDownloading ? "Đang tải..." : "Tải về thiết bị",
                style: const TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isDownloading ? null : _saveModelToDocuments,
            ),
          ),
        ],
      ),
    );
  }
}
