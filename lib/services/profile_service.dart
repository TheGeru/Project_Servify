import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_servify/models/usuarios_model.dart';

class ProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// aqui se creara o actualizara el perfil del usuario en Firestore, asignándole el rol de proveedor.
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
}
