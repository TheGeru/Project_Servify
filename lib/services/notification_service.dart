import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth; // Necesario para V1
import 'package:flutter/services.dart' show rootBundle;

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _messaging.getToken();
      if (kDebugMode) {
        print('FCM Token: $token');
      }
    }
  }

  /// Crea una notificación en la colección 'notifications' de Firestore (Notificación In-App)
  Future<void> sendNotification({
    required String toUserId,
    required String fromUserId,
    required String fromUserName,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? metadata,
  }) async {
    await _db.collection('notifications').add({
      'toUserId': toUserId,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'title': title,
      'body': body,
      'type': type,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
      'metadata': metadata,
    });
  }

  /// Obtiene las notificaciones In-App
  Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('toUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ==========================================
  //        ENVÍO DE PUSH (API V1)
  // ==========================================
  Future<void> sendPushNotification({
    required String token,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      // 1. CREDENCIALES DE CUENTA DE SERVICIO
      // Abre el archivo .json que descargaste de Firebase Console y
      // copia el contenido de cada campo aquí.
      final jsonString = await rootBundle.loadString('secrets/service_account.json');
      final serviceAccountJson = jsonDecode(jsonString);

      // 2. Obtener Token de Acceso (Bearer Token)
      // Esto autentica tu app como si fuera el servidor de Firebase
      final accountCredentials = auth.ServiceAccountCredentials.fromJson(serviceAccountJson);
      
      // Definimos los permisos necesarios (scope)
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      
      // Creamos un cliente autenticado
      final client = await auth.clientViaServiceAccount(accountCredentials, scopes);

      // 3. Enviar la notificación a la API V1
      // Usamos el cliente autenticado para obtener el token de acceso automáticamente
      final accessToken = client.credentials.accessToken.data;

      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/servify-app-4b50f/messages:send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken', // Usamos el token generado
        },
        body: jsonEncode({
          'message': {
            'token': token,
            'notification': {
              'title': title,
              'body': body,
            },
            'data': data, // Datos ocultos para la lógica de la app
            'android': {
              'notification': {
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'channel_id': 'high_importance_channel',
              }
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) print("✅ Notificación Push V1 enviada con éxito");
      } else {
        if (kDebugMode) print("❌ Error enviando Push V1: ${response.body}");
      }
      
      client.close(); // Cerramos el cliente al terminar

    } catch (e) {
      if (kDebugMode) print("❌ Error crítico en proceso Push: $e");
    }
  }
}