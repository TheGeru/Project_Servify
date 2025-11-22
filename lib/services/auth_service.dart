import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_servify/services/google_services.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GoogleAuthServices _googleService = GoogleAuthServices();

  /// REGISTRO TRADICIONAL
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String lastName,
    required String phone,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // CORRECCIÓN: Actualizar displayName en Firebase Auth
    await cred.user?.updateDisplayName('$name $lastName');
    
    // Crear documento en Firestore
    await _createUserInFirestore(
      uid: cred.user!.uid,
      name: name,
      lastName: lastName,
      email: email,
      phone: phone,
    );

    return cred;
  }

  /// LOGIN TRADICIONAL
  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// LOGIN CON GOOGLE
  Future<User?> signInWithGoogle() async {
    try {
      final credential = await _googleService.singInWithGoogle();
      final user = credential.user;

      if (user == null) return null;
      await saveGoogleUser(user);
      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// CREAR EN FIRESTORE (REGISTRO NORMAL)
  Future<void> _createUserInFirestore({
    required String uid,
    required String name,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    final doc = _firestore.collection('users').doc(uid);

    if (!(await doc.get()).exists) {
      await doc.set({
        'uid': uid,
        'nombre': name,           // CORRECCIÓN: Usar 'nombre' como en el modelo
        'apellidos': lastName,    // CORRECCIÓN: Usar 'apellidos'
        'email': email,
        'telefono': phone,        // CORRECCIÓN: Usar 'telefono'
        'tipo': 'user',           // CORRECCIÓN: Usar 'tipo'
        'descripcion': null,
        'fotoUrl': null,
        'oficios': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// CREAR O ACTUALIZAR DESPUÉS DE GOOGLE
  Future<void> saveGoogleUser(User user) async {
    final doc = _firestore.collection('users').doc(user.uid);

    // Separar nombre y apellidos del displayName
    String nombre = '';
    String apellidos = '';
    
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      final parts = user.displayName!.split(' ');
      nombre = parts.first;
      if (parts.length > 1) {
        apellidos = parts.skip(1).join(' ');
      }
    }

    if (!(await doc.get()).exists) {
      // Crear nuevo usuario de Google
      await doc.set({
        'uid': user.uid,
        'nombre': nombre,
        'apellidos': apellidos,
        'email': user.email ?? '',
        'telefono': '',
        'tipo': 'user',
        'descripcion': null,
        'fotoUrl': user.photoURL ?? '',
        'oficios': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Actualizar datos básicos si ya existe
      await doc.update({
        'nombre': nombre,
        'apellidos': apellidos,
        'fotoUrl': user.photoURL ?? '',
        'email': user.email ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
