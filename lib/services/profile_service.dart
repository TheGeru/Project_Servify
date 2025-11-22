import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_servify/models/usuarios_model.dart'; // Asegúrate de que este nombre de archivo sea correcto

class ProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Crea o actualiza el perfil del usuario en Firestore, asignándole el rol de proveedor.
  Future<void> upgradeToProvider({
    required String uid,
    required String email,
    String? displayName, // Recibimos el nombre completo de Auth
    required String phone,
    required String occupation,
    required String description,
  }) async {
    // Referencia al documento del usuario
    final userDocRef = _db.collection('users').doc(uid);

    // Lógica simple para separar Nombre y Apellido si viene todo junto en displayName
    String nombre = displayName ?? 'Usuario';
    String apellidos = '';
    
    if (displayName != null && displayName.contains(' ')) {
      final parts = displayName.split(' ');
      nombre = parts.first;
      apellidos = parts.skip(1).join(' ');
    }

    // 1. Crear el objeto UsuarioModel con los datos nuevos
    // Nota: 'oficios' es una lista en tu modelo, así que envolvemos la ocupación.
    final usuario = UsuarioModel(
      uid: uid,
      nombre: nombre,
      apellidos: apellidos,
      email: email,
      telefono: phone,
      tipo: 'provider', // <--- CAMBIO CLAVE: Establecemos el tipo a 'provider'
      descripcion: description,
      oficios: [occupation], // Guardamos el oficio seleccionado en la lista
      fotoUrl: null, // Se puede actualizar después
    );

    // 2. Guardar en Firestore (Merge true para no borrar datos si ya existían)
    await userDocRef.set(
      usuario.toMap(), 
      SetOptions(merge: true),
    );
  }
  
  /// Obtiene los datos de un usuario específico
  Future<UsuarioModel?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UsuarioModel.fromMap(doc.data()!);
    }
    return null;
  }
}