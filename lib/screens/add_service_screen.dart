import 'package:flutter/material.dart';

class AddServiceScreen extends StatelessWidget {
  const AddServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Nuevo Servicio')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                //aqui es la sintaxis para agregar formulario para la ocpion de agregar servicio
                'Formulario para ingresar un nuevo servicio.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 31, 122, 158),
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Aquí se añadirán campos para el título, descripción, etc, luego lo podemos borrar este texto de marcador de posición.',
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
