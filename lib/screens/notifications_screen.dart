import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(
              Icons.circle_notifications,
              color: Color.fromARGB(255, 31, 122, 158),
            ),
            title: Text('Nueva cotización recibida.'),
            subtitle: Text('Plomería - Hace 5 minutos'),
            trailing: Icon(Icons.arrow_forward_ios, size: 14),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.circle_notifications, color: Colors.grey),
            title: Text('Servicio de Carpintería completado.'),
            subtitle: Text('Hace 2 horas'),
            trailing: Icon(Icons.arrow_forward_ios, size: 14),
          ),
          Divider(),
          Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('Aquí se mostrarán las notificaciones.'),
            ),
          ),
        ],
      ),
    );
  }
}
