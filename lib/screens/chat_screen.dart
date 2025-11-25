import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_servify/models/usuarios_model.dart'; // <--- IMPORTANTE
import 'package:project_servify/services/chat_services.dart';
import 'package:project_servify/screens/perfil_usuario_screen.dart';

class ChatScreen extends StatefulWidget {
  final UsuarioModel targetUser; // Ahora recibimos el objeto completo

  const ChatScreen({
    super.key,
    required this.targetUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.targetUser.uid, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF0F3B81),
            foregroundColor: Colors.white,
            titleSpacing: 0,
            title: InkWell( // <--- ESTO ES LO QUE PERMITE EL CLIC
            onTap: () {
              // Navegar al perfil usando el objeto que recibimos
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PerfilUsuarioScreen(userModel: widget.targetUser),
                ),
              );
            },
            child: Row(
              children: [
                // Foto pequeña en la barra
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white24,
                  backgroundImage: (widget.targetUser.fotoUrl != null &&
                          widget.targetUser.fotoUrl!.isNotEmpty)
                      ? NetworkImage(widget.targetUser.fotoUrl!)
                      : null,
                  child: (widget.targetUser.fotoUrl == null ||
                          widget.targetUser.fotoUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 20, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                // Nombre del usuario
                Expanded(
                  child: Text(
                    "${widget.targetUser.nombre} ${widget.targetUser.apellidos}",
                    style: const TextStyle(fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            // Lista de mensajes
            Expanded(child: _buildMessageList()),
            // Input de texto
            _buildMessageInput(),
          ],
        ),
      );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
          _auth.currentUser!.uid, widget.targetUser.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(15),
          // Hacemos que la lista empiece desde abajo (tipo WhatsApp)
          reverse: false, 
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderId'] == _auth.currentUser!.uid;

    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    
    // Colores tipo WhatsApp/Telegram
    var color = isCurrentUser 
        ? const Color(0xFFE3F2FD) // Azul muy clarito para mis mensajes
        : const Color(0xFFF5F5F5); // Gris muy clarito para los recibidos

    return Container(
      alignment: alignment,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 5),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isCurrentUser ? const Radius.circular(12) : const Radius.circular(0),
            bottomRight: isCurrentUser ? const Radius.circular(0) : const Radius.circular(12),
          ),
          boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.05),
               blurRadius: 2,
               offset: const Offset(0, 1),
             )
          ]
        ),
        child: Column(
          crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(data['message'], style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(10.0),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: const Color(0xFF0F3B81),
              radius: 24,
              child: IconButton(
                onPressed: sendMessage,
                icon: const Icon(Icons.send, size: 20, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}