import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Registro con correo/contraseña
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phone,
    String? description,
    List<String>? oficios,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _firestore.collection('users').doc(cred.user!.uid).set({
      'uid': cred.user!.uid,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone ?? '',
      'description': description ?? '',
      'oficios': oficios ?? [],
      'createdAt': FieldValue.serverTimestamp(),
    });
    return cred;
  }

  // Google Sign-In (Web y Móvil)
  Future<UserCredential?> signInWithGoogle({String role = 'user'}) async {
    try {
      if (kIsWeb) {
        // Web
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        final userCredential = await _auth.signInWithPopup(googleProvider);
        await _saveUserData(userCredential.user!, role);
        return userCredential;
      } else {
        // Android/iOS
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: [
            'email',
            'openid',
          ], // incluir 'openid' para idToken posiblemente
        );
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) return null;
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        // En la nueva API puede que accessToken sea null o no esté definido
        final OAuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          // accessToken: googleAuth.accessToken, // <— quita o pon condicionalmente si existe
        );
        final userCredential = await _auth.signInWithCredential(credential);
        await _saveUserData(userCredential.user!, role);
        return userCredential;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Nuevo: Obtiene el rol del usuario desde Firestore
  Future<String> getUserRole(String uid) async {
    try {
      final snapshot = await _firestore.collection('users').doc(uid).get();
      if (snapshot.exists) {
        return snapshot.data()?['role'] ?? 'user';
      }
      return 'user';
    } catch (e) {
      print("Error fetching user role: $e");
      return 'user'; // Rol por defecto si hay un error
    }
  }

  Future<void> _saveUserData(User user, String role) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final snapshot = await userDoc.get();
    if (!snapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photoURL': user.photoURL ?? '',
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await userDoc.set({
        'name': user.displayName ?? snapshot.data()?['name'] ?? '',
        'email': user.email ?? snapshot.data()?['email'] ?? '',
        'photoURL': user.photoURL ?? snapshot.data()?['photoURL'] ?? '',
        'role':
            snapshot.data()?['role'] ??
            role, // Conserva el rol original si existe
      }, SetOptions(merge: true));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
