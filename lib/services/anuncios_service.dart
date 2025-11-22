import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_servify/models/anuncios_model.dart';

class AnunciosService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Crear un nuevo anuncio
  Future<String> createAnuncio({
    required String titulo,
    required String descripcion,
    required double precio,
    List<String> imagenes = const [],
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    // Verificar que el usuario sea proveedor
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists || userDoc.data()?['tipo'] != 'provider') {
      throw Exception('Solo los proveedores pueden crear anuncios');
    }

    // Crear el documento del anuncio
    final docRef = _firestore.collection('anuncios').doc();
    
    final anuncio = AnuncioModel(
      id: docRef.id,
      titulo: titulo,
      descripcion: descripcion,
      precio: precio,
      proveedorId: user.uid,
      imagenes: imagenes,
    );

    await docRef.set(anuncio.toMap());
    
    return docRef.id;
  }

  /// Obtener todos los anuncios (para el feed principal)
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
}
