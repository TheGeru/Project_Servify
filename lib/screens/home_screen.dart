import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:project_servify/screens/history_screen.dart';
import 'package:project_servify/screens/service_detail_screen.dart';
import 'package:project_servify/screens/add_service_screen.dart';
import 'package:project_servify/screens/search_screen.dart';
import 'package:project_servify/screens/notifications_screen.dart';
import 'package:project_servify/screens/perfil_proveedor_screen.dart';

// Importamos la vista (el diseño)
import 'package:project_servify/widgets/home_view.dart'; 
import 'package:project_servify/widgets/card_container.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- 1. PROPIEDADES (ESTADO Y DATOS) ---
  int _selectedIndex = 0;
  final List<Map<String, String>> allServices = const [
    {'titulo': 'Carpintería', 'categoria': 'Servicios', 'descripcion': 'Ofrecemos servicios de carpintería a medida.'},
    {'titulo': 'Plomería', 'categoria': 'Servicios', 'descripcion': 'Reparación y mantenimiento de sistemas de plomería.'},
    {'titulo': 'Electricidad', 'categoria': 'Servicios', 'descripcion': 'Instalación y reparación de sistemas eléctricos de tu casa u oficina.'},
    {'titulo': 'Jardinería', 'categoria': 'Servicios', 'descripcion': 'Mantenimiento y diseño de jardines para tus áreas verdes.'},
    {'titulo': 'Plomería Urgente', 'categoria': 'Servicios', 'descripcion': 'Mantenimiento y diseño de tus tuberías de tu casa.'},
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

  // --- 3. CONSTRUCCIÓN (STREAM BUILDER) ---

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final User? user = snapshot.data;
        
        // La lista de widgets se mantiene aquí ya que depende del estado interno
        final List<Widget> widgetOptions = <Widget>[
          _ServicesList(
            navigateToServiceDetail: navigateToServiceDetail,
            services: allServices,
          ),
          const HistoryScreen(),
          const PerfilProveedorScreen(), // Índice 2
        ];
        
        // Mandamos todos los datos y la lógica al widget de Diseño (HomeView)
        return HomeView(
          user: user,
          allServices: allServices, // Aunque no se usa en la vista principal, es bueno mantenerlo
          selectedIndex: _selectedIndex,
          widgetOptions: widgetOptions,
          // Funciones de navegación
          onItemTapped: _onItemTapped,
          navigateToServiceDetail: navigateToServiceDetail,
          navigateToSearch: navigateToSearch,
          navigateToAddService: navigateToAddService,
          navigateToNotifications: navigateToNotifications,
        );
      },
    );
  }
}

// Mantenemos _ServicesList aquí, o puedes moverlo también si lo deseas.
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