import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_servify/models/usuarios_model.dart';
import 'package:project_servify/screens/upgrade_to_provider_screen.dart';
import 'package:project_servify/screens/edit_profile_screen.dart';
import 'package:project_servify/screens/chat_screen.dart';
import 'package:project_servify/widgets/info_row.dart';
import 'package:project_servify/services/profile_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_servify/models/anuncios_model.dart';
import 'package:project_servify/services/anuncios_service.dart';
import 'package:project_servify/widgets/card_container.dart';
import 'package:project_servify/screens/service_detail_screen.dart';
import 'package:project_servify/screens/edit_service_screen.dart';

class PerfilUsuarioScreen extends StatelessWidget {
  final UsuarioModel userModel;

  const PerfilUsuarioScreen({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    // 1. OBTENER EL USUARIO LOGUEADO
    final currentUser = FirebaseAuth.instance.currentUser;

    // 2. DEFINIR SI ES MI PERFIL
    // Es mi perfil si estoy logueado Y el ID del perfil coincide con el mío
    final bool isMe = currentUser != null && currentUser.uid == userModel.uid;

    final bool isProvider = userModel.tipo == 'provider';
    final bool isGuest = userModel.uid.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0F3B81),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(
              context), // Mejor pop que pushReplacement para volver
        ),
        title: Text(
          isProvider ? 'Perfil de Proveedor' : 'Perfil de Usuario',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // === SECCIÓN: FOTO DE PERFIL ===
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 100,
                    backgroundColor:
                        isProvider ? Colors.orange[100] : Colors.purple[100],
                    backgroundImage: (userModel.fotoUrl != null &&
                            userModel.fotoUrl!.isNotEmpty)
                        ? NetworkImage(userModel.fotoUrl!)
                        : null,
                    child: (userModel.fotoUrl == null ||
                            userModel.fotoUrl!.isEmpty)
                        ? Icon(
                            isProvider ? Icons.work : Icons.person,
                            size: 160,
                            color: isProvider ? Colors.orange : Colors.purple,
                          )
                        : null,
                  ),
                  const SizedBox(height: 10),

                  // SOLO MOSTRAR "CAMBIAR FOTO" SI ES MI PERFIL
                  if (isMe)
                    TextButton(
                      onPressed: () async {
                        await _cambiarFotoPerfil(context, userModel);
                      },
                      child: const Text(
                        'CAMBIAR FOTO',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                  // ... (El container de PROVEEDOR/USUARIO sigue igual) ...
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isProvider
                          ? Colors.orange.withOpacity(0.9)
                          : Colors.blue.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isProvider ? '⭐ PROVEEDOR' : '👤 USUARIO',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ... (Secciones de Descripción e Información General siguen igual) ...
            const SizedBox(height: 20),

            // === SECCIÓN: DESCRIPCIÓN (SOLO PROVEEDORES) ===
            if (isProvider &&
                userModel.descripcion != null &&
                userModel.descripcion!.isNotEmpty)
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
                      const Row(
                        children: [
                          Icon(Icons.description, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'DESCRIPCIÓN DEL SERVICIO',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        userModel.descripcion!,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),

            if (isProvider) const SizedBox(height: 20),

            // === SECCIÓN: INFORMACIÓN GENERAL ===
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
                    Row(
                      children: [
                        Icon(
                          isProvider
                              ? Icons.business_center
                              : Icons.person_outline,
                          color: isProvider ? Colors.orange : Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'INFORMACIÓN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 10),

                    // Información visible para todos (menos invitados)
                    if (!isGuest) ...[
                      InfoRow(
                        title: "Nombre Completo",
                        value: "${userModel.nombre} ${userModel.apellidos}",
                      ),
                      InfoRow(title: "Correo", value: userModel.email),
                      InfoRow(
                        title: "Teléfono",
                        value: userModel.telefono.isEmpty
                            ? 'No especificado'
                            : userModel.telefono,
                      ),
                    ],

                    if (isProvider &&
                        userModel.oficios != null &&
                        userModel.oficios!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'Oficios / Especialidades:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: userModel.oficios!.map((oficio) {
                          return Chip(
                            label: Text(oficio),
                            backgroundColor: Colors.orange.shade100,
                            avatar: const Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.orange,
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    if (isGuest)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'Inicia sesión para ver tu perfil completo',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // === SECCIÓN: BOTONES DE ACCIÓN (AQUÍ ESTÁ LA LÓGICA NUEVA) ===

            // CASO 1: ES MI PERFIL (Muestro Editar, Eliminar, Upgrade)
            if (isMe)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Botón EDITAR
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditProfileScreen(userModel: userModel),
                            ),
                          );

                          if (result == true && context.mounted) {
                            Navigator.pushReplacementNamed(context, 'home');
                          }
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('EDITAR',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Botón ELIMINAR CUENTA
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          _showDeleteAccountDialog(context);
                        },
                        icon: const Icon(Icons.delete_forever, size: 18),
                        label: const Text('ELIMINAR',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ),

                    // Botón CONVERTIRSE EN PROVEEDOR
                    if (!isProvider) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B35),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const UpgradeToProviderScreen(),
                              ),
                            );

                            if (result == true && context.mounted) {
                              Navigator.pushReplacementNamed(context, 'home');
                            }
                          },
                          icon: const Icon(Icons.upgrade, size: 18),
                          label: const Text('PROVEEDOR',
                              style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // CASO 2: NO ES MI PERFIL, NO SOY INVITADO (Muestro Contactar)
            if (!isMe && !isGuest)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity, // Ocupa todo el ancho
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors
                          .green, // Color distintivo para acción principal
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // NAVEGAR AL CHAT
                      // Asegúrate de tener ChatScreen importado o definido
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            targetUser:
                                userModel, // Pasamos el usuario del perfil
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send, size: 22),
                    label: const Text(
                      'ENVIAR MENSAJE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

            // CASO 3: ES INVITADO (Muestro Login)
            if (isGuest)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, 'inicio_usuarios');
                      },
                      child: const Text(
                        'INICIAR SESIÓN',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'crear_cuenta');
                      },
                      child: const Text(
                        '¿No tienes cuenta? Regístrate',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            _buildUserAnuncios(context, userModel, isMe),
          ],
        ),
      ),
    );
  }
}

