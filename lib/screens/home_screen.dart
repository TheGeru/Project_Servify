import 'package:flutter/material.dart';

import 'package:project_servify/screens/service_detail_screen.dart';
import 'package:project_servify/screens/add_service_screen.dart';
import 'package:project_servify/widgets/card_container.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Servify')),
      body: ListView(
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
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => navigateToAddService(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
