import 'package:flutter/material.dart';

class PerfilUsuarioScreen extends StatelessWidget {
  const PerfilUsuarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F3B81),
      // 🛑 1. AGREGAR APPBAR PARA EL BOTÓN DE REGRESO
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Fondo transparente
        elevation: 0, // Sin sombra
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Ícono blanco
          onPressed: () => Navigator.pushReplacementNamed(context, 'home'), // Función de regreso manual
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // El resto de tu UI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.purple[100],
                    child: const Icon(
                      Icons.person,
                      size: 160,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'CAMBIAR FOTO',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // ... (Contenedor vacío)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),               
              ),
            ),
            const SizedBox(height: 20),
            // ... (Contenedor de Información)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'INFORMACION',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text('NOMBRE COMPLETO'),
                    Text('Juan Perez Alonso'),
                    SizedBox(height: 10),
                    Text('TELEFONO'),
                    Text('427123456'),
                    SizedBox(height: 10),
                    Text('CORREO'),
                    Text('ejemplo@hotmail.com'),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                    onPressed: () {},
                    child: const Text('EDITAR'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    onPressed: () {},
                    child: const Text('ELIMINAR'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}