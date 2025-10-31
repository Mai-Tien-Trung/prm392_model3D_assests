import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class BackblazeDownloader {
  late final String keyId;
  late final String applicationKey;
  late final String bucketName;
  late final String filePathInBucket;

  String? _authToken;
  String? _apiUrl;
  String? _downloadUrl;

  // Constructor để lấy biến môi trường từ .env
  BackblazeDownloader() {
    keyId = dotenv.env['B2_KEY_ID'] ?? 'default_key_id';
    applicationKey = dotenv.env['B2_APPLICATION_KEY'] ?? 'default_app_key';
    bucketName = dotenv.env['B2_BUCKET_NAME'] ?? 'default_bucket';
    // Chỉ lấy đường dẫn tương đối từ URL
    final rawFilePath = dotenv.env['B2_FILE_PATH'] ?? 'default_path';
    filePathInBucket = _extractFilePath(rawFilePath);

    // Debug: In biến môi trường để kiểm tra
    print('B2_KEY_ID: $keyId');
    print('B2_APPLICATION_KEY: $applicationKey');
    print('B2_BUCKET_NAME: $bucketName');
    print('B2_FILE_PATH: $filePathInBucket');

    // Kiểm tra xem biến môi trường có được thiết lập không
    if (keyId == 'default_key_id' || applicationKey == 'default_app_key') {
      throw Exception('Missing Backblaze environment variables. Please check .env file.');
    }
  }

  // Hàm trích xuất đường dẫn tương đối từ URL
  String _extractFilePath(String rawPath) {
    if (rawPath.startsWith('https://')) {
      // Lấy phần sau /file/<bucket>/
      final regex = RegExp(r'https://[^/]+/file/[^/]+/(.*)');
      final match = regex.firstMatch(rawPath);
      return match?.group(1) ?? rawPath;
    }
    return rawPath;
  }

  // Bước 1: Xác thực với Backblaze
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
      print('Auth thành công!');
    } else {
      print('Auth failed: ${response.statusCode} - ${response.body}');
      throw Exception('Auth failed: ${response.body}');
    }
  }

  // Bước 2: Lấy URL tải file (dùng b2_download_file_by_name với GET)
  Future<String> getDownloadUrl() async {
    if (_authToken == null || _downloadUrl == null) {
      await authorize();
    }

    // Sử dụng GET với query parameters
    final url = Uri.parse('$_downloadUrl/file/$bucketName/$filePathInBucket')
        .replace(queryParameters: {'Authorization': _authToken});

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return url.toString();
    } else {
      print('Get download URL failed: ${response.statusCode} - ${response.body}');
      throw Exception('Không lấy được URL tải: ${response.body}');
    }
  }

  // Bước 3: Tải file về thiết bị Android
  Future<File?> downloadFile() async {
    try {
      final downloadUrl = await getDownloadUrl();
      final response = await http.get(
        Uri.parse(downloadUrl),
        headers: {'Authorization': _authToken!},
      );

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = filePathInBucket.split('/').last;
        final file = File('${directory.path}/$fileName');

        await file.writeAsBytes(response.bodyBytes);
        print('Tải thành công: ${file.path}');
        return file;
      } else {
        print('Lỗi tải file: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Lỗi: $e');
      return null;
    }
  }
}