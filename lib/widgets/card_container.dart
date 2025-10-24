import 'package:flutter/material.dart';

class CardContainer extends StatelessWidget {
  final String titulo;
  final String categoria;
  final String descripcion;
  final VoidCallback onTap;

  const CardContainer({
    super.key,
    required this.titulo,
    required this.categoria,
    required this.descripcion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          onTap: onTap, // esta creo llama la funcion de interaccion al tocar
          //corriganme si estoy mal
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  categoria,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text(descripcion, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
