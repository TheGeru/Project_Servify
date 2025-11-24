import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_servify/services/notification_service.dart';
import 'package:project_servify/screens/chat_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final notiService = NotificationService();

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notificaciones')),
        body: const Center(
          child: Text("Inicia sesión para ver notificaciones"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: const Color(0xFF0F3B81),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notiService.getUserNotifications(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No tienes notificaciones nuevas",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data!.docs;

          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1, indent: 70),
            itemBuilder: (context, index) {
              final data = notifications[index].data() as Map<String, dynamic>;
              final isRead = data['read'] ?? false;

              return ListTile(
                tileColor: isRead ? Colors.white : Colors.blue.shade50,
                leading: CircleAvatar(
                  backgroundColor: isRead
                      ? Colors.grey.shade300
                      : const Color(0xFFFF6B35),
                  child: Icon(
                    Icons.notifications,
                    color: isRead ? Colors.grey : Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(
                  data['title'] ?? 'Notificación',
                  style: TextStyle(
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      data['body'] ?? '',
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'De: ${data['fromUserName'] ?? 'Usuario'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  // accion deMarcar como leída al tocar
                  if (!isRead) {
                    notifications[index].reference.update({'read': true});
                  }

                  if(data['type'] == 'chat_request' || data['type'] == 'contact_request') {
                    // Navegar a la pantalla de chat
                    final metadata = data['metadata'] as Map<String, dynamic>?;
                    final fromUserId = data['fromUserId']; // Fallback si no hay metadata
                    final fromUserName = data['fromUserName'];

                    // El ID del otro usuario es 'fromUserId' (quien envió la noti)
                    // O mejor, sácalo de metadata si lo guardaste ahí.
                    final partnerId = metadata?['chatPartnerId'] ?? fromUserId;
                    final partnerName = metadata?['chatPartnerName'] ?? fromUserName;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          receiverUserEmail: partnerName,
                          receiverUserId: partnerId,
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
