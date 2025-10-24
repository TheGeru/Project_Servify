import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:project_servify/widgets/card_container.dart';

class HomeScreem extends StatelessWidget {
  const HomeScreem({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Servify')),
      body: ListView(
        children: const [
          CardContainer(
            titulo: 'Carpintería',
            categoria: 'Servicios',
            descripcion: 'Ofrecemos servicios de carpintería a medida.',
          ),

          CardContainer(
            titulo: 'Plomería',
            categoria: 'Servicios',
            descripcion: 'Reparación y mantenimiento de sistemas de plomería.',
          ),

          CardContainer(
            titulo: 'Electricidad',
            categoria: 'Servicios',
            descripcion:
                'Instalación y reparación de sistemas eléctricos de tu casa u oficina.',
          ),

          CardContainer(
            titulo: 'Jardinería',
            categoria: 'Servicios',
            descripcion:
                'Mantenimiento y diseño de jardines para tus áreas verdes.',
          ),
        ],
      ),
    );
  }
}
