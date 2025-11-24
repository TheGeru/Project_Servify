import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_servify/models/anuncios_model.dart';
import 'package:project_servify/models/usuarios_model.dart';

class AnuncioCard extends StatelessWidget {
  final AnuncioModel anuncio;
  final VoidCallback? onTap;
  final bool showProviderInfo; // Mostrar info del proveedor
  final VoidCallback? onEdit; // Callback para editar
  final VoidCallback? onDelete; // Callback para eliminar

  const AnuncioCard({
    super.key,
    required this.anuncio,
    this.onTap,
    this.showProviderInfo = true,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black54,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (anuncio.imagenes.isNotEmpty)
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey[300]),
                  child: Image.network(
                    anuncio.imagenes.first['url'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.home_repair_service,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),

              // Contenido del anuncio
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título y precio
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            anuncio.titulo,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '\$${anuncio.precio.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Categoría (si existe)
                    if (anuncio.categoria != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Chip(
                          label: Text(
                            anuncio.categoria!,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.blue.shade100,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),

                    // Descripción
                    Text(
                      anuncio.descripcion,
                      style: const TextStyle(fontSize: 16),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Información del proveedor
                    if (showProviderInfo)
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(anuncio.proveedorId)
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox.shrink();
                          }

                          final proveedorData =
                              snapshot.data?.data() as Map<String, dynamic>?;
                          if (proveedorData == null) {
                            return const SizedBox.shrink();
                          }

                          final proveedor = UsuarioModel.fromMap(proveedorData);

                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.orange.shade100,
                                backgroundImage:
                                    (proveedor.fotoUrl != null &&
                                        proveedor.fotoUrl!.isNotEmpty)
                                    ? NetworkImage(proveedor.fotoUrl!)
                                    : null,
                                child:
                                    (proveedor.fotoUrl == null ||
                                        proveedor.fotoUrl!.isEmpty)
                                    ? Icon(
                                        Icons.person,
                                        size: 18,
                                        color: Colors.orange.shade800,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Por: ${proveedor.nombre} ${proveedor.apellidos}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                    // Botones de acción (Editar/Eliminar) - SOLO para el dueño
                    if (onEdit != null || onDelete != null)
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.admin_panel_settings,
                              size: 16,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Opciones de administración',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                            if (onEdit != null)
                              IconButton(
                                onPressed: onEdit,
                                icon: const Icon(Icons.edit, size: 20),
                                color: Colors.blue,
                                tooltip: 'Editar anuncio',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            const SizedBox(width: 8),
                            if (onDelete != null)
                              IconButton(
                                onPressed: onDelete,
                                icon: const Icon(Icons.delete, size: 20),
                                color: Colors.red,
                                tooltip: 'Eliminar anuncio',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
