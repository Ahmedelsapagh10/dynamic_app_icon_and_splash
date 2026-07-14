import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class ImageKitUploadService {
  static const String urlEndpoint =
      'https://ik.imagekit.io/XXXX'; //! set your link
  static const String _uploadUrl =
      'https://upload.imagekit.io/api/v1/files/upload';
  static const String _folder = '/shopia/splash';

  // For this demo only. Move this to a secure backend or callable function.
  static const String _privateKey = 'private_XXXXX/XXXXX='; //! set your key

  Future<String> uploadSplashImage(XFile file) async {
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw const FormatException('Selected image is empty.');
    }

    final extension = _extractExtension(file.name);
    if (!_isAllowedExtension(extension)) {
      throw const FormatException('Use png, jpg, jpeg, or webp images only.');
    }

    final fileName =
        'splash_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final auth = base64Encode(utf8.encode('$_privateKey:'));

    final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl))
      ..headers['Authorization'] = 'Basic $auth'
      ..fields['fileName'] = fileName
      ..fields['folder'] = _folder
      ..fields['useUniqueFileName'] = 'true'
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
          contentType: MediaType(
            'image',
            extension == 'jpg' ? 'jpeg' : extension,
          ),
        ),
      );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'ImageKit upload failed: ${response.statusCode} $responseBody',
      );
    }

    final decoded = jsonDecode(responseBody);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Unexpected upload response.');
    }

    final url = decoded['url']?.toString().trim() ?? '';
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.isAbsolute) {
      throw const FormatException('ImageKit returned an invalid URL.');
    }

    return url;
  }

  bool _isAllowedExtension(String extension) {
    return <String>{'png', 'jpg', 'jpeg', 'webp'}.contains(extension);
  }

  String _extractExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return '';
    }
    return fileName.substring(dotIndex + 1).toLowerCase().trim();
  }
}
