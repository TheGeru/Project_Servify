import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Generar un ID único para el chat entre dos usuarios (siempre igual para los mismos pares)
  String getChatRoomId(String user1, String user2) {
    if (user1.compareTo(user2) > 0) {
      return "$user1, $user2";
    } else {
      return "$user2, $user1";
    }
  }

  // Enviar mensaje
  Future<void> sendMessage(String receiverId, String message) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String chatRoomId = getChatRoomId(currentUserId, receiverId);
    final Timestamp timestamp = Timestamp.now();

    // Estructura del mensaje
    Map<String, dynamic> newMessage = {
      'senderId': currentUserId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'read': false,
    };

    // Guardar en la subcolección 'messages' de la sala de chat
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage);

    // Actualizar datos de la sala (para mostrar último mensaje en una lista de chats si quisieras)
    await _firestore.collection('chat_rooms').doc(chatRoomId).set({
      'users': [currentUserId, receiverId],
      'lastMessage': message,
      'lastMessageTime': timestamp,
    }, SetOptions(merge: true));
  }

  // Obtener mensajes (Stream)
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    String chatRoomId = getChatRoomId(userId, otherUserId);
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}