import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_servify/models/usuarios_model.dart';
import 'package:project_servify/services/anuncios_service.dart';
import 'package:project_servify/services/cloudinary_service.dart';
import 'dart:io';

class ProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  Future<void> upgradeToProvider({
    required String uid,
    required String email,
    String? displayName,
    required String phone,
    required String occupation,
    required String description,
  }) async {
    final userDocRef = _db.collection('users').doc(uid);

    String nombre = displayName ?? 'Usuario';
    String apellidos = '';

    if (displayName != null && displayName.contains(' ')) {
      final parts = displayName.split(' ');
      nombre = parts.first;
      apellidos = parts.skip(1).join(' ');
    }

    final usuario = UsuarioModel(
      uid: uid,
      nombre: nombre,
      apellidos: apellidos,
      email: email,
      telefono: phone,
      tipo: 'provider',
      descripcion: description,
      oficios: [occupation],
      fotoUrl: null,
    );

    await userDocRef.set(usuario.toMap(), SetOptions(merge: true));
  }

  Future<void> updateUserProfile({
    required String uid,
    required String nombre,
    required String apellidos,
    required String telefono,
  }) async {
    await _db.collection('users').doc(uid).update({
      'nombre': nombre,
      'apellidos': apellidos,
      'telefono': telefono,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<UsuarioModel?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UsuarioModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateProfilePhoto(String uid, File newImageFile) async {
    try {
      UsuarioModel? currentUser = await getUserData(uid);

      if (currentUser != null && currentUser.fotoPublicId != null) {
        await _cloudinaryService.deleteImage(currentUser.fotoPublicId!);
      }

      final uploadResult = await _cloudinaryService.uploadImage(
        newImageFile, 
        folder: 'user_profile' // Enviamos a la carpeta de usuarios
      );

      if (uploadResult != null) {
        await _db.collection('users').doc(uid).update({
          'fotoUrl': uploadResult['url'],
          'fotoPublicId': uploadResult['public_id'],
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        throw Exception("Error al subir la imagen");
      }
    } catch (e) {
      print("Error en updateProfilePhoto: $e");
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("No hay usuario logueado");

    final lastSignIn = user.metadata.lastSignInTime;
    if (lastSignIn != null) {
      final timeSinceLogin = DateTime.now().difference(lastSignIn);
      if (timeSinceLogin.inMinutes > 64) {
        throw FirebaseAuthException(
          code: 'requires-recent-login',
          message: 'Tu sesión es antigua. Por seguridad, cierra sesión y entra de nuevo.',
        );
      }
    }

    final uid = user.uid;
    try {
      final userDoc = await _db.collection('users').doc(uid).get();
      
      if (userDoc.exists) {
        final data = userDoc.data();

        if (data != null && data['fotoPublicId'] != null) {
          await _cloudinaryService.deleteImage(data['fotoPublicId']);
        }
        if (data != null && data['tipo'] == 'provider') {
          final anunciosService = AnunciosService();
          await anunciosService.deleteAllAnunciosFromProvider(uid);
        }
      }
      await _db.collection('users').doc(uid).delete();
      await user.delete();
      
    } catch (e) {
      print("Error crítico eliminando cuenta: $e");
      rethrow;
    }
  }
}
