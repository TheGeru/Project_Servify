// lib/screens/service_detail_screen.dart (Nuevo archivo)

import 'package:flutter/material.dart';

class ServiceDetailScreen extends StatelessWidget {
  final String serviceTitle;

  const ServiceDetailScreen({super.key, required this.serviceTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(serviceTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¡Bienvenido a los detalles de $serviceTitle!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 31, 122, 158),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Aquí vamos a poner más detalles de los servicios seleccionados.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
