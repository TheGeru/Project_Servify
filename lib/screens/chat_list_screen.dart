import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_servify/models/usuarios_model.dart'; 
import 'package:project_servify/screens/chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Mensajes'),
        backgroundColor: const Color(0xFF0F3B81),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chat_rooms')
            .where('users', arrayContains: currentUserId)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No tienes conversaciones activas"),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final users = List<String>.from(data['users']);
              
              final otherUserId = users.firstWhere((id) => id != currentUserId);
              final lastMessage = data['lastMessage'] ?? 'Imagen o archivo';
              
              // Timestamp a fecha legible (opcional, lógica simple)
              // final Timestamp? timestamp = data['lastMessageTime'];
              
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return const SizedBox();
                  
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  
                  // CREAMOS EL MODELO AQUÍ
                  final otherUser = UsuarioModel.fromMap(userData); 

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blue.shade100,
                      backgroundImage: (otherUser.fotoUrl != null && otherUser.fotoUrl!.isNotEmpty)
                          ? NetworkImage(otherUser.fotoUrl!)
                          : null,
                      child: (otherUser.fotoUrl == null || otherUser.fotoUrl!.isEmpty)
                          ? Text(otherUser.nombre[0].toUpperCase(), 
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                          : null,
                    ),
                    title: Text(
                      "${otherUser.nombre} ${otherUser.apellidos}", 
                      style: const TextStyle(fontWeight: FontWeight.bold)
                    ),
                    subtitle: Text(
                      lastMessage, 
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    onTap: () {
                      // NAVEGAMOS PASANDO EL MODELO
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            targetUser: otherUser, // <--- Ahora pasamos el objeto
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
