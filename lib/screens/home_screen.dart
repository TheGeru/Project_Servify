import 'package:flutter/material.dart';
<<<<<<< Updated upstream
=======
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_servify/services/auth_service.dart'; // Importar AuthService
>>>>>>> Stashed changes

import 'package:project_servify/screens/history_screen.dart';
import 'package:project_servify/screens/profile_screen.dart';
import 'package:project_servify/screens/service_detail_screen.dart';
import 'package:project_servify/screens/add_service_screen.dart';
import 'package:project_servify/widgets/card_container.dart';
import 'package:project_servify/screens/search_screen.dart';
import 'package:project_servify/screens/notifications_screen.dart';
import 'package:project_servify/screens/perfil_proveedor_screen.dart';
<<<<<<< Updated upstream

import 'package:project_servify/screens/service_detail_screen.dart';
import 'package:project_servify/screens/add_service_screen.dart';
import 'package:project_servify/widgets/card_container.dart';
import 'package:project_servify/widgets/menu_bar.dart';
=======
import 'package:project_servify/screens/perfil_usuario_screen.dart';
import 'package:project_servify/widgets/menu_bar.dart'; // Importamos Menu_Bar
import 'package:project_servify/widgets/card_container.dart';

// Type alias para mayor claridad
typedef ServiceData = Map<String, dynamic>;
>>>>>>> Stashed changes

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
<<<<<<< Updated upstream
  final List<Map<String, String>> allServices = const [
=======
  final AuthService _authService = AuthService(); // Instancia de AuthService

  // Datos de prueba ampliados
  final List<ServiceData> allServices = const [
>>>>>>> Stashed changes
    {
      'titulo': 'Carpintería',
      'categoria': 'Servicios',
      'descripcion': 'Ofrecemos servicios de carpintería a medida.',
<<<<<<< Updated upstream
=======
      'proveedor_nombre': 'Muebles de Juan',
      'descripcion_completa':
          'Diseño, fabricación y reparación de muebles de madera, closets, cocinas integrales y trabajos a medida. 10 años de experiencia.',
>>>>>>> Stashed changes
    },
    {
      'titulo': 'Plomería',
      'categoria': 'Servicios',
      'descripcion': 'Reparación y mantenimiento de sistemas de plomería.',
<<<<<<< Updated upstream
=======
      'proveedor_nombre': 'Plomeros Rápido S.A.',
      'descripcion_completa':
          'Expertos en fugas, tuberías rotas, instalación de boilers y mantenimiento general de sistemas de agua. Servicio 24/7.',
>>>>>>> Stashed changes
    },
    {
      'titulo': 'Electricidad',
      'categoria': 'Servicios',
      'descripcion':
          'Instalación y reparación de sistemas eléctricos de tu casa u oficina.',
<<<<<<< Updated upstream
=======
      'proveedor_nombre': 'Electricistas Unidos',
      'descripcion_completa':
          'Servicios eléctricos residenciales e industriales, cortos circuitos, cableado, instalación de luminarias y mufas. Con certificado.',
>>>>>>> Stashed changes
    },
    {
      'titulo': 'Jardinería',
      'categoria': 'Servicios',
      'descripcion':
          'Mantenimiento y diseño de jardines para tus áreas verdes.',
<<<<<<< Updated upstream
=======
      'proveedor_nombre': 'Jardines de Laura',
      'descripcion_completa':
          'Diseño de paisajismo, poda de árboles, mantenimiento de pasto y fertilización. Convierte tu espacio en un oasis.',
>>>>>>> Stashed changes
    },
    {
      'titulo': 'Plomería Urgente',
      'categoria': 'Servicios',
      'descripcion': 'Mantenimiento y diseño de tus tuberías de tu casa.',
<<<<<<< Updated upstream
    },
  ];
  void navigateToServiceDetail(BuildContext context, String title) {
=======
      'proveedor_nombre': 'Plomeros Rápido S.A.',
      'descripcion_completa':
          'Atención inmediata a emergencias de plomería. Fugas graves, desatascos y drenajes. Llegamos en menos de 30 minutos.',
    },
  ];

  // --- 2. MÉTODOS Y FUNCIONES (LÓGICA) ---

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 0) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    });
  }

  void navigateToServiceDetail(BuildContext context, ServiceData serviceData) {
>>>>>>> Stashed changes
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailScreen(serviceData: serviceData),
      ),
    );
  }

  // Verifica autenticación antes de permitir la publicación
  void navigateToAddService(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para publicar un servicio.'),
        ),
      );
      Navigator.pushNamed(context, 'inicio_usuarios');
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddServiceScreen()),
      );
    }
  }

  late final List<Widget> _widgetOptions = <Widget>[
    _ServicesList(navigateToServiceDetail: navigateToServiceDetail),
    //Funcion de navegacion a las nuevas pantallas
    const HistoryScreen(),
    const PerfilProveedorScreen(),
  ];

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
          // Convertir la lista a Map<String, String> para compatibilidad de SearchScreen
          allServices: allServices
              .map((s) => s.map((k, v) => MapEntry(k, v.toString())))
              .toList(),
          navigateToServiceDetail: (ctx, title) {
            final service = allServices.firstWhere((s) => s['titulo'] == title);
            navigateToServiceDetail(ctx, service);
          },
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

