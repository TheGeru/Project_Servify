import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddServiceScreen extends StatelessWidget {
  const AddServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Si por alguna razón la navegación falló la verificación, regresa.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Si el usuario está autenticado, muestra el formulario simulado.
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Nuevo Servicio')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¡Publica tu Servicio!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
<<<<<<< Updated upstream
                  color: Color.fromARGB(255, 31, 122, 158),
=======
                  color: Color(0xFF0F3B81),
>>>>>>> Stashed changes
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Aquí irá el formulario completo para que el proveedor ingrese:\n- Título del servicio\n- Categoría\n- Descripción detallada\n- Horario de atención\n- Fotos (Galería)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 30),
              Icon(Icons.person_pin_circle, size: 80, color: Colors.orange),
              SizedBox(height: 20),
              Text(
                'Esta pantalla solo es accesible para usuarios logueados.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
