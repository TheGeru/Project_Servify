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

  //LOGIN CON GOOGLE
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

  /// -----------------------------
  /// CREAR EN FIRESTORE (REGISTRO NORMAL)
  /// -----------------------------
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
        'name': name,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'isProvider': false,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// -----------------------------
  /// CREAR O ACTUALIZAR DESPUÉS DE GOOGLE
  /// -----------------------------
  Future<void> saveGoogleUser(User user) async {
    final doc = _firestore.collection('users').doc(user.uid);

    if (!(await doc.get()).exists) {
      await doc.set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'lastName': '',
        'email': user.email ?? '',
        'phone': '',
        'photoURL': user.photoURL ?? '',
        'isProvider': false,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Si ya existe, solo actualizamos datos básicos
      await doc.update({
        'name': user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'email': user.email ?? '',
      });
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
