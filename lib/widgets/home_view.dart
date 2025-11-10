import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Necesario para el tipo User
import 'package:project_servify/widgets/menu_bar.dart'; 
// Asegúrate de importar el archivo donde tienes Menu_Bar

class HomeView extends StatelessWidget {
  // --- PROPIEDADES RECIBIDAS (DATOS Y CALLBACKS) ---
  final User? user;
  final List<Map<String, String>> allServices;
  final int selectedIndex;
  final List<Widget> widgetOptions;
  
  // Callbacks de Lógica
  final Function(int) onItemTapped;
  final Function(BuildContext, String) navigateToServiceDetail;
  final Function(BuildContext) navigateToSearch;
  final Function(BuildContext) navigateToAddService;
  final Function(BuildContext) navigateToNotifications;

  const HomeView({
    super.key,
    required this.user,
    required this.allServices,
    required this.selectedIndex,
    required this.widgetOptions,
    required this.onItemTapped,
    required this.navigateToServiceDetail,
    required this.navigateToSearch,
    required this.navigateToAddService,
    required this.navigateToNotifications,
  });

  // --- MÉTODOS AUXILIARES DE DISEÑO (DRAWER) ---
  
  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              user != null ? user?.displayName ?? "Usuario de Servify" : "Invitado",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: user != null 
                ? Text(user!.email ?? "Correo no disponible") 
                : const Text("Inicia sesión o regístrate"), 
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: user?.photoURL != null
                  ? ClipOval(child: Image.network(user!.photoURL!))
                  : Text(user != null && user?.displayName != null ? user!.displayName![0] : "S", style: const TextStyle(fontSize: 40.0)),
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
              if (user != null) {
                 onItemTapped(2); // Usamos la función pasada
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Debes iniciar sesión para ver tu perfil')),
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
                // NOTA: Cerramos sesión directamente en la vista por conveniencia, 
                // pero idealmente se llamaría a una función pasada como parámetro.
                await FirebaseAuth.instance.signOut(); 
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sesión Cerrada')),
                );
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

  // --- CONSTRUCCIÓN DE LA VISTA (SOLO SCAFFOLD) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 25, 64, 119),
      appBar: Menu_Bar(
        isAuthenticated: user != null,
        notificationCount: 5,
        onSearchPressed: () => navigateToSearch(context), // Llama al callback pasado
        onNotificationPressed: () => navigateToNotifications(context),
        onProfilePressed: () {
          if (user != null) {
            Navigator.pushNamed(context, '/profile');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Inicia sesión para ver tu perfil')),
            );
            Navigator.pushNamed(context, 'inicio_usuarios');
          }
        },
        onLoginPressed: () => Navigator.pushNamed(context, 'inicio_usuarios'),
        onSignUpPressed: () => Navigator.pushNamed(context, 'crear_cuenta'),
      ),
      drawer: _buildDrawer(context), // Usamos el Drawer separado
      body: widgetOptions.elementAt(selectedIndex),
      floatingActionButton: selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => navigateToAddService(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}