import 'package:flutter/material.dart';

import 'package:project_servify/screens/history_screen.dart';
//import 'package:project_servify/screens/profile_screen.dart';
import 'package:project_servify/screens/service_detail_screen.dart';
import 'package:project_servify/screens/add_service_screen.dart';
import 'package:project_servify/widgets/card_container.dart';
import 'package:project_servify/screens/search_screen.dart';
import 'package:project_servify/screens/notifications_screen.dart';
import 'package:project_servify/screens/perfil_proveedor_screen.dart';
import 'package:project_servify/widgets/menu_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Map<String, String>> allServices = const [
    {
      'titulo': 'Carpintería',
      'categoria': 'Servicios',
      'descripcion': 'Ofrecemos servicios de carpintería a medida.',
    },
    {
      'titulo': 'Plomería',
      'categoria': 'Servicios',
      'descripcion': 'Reparación y mantenimiento de sistemas de plomería.',
    },
    {
      'titulo': 'Electricidad',
      'categoria': 'Servicios',
      'descripcion':
          'Instalación y reparación de sistemas eléctricos de tu casa u oficina.',
    },
    {
      'titulo': 'Jardinería',
      'categoria': 'Servicios',
      'descripcion':
          'Mantenimiento y diseño de jardines para tus áreas verdes.',
    },
    {
      'titulo': 'Plomería Urgente',
      'categoria': 'Servicios',
      'descripcion': 'Mantenimiento y diseño de tus tuberías de tu casa.',
    },
  ];
  void navigateToServiceDetail(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailScreen(serviceTitle: title),
      ),
    );
  }

  void navigateToAddService(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddServiceScreen()),
    );
  }

//  late final List<Widget> _widgetOptions = <Widget>[
  //  _ServicesList(navigateToServiceDetail: navigateToServiceDetail),
    //Funcion de navegacion a las nuevas pantallas
    //const HistoryScreen(),
    //const PerfilProveedorScreen(),
  //];

  // Función para cambiar el índice al presionar una pestaña
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 0) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    });
  }

  void navigateToSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(
          allServices: allServices,
          navigateToServiceDetail: navigateToServiceDetail,
        ),
      ),
    );
  }

  void navigateToNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
  }
// DEBES REEMPLAZAR COMPLETAMENTE EL MÉTODO build EXISTENTE CON ESTE:

@override
Widget build(BuildContext context) {
  // 1. Escuchar el estado de autenticación de Firebase
  return StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      // El objeto user será null si no hay nadie logueado, o tendrá datos si lo hay.
      final User? user = snapshot.data;
      
      // 2. Definición dinámica del Drawer (Menú Lateral)
      final Drawer appDrawer = Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              // Si hay usuario, muestra su nombre, si no, "Invitado"
              accountName: Text(
                user != null ? user.displayName ?? "Usuario de Servify" : "Invitado",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              // Si hay usuario, muestra su correo, si no, un mensaje de inicio de sesión
              accountEmail: user != null 
                  ? Text(user.email ?? "Correo no disponible") 
                  : const Text("Inicia sesión o regístrate"), 
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: user?.photoURL != null
                    ? ClipOval(child: Image.network(user!.photoURL!))
                    : Text(user != null && user.displayName != null ? user.displayName![0] : "S", style: const TextStyle(fontSize: 40.0)),
              ),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 31, 122, 158),
              ),
            ),
            
            // Opciones de navegación (Servicios, Historial, Perfil)
            ListTile(
              leading: const Icon(Icons.home_repair_service),
              title: const Text('Servicios'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historial'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () {
                // Navegar al perfil o requerir login
                Navigator.pop(context);
                if (user != null) {
                   _onItemTapped(2); // Asumiendo que el índice 2 es el perfil
                } else {
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Debes iniciar sesión para ver tu perfil')),
                   );
                   Navigator.pushNamed(context, 'inicio_usuarios');
                }
              },
            ),
            
            const Divider(),
            
            // Botones condicionales de Sesión
            if (user != null) // Si hay usuario logueado
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar Sesión'),
                onTap: () async {
                  Navigator.pop(context);
                  await FirebaseAuth.instance.signOut(); // 🛑 Cierra la sesión en Firebase
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sesión Cerrada')),
                  );
                },
              )
            else // Si no hay usuario logueado
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

      // Definimos la lista de widgets DENTRO de build
      final List<Widget> widgetOptions = <Widget>[
        _ServicesList(
          navigateToServiceDetail: navigateToServiceDetail,
          services: allServices,
        ),
        const HistoryScreen(),
        // Debes tener una pantalla para el perfil en el índice 2 si lo habilitas
        // const ProfileScreen(), 
      ];

      // 3. Devolver el Scaffold con el Drawer dinámico
      return Scaffold(
        backgroundColor: const Color(0xFF0F3B81),
        appBar: Menu_Bar(
          notificationCount: 5,
          onSearchPressed: () => Navigator.pushNamed(context, '/search'),
          onNotificationPressed: () =>
              Navigator.pushNamed(context, '/notifications'),
          onProfilePressed: () {
            // Navegación condicional desde el AppBar si lo necesitas
            if (user != null) {
              Navigator.pushNamed(context, '/profile');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Inicia sesión para ver tu perfil')),
              );
              Navigator.pushNamed(context, 'inicio_usuarios');
            }
          },
        ),
        drawer: appDrawer, // 👈 Usamos el Drawer dinámico que acabamos de definir
        body: widgetOptions.elementAt(_selectedIndex),
        floatingActionButton: _selectedIndex == 0
            ? FloatingActionButton(
                onPressed: () => navigateToAddService(context),
                child: const Icon(Icons.add),
              )
            : null,
      );
    },
  );
}
}

class _ServicesList extends StatelessWidget {
  final Function(BuildContext, String) navigateToServiceDetail;
  final List<Map<String, String>> services;

  const _ServicesList({
    required this.navigateToServiceDetail,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ...services.map(
          (service) => CardContainer(
            titulo: service['titulo']!,
            categoria: service['categoria']!,
            descripcion: service['descripcion']!,
            onTap: () => navigateToServiceDetail(context, service['titulo']!),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}