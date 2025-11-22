import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import 'package:project_servify/services/google_services.dart';

class GoogleAuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> singInWithGoogle() async {
    try {
      if (kIsWasm) {
        GoogleAuthProvider provider = GoogleAuthProvider();
        provider.addScope('email');
        return await _auth.signInWithPopup(provider);
      } else {
        final googleUser = await GoogleSignIn(
          scopes: ['email', 'openid'],
        ).signIn();

        if(googleUser == null){
          throw Exception('Inicio de sesion interrumpido');
        }

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      rethrow;
    }
  }
}
