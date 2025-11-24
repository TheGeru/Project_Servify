import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_servify/services/notification_service.dart';

typedef ServiceData = Map<String, dynamic>;

class ServiceDetailScreen extends StatelessWidget {
  final ServiceData serviceData;

  const ServiceDetailScreen({super.key, required this.serviceData});

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

    final serviceTitle = serviceData['titulo'] ?? 'Servicio Desconocido';
    final providerName = serviceData['proveedor_nombre'] ?? 'Proveedor Anónimo';
    final providerId =
        serviceData['proveedor_id']; // ID necesario para notificación
    final serviceCategory = serviceData['categoria'] ?? 'Sin Categoría';
    final fullDescription =
        serviceData['descripcion_completa'] ??
        'No hay una descripción detallada disponible.';
    final serviceSchedule = serviceData['horario'] ?? 'Horario no especificado';

    // Imagen (usando la primera si existe)
    final List<dynamic> images = serviceData['imagenes'] ?? [];
    final String? firstImage = images.isNotEmpty ? images.first['url'] : null;

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
            // Banner/Imagen del Servicio
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: firstImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(firstImage, fit: BoxFit.cover),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image, size: 50, color: Colors.grey),
                          const SizedBox(height: 10),
                          Text(
                            serviceTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            // Descripción del Servicio
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

            // Información del Proveedor
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

            //  Botón de Contacto (Con Notificación)
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Debes iniciar sesión para contactar al proveedor.',
                        ),
                      ),
                    );
                    Navigator.pushNamed(context, 'inicio_usuarios');
                  } else {
                    // Validacion de ID del proveedor
                    if (providerId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Error: No se pudo identificar al proveedor.',
                          ),
                        ),
                      );
                      return;
                    }

                    // Evitar auto-contacto
                    if (providerId == user.uid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'No puedes solicitar tu propio servicio.',
                          ),
                        ),
                      );
                      return;
                    }

                    // ENVIAR NOTIFICACIÓN
                    final notiService = NotificationService();
                    try {
                      await notiService.sendNotification(
                        toUserId: providerId,
                        fromUserId: user.uid,
                        fromUserName:
                            user.displayName ?? 'Un cliente interesado',
                        title: '¡Nueva solicitud de servicio!',
                        body: 'Un cliente está interesado en: $serviceTitle',
                        type: 'contact_request',
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Solicitud enviada a $providerName. Te contactará pronto.',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al enviar solicitud: $e'),
                          ),
                        );
                      }
                    }
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
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
