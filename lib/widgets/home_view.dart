import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_servify/screens/home_screen.dart';
import 'package:project_servify/widgets/menu_bar.dart'; 
import 'package:project_servify/models/usuarios_model.dart';
import 'package:project_servify/screens/perfil_usuario_screen.dart';

// CORRECCIÓN: Función helper global para obtener iniciales de forma segura
String _getInitials(User? user, UsuarioModel? userModel) {
  // Prioridad 1: Nombre del modelo de usuario
  if (userModel != null && userModel.nombre.isNotEmpty) {
    return userModel.nombre[0].toUpperCase();
  }
  
  // Prioridad 2: DisplayName de Firebase
  if (user?.displayName != null && user!.displayName!.isNotEmpty) {
    return user.displayName![0].toUpperCase();
  }
  
  // Prioridad 3: Email
  if (user?.email != null && user!.email!.isNotEmpty) {
    return user.email![0].toUpperCase();
  }
  
  // Fallback: S de Servify
  return "S";
}

class HomeView extends StatelessWidget {
  final User? user;
  final UsuarioModel? userModel;
  final List<Map<String, String>> allServices;
  final int selectedIndex;
  final List<Widget> widgetOptions;
  
  final Function(int) onItemTapped;
  final Function(BuildContext, ServiceData) navigateToServiceDetail;
  final Function(BuildContext) navigateToSearch;
  final Function(BuildContext) navigateToAddService;
  final Function(BuildContext) navigateToNotifications;

  const HomeView({
    super.key,
    required this.user,
    required this.userModel,
    required this.allServices,
    required this.selectedIndex,
    required this.widgetOptions,
    required this.onItemTapped,
    required this.navigateToServiceDetail,
    required this.navigateToSearch,
    required this.navigateToAddService,
    required this.navigateToNotifications,
  });

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              userModel != null 
                  ? '${userModel!.nombre} ${userModel!.apellidos}' 
                  : (user != null ? user!.displayName ?? "Usuario Sin Nombre" : "Invitado"),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: user != null 
                ? Text(user!.email ?? "Correo no disponible")
                : const Text("Inicia sesión o regístrate"), 
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: user?.photoURL != null
                  ? ClipOval(
                      child: Image.network(
                        user!.photoURL!,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Text(
                      _getInitials(user, userModel),
                      style: const TextStyle(
                        fontSize: 40.0,
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 31, 122, 158),
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.home_repair_service),
            title: const Text('Servicios'),
            onTap: () {
              Navigator.pop(context);
              onItemTapped(0);
            },
          ),
           ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Historial'),
            onTap: () {
              Navigator.pop(context);
              onItemTapped(1);
            },
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            onTap: () {
              Navigator.pop(context);
              
              if (user != null && userModel != null) {
                // CORRECCIÓN: Navegar directamente sin cambiar índice
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PerfilUsuarioScreen(userModel: userModel!),
                  ),
                ).then((_) {
                  // Al volver, asegurar que estamos en la pestaña correcta
                  if (selectedIndex != 0) {
                    onItemTapped(0);
                  }
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Debes iniciar sesión para ver tu perfil'),
                  ),
                );
                Navigator.pushNamed(context, 'inicio_usuarios');
              }
            },
          ),
          
          const Divider(),
          
          if (user != null) 
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut(); 
                
                // CORRECCIÓN: Resetear índice al cerrar sesión
                onItemTapped(0);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sesión Cerrada')),
                  );
                }
              },
            )
          else 
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Iniciar Sesión / Registrarse'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'inicio_usuarios');
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // CORRECCIÓN: Validar índice antes de usar
    final safeIndex = selectedIndex.clamp(0, widgetOptions.length - 1);
    
    return WillPopScope(
      // CORRECCIÓN: Manejar el botón "atrás" correctamente
      onWillPop: () async {
        if (safeIndex != 0) {
          // Si no estamos en Home, volver a Home
          onItemTapped(0);
          return false; // No cerrar la app
        }
        // Si estamos en Home, permitir cerrar la app
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 25, 64, 119),
        appBar: Menu_Bar(
          isAuthenticated: user != null,
          notificationCount: 5,
          onSearchPressed: () => navigateToSearch(context),
          onNotificationPressed: () => navigateToNotifications(context),
          onProfilePressed: () {
            // CORRECCIÓN: Usar navegación consistente
            if (user != null && userModel != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PerfilUsuarioScreen(userModel: userModel!),
                ),
              ).then((_) {
                // Al volver, asegurar que estamos en la vista correcta
                if (safeIndex != 0) {
                  onItemTapped(0);
                }
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Inicia sesión para ver tu perfil'),
                ),
              );
              Navigator.pushNamed(context, 'inicio_usuarios');
            }
          },
          onLoginPressed: () => Navigator.pushNamed(context, 'inicio_usuarios'),
          onSignUpPressed: () => Navigator.pushNamed(context, 'crear_cuenta'),
        ),
        drawer: _buildDrawer(context),
        body: IndexedStack(
          // CORRECCIÓN: Usar IndexedStack en lugar de acceso directo
          index: safeIndex,
          children: widgetOptions,
        ),
        floatingActionButton: safeIndex == 0
            ? Visibility(
                visible: userModel?.tipo == 'provider',
                child: FloatingActionButton(
                  onPressed: () => navigateToAddService(context),
                  backgroundColor: const Color(0xFF0F3B81),
                  child: const Icon(Icons.add),
                ),
              )
            : null,
      ),
    );
  }
}