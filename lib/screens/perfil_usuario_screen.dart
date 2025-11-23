import 'package:flutter/material.dart';
import 'package:project_servify/models/usuarios_model.dart';
import 'package:project_servify/screens/upgrade_to_provider_screen.dart';
import 'package:project_servify/screens/edit_profile_screen.dart';
import 'package:project_servify/widgets/info_row.dart';

class PerfilUsuarioScreen extends StatelessWidget {
  final UsuarioModel userModel;

  const PerfilUsuarioScreen({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    final bool isProvider = userModel.tipo == 'provider';
    final bool isGuest = userModel.uid.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0F3B81),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pushReplacementNamed(context, 'home'),
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
                    backgroundColor: isProvider
                        ? Colors.orange[100]
                        : Colors.purple[100],
                    child: Icon(
                      isProvider ? Icons.work : Icons.person,
                      size: 160,
                      color: isProvider ? Colors.orange : Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (!isGuest)
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Función de cambiar foto en desarrollo',
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'CAMBIAR FOTO',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
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
            const SizedBox(height: 20),

            // === SECCIÓN: BOTONES DE ACCIÓN ===
            if (!isGuest)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Botón EDITAR (ACTUALIZADO)
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          // Navegamos a la pantalla de edición
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditProfileScreen(userModel: userModel),
                            ),
                          );

                          // Si se editó con éxito, recargamos la vista home
                          if (result == true && context.mounted) {
                            Navigator.pushReplacementNamed(context, 'home');
                          }
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text(
                          'EDITAR',
                          style: TextStyle(fontSize: 12),
                        ),
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
                        label: const Text(
                          'ELIMINAR',
                          style: TextStyle(fontSize: 12),
                        ),
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
                          label: const Text(
                            'SER PROVEEDOR',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            const SizedBox(height: 30),

            // Botones Login/Registro para invitados...
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
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ Eliminar Cuenta'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar tu cuenta?\n\n'
          'Esta acción es IRREVERSIBLE y perderás todos tus datos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función de eliminar cuenta en desarrollo'),
                  backgroundColor: Colors.red,
                ),
              );
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
}
