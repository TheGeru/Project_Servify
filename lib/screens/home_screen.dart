import 'package:flutter/material.dart';

import 'package:project_servify/screens/history_screen.dart';
import 'package:project_servify/screens/profile_screen.dart';

import 'package:project_servify/screens/service_detail_screen.dart';
import 'package:project_servify/screens/add_service_screen.dart';
import 'package:project_servify/widgets/card_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

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
    const ProfileScreen(),
  ];

  // Función para cambiar el índice al presionar una pestaña
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // El título cambia dinámicamente según la pestaña seleccionada
        title: Text(
          _selectedIndex == 0
              ? 'Servicios'
              : (_selectedIndex == 1 ? 'Historial' : 'Perfil'),
        ),
      ),

      // Muestra el widget de la pestaña seleccionada
      body: _widgetOptions.elementAt(_selectedIndex),

      // El FloatingActionButton solo es visible en la pestaña de Servicios (índice 0)
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => navigateToAddService(context),
              child: const Icon(Icons.add),
            )
          : null, // Ocultar si no es la pestaña de Servicios
      // BottomNavigationBar para la navegación principal
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_repair_service),
            label: 'Servicios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 31, 122, 158),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _ServicesList extends StatelessWidget {
  final Function(BuildContext, String) navigateToServiceDetail;

  const _ServicesList({required this.navigateToServiceDetail});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        CardContainer(
          titulo: 'Carpintería',
          categoria: 'Servicios',
          descripcion: 'Ofrecemos servicios de carpintería a medida.',
          onTap: () => navigateToServiceDetail(context, 'Carpintería'),
        ),
        CardContainer(
          titulo: 'Plomería',
          categoria: 'Servicios',
          descripcion: 'Reparación y mantenimiento de sistemas de plomería.',
          onTap: () => navigateToServiceDetail(context, 'Plomería'),
        ),
        CardContainer(
          titulo: 'Electricidad',
          categoria: 'Servicios',
          descripcion:
              'Instalación y reparación de sistemas eléctricos de tu casa u oficina.',
          onTap: () => navigateToServiceDetail(context, 'Electricidad'),
        ),
        CardContainer(
          titulo: 'Jardinería',
          categoria: 'Servicios',
          descripcion:
              'Mantenimiento y diseño de jardines para tus áreas verdes.',
          onTap: () => navigateToServiceDetail(context, 'Jardinería'),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}
