import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:image_picker/image_picker.dart'; // Para XFile

class CloudinaryService {
  final String cloudName = "fotosgeneral";
  final String uploadPreset = "fotosGeneral";
  final String apiKey = "586979948654399";
  final String apiSecret = "vdW2TrSwjJiYaZ41m_TbL4Y3J_k";

  // IMPORTANTE: Recibe XFile? (compatible con Web y Mobile)
  Future<Map<String, String>?> uploadImage(XFile? imageFile, {required String folder}) async {
    if (imageFile == null) {
      print('Aviso: Intento de subir imagen nula');
      return null;
    }

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    
    // 1. Crear la solicitud MultipartRequest
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = folder;
      
    // 2. Adjuntar el archivo según la plataforma
    try {
      if (kIsWeb) {
        // EN WEB: Leemos los bytes directamente del XFile (para evitar dart:io)
        final bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'file', // <-- Nombre de campo requerido por Cloudinary
            bytes,
            filename: imageFile.name,
          ),
        );
      } else {
        // EN MÓVIL: Usamos la ruta del XFile (compatible con fromPath)
        request.files.add(
          await http.MultipartFile.fromPath(
            'file', // <-- Nombre de campo requerido por Cloudinary
            imageFile.path,
            filename: imageFile.name,
          ),
        );
      }

    } catch (e) {
      // Capturamos cualquier error durante la lectura del archivo (permisos, archivo temporal)
      print('Error al leer el archivo para subir: $e');
      return null; // Detenemos el proceso si el archivo no se puede leer
    }

    // 3. Enviar la solicitud
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);

        return {
          'url': jsonMap['secure_url'],
          'public_id': jsonMap['public_id'],
        };
      } else {
        print('Error al subir a Cloudinary: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al enviar la solicitud HTTP: $e');
      return null;
    }
  }

  // --- ELIMINAR IMAGEN (sin cambios) ---
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