<<<<<<< Updated upstream
  @override
  Widget build(BuildContext context) {
    // Definimos la lista de widgets DENTRO de build para que sea creada solo cuando el contexto es válido
    final List<Widget> widgetOptions = <Widget>[
      _ServicesList(
        // Pasamos la función y la lista aquí.
        navigateToServiceDetail: navigateToServiceDetail,
        services: allServices,
      ),
      const HistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: _CustomAppBar(
          title: _selectedIndex == 0
              ? 'Servicios'
              : (_selectedIndex == 1 ? 'Historial' : 'Perfil'),
          onSearchPressed: () => navigateToSearch(context),
          onNotificationPressed: () => navigateToNotifications(context),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const UserAccountsDrawerHeader(
              accountName: Text(
                "Usuario Actual",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: null,
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text("A", style: TextStyle(fontSize: 40.0)),
              ),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 31, 122, 158),
              ),
            ),
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
                Navigator.pop(context);
                _onItemTapped(2);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sesión Cerrada (Simulación)')),
                );
              },
            ),
          ],
        ),
      backgroundColor: const Color(0xFF0F3B81),
      appBar: Menu_Bar(
        notificationCount: 5,
        onSearchPressed: () => Navigator.pushNamed(context, '/search'),
        onNotificationPressed: () =>
            Navigator.pushNamed(context, '/notifications'),
        onProfilePressed: () => Navigator.pushNamed(context, '/profile'),
      ),
      body: widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => navigateToAddService(context),
              child: const Icon(Icons.add),
            )
          : null,
=======
  // Lógica de navegación del Perfil con verificación de rol
  void navigateToProfile(BuildContext context, User user) async {
    final role = await _authService.getUserRole(user.uid);

    // Navega basado en el rol obtenido
    if (role == 'provider') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PerfilProveedorScreen()),
      );
    } else {
      // Rol 'user' o cualquier otro
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PerfilUsuarioScreen()),
      );
    }
  }

  // --- 3. WIDGETS AUXILIARES DE DISEÑO (DRAWER) ---

  Drawer _buildDrawer(BuildContext context, User? user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              user != null
                  ? user.displayName ?? "Usuario de Servify"
                  : "Invitado",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: user != null
                ? Text(user.email ?? "Correo no disponible")
                : const Text("Inicia sesión o regístrate"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: user?.photoURL != null
                  ? ClipOval(child: Image.network(user!.photoURL!))
                  : Text(
                      user != null && user.displayName != null
                          ? user.displayName![0]
                          : "S",
                      style: const TextStyle(fontSize: 40.0),
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
              Navigator.pop(context);
              if (user != null) {
                navigateToProfile(
                  context,
                  user,
                ); // Usa la función con lógica de rol
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
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Sesión Cerrada')));
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

  // --- 4. CONSTRUCCIÓN DE LA VISTA (WIDGET BUILD) ---

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final User? user = snapshot.data;

        // Contenido de las pestañas
        final List<Widget> widgetOptions = <Widget>[
          _ServicesList(
            navigateToServiceDetail: navigateToServiceDetail,
            services: allServices,
          ),
          const HistoryScreen(),
          const PerfilUsuarioScreen(), // Índice 2 (Perfil por defecto)
        ];

        // Retorna el Scaffold (lo que antes hacía HomeView)
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 25, 64, 119),
          appBar: Menu_Bar(
            isAuthenticated: user != null,
            notificationCount: 5,
            onSearchPressed: () => navigateToSearch(context),
            onNotificationPressed: () => navigateToNotifications(context),
            onProfilePressed: () {
              if (user != null) {
                navigateToProfile(
                  context,
                  user,
                ); // Usa la función con lógica de rol
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Inicia sesión para ver tu perfil'),
                  ),
                );
                Navigator.pushNamed(context, 'inicio_usuarios');
              }
            },
            onLoginPressed: () =>
                Navigator.pushNamed(context, 'inicio_usuarios'),
            onSignUpPressed: () => Navigator.pushNamed(context, 'crear_cuenta'),
          ),
          drawer: _buildDrawer(
            context,
            user,
          ), // Usamos el Drawer integrado aquí
          body: widgetOptions.elementAt(_selectedIndex),

          // Botón flotante condicional (solo en Servicios y fuerza login para publicar)
          floatingActionButton: _selectedIndex == 0
              ? FloatingActionButton(
                  onPressed: () => navigateToAddService(context),
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
>>>>>>> Stashed changes
    );
  }
}

<<<<<<< Updated upstream
=======
// Mantenemos _ServicesList, con el tipo de dato ajustado.
>>>>>>> Stashed changes
class _ServicesList extends StatelessWidget {
  final Function(BuildContext, ServiceData) navigateToServiceDetail;
  final List<ServiceData> services;

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
            onTap: () => navigateToServiceDetail(context, service),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}
<<<<<<< Updated upstream

class _CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onSearchPressed;
  final VoidCallback onNotificationPressed;

  const _CustomAppBar({
    required this.title,
    required this.onSearchPressed,
    required this.onNotificationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      title: Text(title),
      actions: [
        IconButton(icon: const Icon(Icons.search), onPressed: onSearchPressed),
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: onNotificationPressed,
        ),
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            context.findAncestorStateOfType<_HomeScreenState>()?._onItemTapped(
              2,
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
}
=======
>>>>>>> Stashed changes
