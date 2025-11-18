import 'package:flutter/material.dart';
import 'package:project_servify/models/usuarios_model.dart';
import 'package:project_servify/screens/add_service_screen.dart';
import 'package:project_servify/widgets/info_row.dart';

class PerfilUsuarioScreen extends StatelessWidget {
  final UsuarioModel userModel;

  const PerfilUsuarioScreen({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F3B81),
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Fondo transparente
        elevation: 0, // Sin sombra
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ), // Ícono blanco
          onPressed: () => Navigator.pushReplacementNamed(
            context,
            'home',
          ), // Función de regreso manual
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
                  children: [
                    Text(
                      'INFORMACION',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...(
                      userModel.tipo == 'provider'
                    ? [
                      InfoRow(
                        title: "Descripcion",
                        value: userModel.descripcion ?? "Sin descripcion",
                      ),
                    ]: [
                    SizedBox(height: 10),
                    InfoRow(title: "Nombre", value: userModel.nombre),
                    InfoRow(title: "Apellido", value: userModel.apellidos),
                    InfoRow(title: "Correo", value: userModel.email),
                    InfoRow(title: "Telefono", value: userModel.telefono),
                    ]),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {},
                    child: const Text('EDITAR'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {},
                    child: const Text('ELIMINAR'),
                  ),
                  if (userModel.tipo == 'user')
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddServiceScreen()
                          ),
                        );
                      },
                      child: const Text('Convertirme en en Proveedor'),
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
