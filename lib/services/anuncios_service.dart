import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_servify/models/anuncios_model.dart';
import 'dart:io';
import 'package:project_servify/services/cloudinary_service.dart';

class AnunciosService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  Future<String> createAnuncio({
    required String titulo,
    required String descripcion,
    required double precio,
    File? imagenFile,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    List<Map<String, dynamic>> listaImagenes = [];
    
    if (imagenFile != null) {
      final uploadResult = await _cloudinaryService.uploadImage(
        imagenFile, 
        folder: 'services_images'
      );
      
      if (uploadResult != null) {
        listaImagenes.add({
          'url': uploadResult['url'],
          'public_id': uploadResult['public_id'],
        });
      }
    }

    final docRef = _firestore.collection('anuncios').doc();
    
    final anuncio = AnuncioModel(
      id: docRef.id,
      titulo: titulo,
      descripcion: descripcion,
      precio: precio,
      proveedorId: user.uid,
      imagenes: listaImagenes,
    );

    await docRef.set(anuncio.toMap());
    
    return docRef.id;
  }

  Stream<List<AnuncioModel>> getAllAnuncios() {
    return _firestore
        .collection('anuncios')
        .orderBy('titulo')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Asegurar que tenga el ID
        return AnuncioModel.fromMap(data);
      }).toList();
    });
  }

  /// Obtener anuncios de un proveedor específico
  Stream<List<AnuncioModel>> getAnunciosByProveedor(String proveedorId) {
    return _firestore
        .collection('anuncios')
        .where('proveedorId', isEqualTo: proveedorId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AnuncioModel.fromMap(data);
      }).toList();
    });
  }

  /// Obtener anuncios del usuario actual (si es proveedor)
  Stream<List<AnuncioModel>> getMyAnuncios() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    return getAnunciosByProveedor(user.uid);
  }

  /// Actualizar un anuncio
  Future<void> updateAnuncio(AnuncioModel anuncio) async {
    final user = _auth.currentUser;
    if (user == null || user.uid != anuncio.proveedorId) {
      throw Exception('No tienes permiso para editar este anuncio');
    }

    await _firestore
        .collection('anuncios')
        .doc(anuncio.id)
        .update(anuncio.toMap());
  }

  /// Eliminar un anuncio
  Future<void> deleteAnuncio(String anuncioId, String proveedorId) async {
    final user = _auth.currentUser;
    if (user == null || user.uid != proveedorId) {
      throw Exception('No tienes permiso para eliminar este anuncio');
    }

    await _firestore.collection('anuncios').doc(anuncioId).delete();
  }

  /// Obtener datos del proveedor para un anuncio
  Future<Map<String, dynamic>?> getProveedorData(String proveedorId) async {
    final doc = await _firestore.collection('users').doc(proveedorId).get();
    return doc.data();
  }

   /// Eliminar TODOS los anuncios de un proveedor (Para borrar cuenta)
  Future<void> deleteAllAnunciosFromProvider(String providerId) async {
    final snapshot = await _firestore
        .collection('anuncios')
        .where('proveedorId', isEqualTo: providerId)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();

      if (data['imagenes'] != null) {
        List imgs = data['imagenes'];
        for (var img in imgs) {
           if (img is Map && img['public_id'] != null) {
             await _cloudinaryService.deleteImage(img['public_id']);
           }
        }
      }

      // 3. Borrar el documento del anuncio
      await doc.reference.delete();
    }
  }

}