Future<void> _cambiarFotoPerfil(
  BuildContext context,
  UsuarioModel user,
) async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);

  if (image == null) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Subiendo imagen... por favor espera')),
  );
  try {
    final profileService = ProfileService();

    await profileService.updateProfilePhoto(user.uid, image);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Foto actualizada correctamente')),
    );

    Navigator.pushReplacementNamed(context, 'home');
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al actualizar foto: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

void _showDeleteAccountDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('⚠️ Eliminar Cuenta'),
      content: const Text(
        '¿Estás seguro de que deseas eliminar tu cuenta?\n\n'
        'Esta acción es IRREVERSIBLE.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            Navigator.pop(ctx);
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (c) => const Center(child: CircularProgressIndicator()),
            );

            try {
              final profileService = ProfileService();
              await profileService.deleteAccount();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  'home',
                  (route) => false,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cuenta eliminada correctamente.'),
                  ),
                );
              }
            } on FirebaseAuthException catch (e) {
              if (context.mounted) {
                Navigator.pop(context);
                if (e.code == 'requires-recent-login') {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    'home',
                    (route) => false,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Por seguridad, la sesión ha expirado. Entra a tu perfil nuevamente para eliminar.',
                      ),
                      duration: Duration(seconds: 5),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } else {
                  // Otro error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            } catch (e) {
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: const Text(
            'ELIMINAR',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}

// MÉTODO PARA MOSTRAR ANUNCIOS
// Método actualizado para recibir 'userModel' y 'isMe'
Widget _buildUserAnuncios(
    BuildContext context, UsuarioModel userModel, bool isMe) {
  if (userModel.tipo != 'provider') {
    return const SizedBox.shrink();
  }

  final anunciosService = AnunciosService();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Servicios Publicados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            // Un pequeño contador opcional
            if (isMe)
              const Icon(Icons.settings, color: Colors.white70, size: 16),
          ],
        ),
      ),
      StreamBuilder<List<AnuncioModel>>(
        stream: anunciosService.getAnunciosByProveedor(userModel.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final anuncios = snapshot.data ?? [];

          if (anuncios.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isMe
                    ? 'No has publicado servicios aún.'
                    : 'Este usuario aún no tiene servicios activos.',
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: anuncios.length,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemBuilder: (context, index) {
              final anuncio = anuncios[index];

              return AnuncioCard(
                anuncio: anuncio,
                showProviderInfo: false,
                onTap: () {
                  // Navegar al detalle
                  final serviceData = {
                    'titulo': anuncio.titulo,
                    'descripcion': anuncio.descripcion,
                    'precio': anuncio.precio,
                    'categoria': anuncio.categoria ?? 'Servicios',
                    'descripcion_completa': anuncio.descripcion,
                    'proveedor_id': anuncio.proveedorId,
                    'imagenes': anuncio.imagenes,
                  };

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ServiceDetailScreen(serviceData: serviceData),
                    ),
                  );
                },

                // === LÓGICA DE EDICIÓN (Solo si es mi perfil) ===
                onEdit: isMe
                    ? () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditServiceScreen(anuncio: anuncio),
                          ),
                        );
                        // El StreamBuilder se actualizará solo, pero puedes mostrar un mensaje
                        if (result == true && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Anuncio actualizado')),
                          );
                        }
                      }
                    : null, // Si no es mi perfil, pasamos null y los botones se ocultan

                // === LÓGICA DE ELIMINACIÓN (Solo si es mi perfil) ===
                onDelete: isMe
                    ? () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Eliminar Servicio'),
                            content: const Text(
                              '¿Estás seguro de que quieres eliminar este servicio permanentemente?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && context.mounted) {
                          try {
                            await anunciosService.deleteAnuncio(
                                anuncio.id, anuncio.proveedorId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Servicio eliminado'),
                                  backgroundColor: Colors.red),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      }
                    : null,
              );
            },
          );
        },
      ),
      const SizedBox(height: 40),
    ],
  );
}
