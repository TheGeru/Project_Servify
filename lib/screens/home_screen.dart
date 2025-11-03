import 'package:flutter/material.dart';

import 'package:project_servify/screens/history_screen.dart';
import 'package:project_servify/screens/profile_screen.dart';
import 'package:project_servify/screens/service_detail_screen.dart';
import 'package:project_servify/screens/add_service_screen.dart';
import 'package:project_servify/widgets/card_container.dart';
import 'package:project_servify/screens/search_screen.dart';
import 'package:project_servify/screens/notifications_screen.dart';
import 'package:project_servify/screens/perfil_proveedor_screen.dart';

import 'package:project_servify/screens/service_detail_screen.dart';
import 'package:project_servify/screens/add_service_screen.dart';
import 'package:project_servify/widgets/card_container.dart';
import 'package:project_servify/widgets/menu_bar.dart';

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
