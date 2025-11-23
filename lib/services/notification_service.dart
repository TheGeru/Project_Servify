import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

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
    required String toUserId, // ID del proveedor que recibe
    required String fromUserId, // ID del cliente que envía
    required String fromUserName,
    required String title,
    required String body,
    required String type,
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
    });
  }

  Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('toUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
