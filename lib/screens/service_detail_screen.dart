import 'package:flutter/material.dart';

class ServiceDetailScreen extends StatelessWidget {
  final String serviceTitle;

  const ServiceDetailScreen({super.key, required this.serviceTitle});
  void _onItemTapped(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
    }
  }

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
                'Esta pantalla muestra los detalles del servicio seleccionado.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
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
        currentIndex: 0,
        selectedItemColor: const Color.fromARGB(255, 31, 122, 158),
        unselectedItemColor: Colors.grey,
        onTap: (index) => _onItemTapped(context, index),
      ),
    );
  }
}
