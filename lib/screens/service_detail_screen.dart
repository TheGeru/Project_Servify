import 'package:flutter/material.dart';
import 'package:project_servify/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Definición de la estructura de datos que se espera
typedef ServiceData = Map<String, dynamic>;

class ServiceDetailScreen extends StatelessWidget {
  final ServiceData serviceData;
  // NOTA: Inicializamos aquí para evitar el error de constructor const
  final AuthService _authService = AuthService();

  // CORREGIDO: Eliminamos 'const' del constructor.
  ServiceDetailScreen({super.key, required this.serviceData});

  // Widget para construir una sección de información
  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
    IconData icon = Icons.info_outline,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF0F3B81)),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F3B81),
                ),
              ),
            ],
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  // Widget para mostrar un detalle (etiqueta y valor)
  Widget _buildDetailRow(String label, String value, {bool isLarge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isLarge ? 16 : 14,
              color: isLarge ? Colors.black87 : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    // Uso de ?? 'Valor por defecto' para prevenir el error Null check operator
    final serviceTitle = serviceData['titulo'] ?? 'Servicio Desconocido';
    final providerName = serviceData['proveedor_nombre'] ?? 'Proveedor Anónimo';
    final serviceCategory = serviceData['categoria'] ?? 'Sin Categoría';
    final serviceDescription =
        serviceData['descripcion'] ?? 'Sin descripción breve.';
    final fullDescription =
        serviceData['descripcion_completa'] ??
        'No hay una descripción detallada disponible.';
    final serviceSchedule = serviceData['horario'] ?? 'Horario no especificado';

    return Scaffold(
      appBar: AppBar(
        title: Text(serviceTitle),
        backgroundColor: const Color(0xFF0F3B81),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Banner/Imagen del Servicio ---
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
                image: const DecorationImage(
                  image: AssetImage('assets/images/servify_logo.png'),
                  fit: BoxFit.contain,
                ),
              ),
              child: Center(
                child: Text(
                  serviceTitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- 2. Descripción del Servicio ---
            _buildInfoSection(
              title: 'Detalles del Servicio',
              icon: Icons.description,
              children: [
                _buildDetailRow('Categoría', serviceCategory),
                _buildDetailRow(
                  'Descripción Completa',
                  fullDescription,
                  isLarge: true,
                ),
                _buildDetailRow('Horario de Atención', serviceSchedule),
                _buildDetailRow('Publicado por', providerName),
              ],
            ),

            // --- 3. Información del Proveedor ---
            _buildInfoSection(
              title: 'Información del Proveedor',
              icon: Icons.person_pin,
              children: [
                _buildDetailRow('Proveedor', providerName),
                _buildDetailRow('Especialidad', serviceTitle),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const Icon(Icons.star_half, color: Colors.amber, size: 20),
                    const SizedBox(width: 5),
                    Text(
                      '4.5 estrellas',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- 4. Botón de Contacto (Depende de Autenticación) ---
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  if (user == null) {
                    // Si no está logueado, pide que inicie sesión
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Debes iniciar sesión para contactar al proveedor.',
                        ),
                      ),
                    );
                    Navigator.pushNamed(context, 'inicio_usuarios');
                  } else {
                    // Lógica para contactar (e.g., abrir chat o formulario de cotización)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Iniciando contacto con $providerName...',
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.contact_mail),
                label: Text(
                  user == null
                      ? 'INICIA SESIÓN PARA CONTACTAR'
                      : 'CONTACTAR / SOLICITAR',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 127, 80),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}