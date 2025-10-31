import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler/permission_handler.dart';

class BackblazeDownloader {
  late final String keyId;
  late final String applicationKey;
  late final String bucketName;

  String? _authToken;
  String? _apiUrl;
  String? _downloadUrl;

  BackblazeDownloader() {
    keyId = dotenv.env['B2_KEY_ID'] ?? '';
    applicationKey = dotenv.env['B2_APPLICATION_KEY'] ?? '';
    bucketName = dotenv.env['B2_BUCKET_NAME'] ?? '';

    if (keyId.isEmpty || applicationKey.isEmpty || bucketName.isEmpty) {
      throw Exception('Missing Backblaze environment variables in .env');
    }
  }

  /// 🔐 Authorize Backblaze API
  Future<void> authorize() async {
    final authString = base64Encode(utf8.encode('$keyId:$applicationKey'));
    final response = await http.get(
      Uri.parse('https://api.backblazeb2.com/b2api/v2/b2_authorize_account'),
      headers: {'Authorization': 'Basic $authString'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _authToken = data['authorizationToken'];
      _apiUrl = data['apiUrl'];
      _downloadUrl = data['downloadUrl'];
    } else {
      throw Exception('Backblaze auth failed: ${response.body}');
    }
  }

  /// 📥 Tải file từ URL của Backblaze và lưu tạm
  Future<File> downloadFromUrl(String fileUrl) async {
    if (_authToken == null) await authorize();

    final response = await http.get(
      Uri.parse(fileUrl),
      headers: {'Authorization': _authToken!},
    );

    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final fileName = fileUrl.split('/').last.split('?').first;
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);
      print('Tải tạm thành công: ${file.path}');
      return file;
    } else {
      throw Exception('Tải file thất bại: ${response.statusCode}');
    }
  }

  Future<File?> saveToDocuments(File sourceFile) async {
    try {
      // 1️⃣ Xin quyền truy cập bộ nhớ (Android 11+ cần quyền manageExternalStorage)
      if (Platform.isAndroid) {
        if (await Permission.manageExternalStorage.isDenied) {
          final status = await Permission.manageExternalStorage.request();
          if (!status.isGranted) {
            print('❌ Không có quyền truy cập bộ nhớ');
            return null;
          }
        }
      }

      // 2️⃣ Đường dẫn tuyệt đối đến thư mục Documents công khai
      const publicDocumentsPath = '/storage/emulated/0/Documents';

      final documentsDir = Directory(publicDocumentsPath);
      if (!await documentsDir.exists()) {
        await documentsDir.create(recursive: true);
      }

      // 3️⃣ Sao chép file
      final fileName = sourceFile.path.split('/').last;
      final savedFile = File('${documentsDir.path}/$fileName');
      await sourceFile.copy(savedFile.path);

      print('✅ File đã lưu vào Documents công khai: ${savedFile.path}');
      return savedFile;
    } catch (e) {
      print('❌ Lỗi khi lưu file: $e');
      return null;
    }
  }



  /// 🔒 Đảm bảo có quyền truy cập bộ nhớ, tự xin nếu chưa có
  Future<bool> _ensureStoragePermission() async {
    try {
      var status = await Permission.storage.status;

      if (Platform.isAndroid && await _isAndroid13OrAbove()) {
        // Android 13+ dùng quyền ảnh/video thay cho storage
        if (!await Permission.photos.isGranted) {
          await Permission.photos.request();
        }
      }

      if (!status.isGranted) {
        status = await Permission.storage.request();
      }

      if (status.isPermanentlyDenied) {
        print('Quyền lưu trữ bị từ chối vĩnh viễn');
        await openAppSettings();
        return false;
      }

      return status.isGranted;
    } catch (e) {
      print('Lỗi xin quyền lưu trữ: $e');
      return false;
    }
  }

  /// ⚙️ Helper: kiểm tra Android 13+
  Future<bool> _isAndroid13OrAbove() async {
    if (!Platform.isAndroid) return false;
    final version = await _getAndroidSdkInt();
    return version >= 33;
  }

  Future<int> _getAndroidSdkInt() async {
    try {
      final result = await Process.run('getprop', ['ro.build.version.sdk']);
      return int.tryParse(result.stdout.toString().trim()) ?? 0;
    } catch (_) {
      return 0;
    }
  }
}
