import 'package:flutter/material.dart';

class RecuperarPassScreen extends StatelessWidget {
  const RecuperarPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'),
      ),
      body: const Center(
        child: Text('Pantalla de Recuperación de Contraseña'),
      ),
    );
  }
}