import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class CloudinaryService {
  final String cloudName = "fotosgeneral";
  final String uploadPreset = "fotosGeneral";
  final String apiKey = "586979948654399";
  final String apiSecret = "vdW2TrSwjJiYaZ41m_TbL4Y3J_k";

  Future<Map<String, String>?> uploadImage(File imageFile, {required String folder}) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = folder
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);

      return {
        'url': jsonMap['secure_url'],
        'public_id': jsonMap['public_id'],
      };
    } else {
      print('Error al subir a Cloudinary: ${response.statusCode}');
      return null;
    }
  }

  // --- ELIMINAR IMAGEN ---
  Future<bool> deleteImage(String publicId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    final signatureString = 'public_id=$publicId&timestamp=$timestamp$apiSecret';
    final signature = sha1.convert(utf8.encode(signatureString)).toString();

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/destroy');

    final response = await http.post(url, body: {
      'public_id': publicId,
      'timestamp': timestamp,
      'api_key': apiKey,
      'signature': signature,
    });

    if (response.statusCode == 200) {
      print('Imagen eliminada de Cloudinary exitosamente');
      return true;
    } else {
      print('Error al eliminar de Cloudinary: ${response.body}');
      return false;
    }
  }
}