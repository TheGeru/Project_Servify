import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final TextEditingController descriptionController = TextEditingController();

  List<String> allSkills = [
    "Electricista",
    "Plomero",
    "Carpintero",
    "Albañil",
    "Jardinero",
    "Programador",
    "Cerrajero",
    "Pintor",
  ];

  List<String> selectedSkills = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Convertirse en proveedor")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Descripcion del Servidor"),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            const Text("Selecciona tus oficios"),

            Wrap(
              spacing: 8,
              children: allSkills.map((skill) {
                final isSelected = selectedSkills.contains(skill);
                return ChoiceChip(
                  label: Text(skill),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      if (isSelected) {
                        selectedSkills.remove(skill);
                      } else {
                        selectedSkills.add(skill);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: saveProviderData,
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveProviderData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
      "tipo": "provider",
      "descripcion": descriptionController.text.trim(),
      "oficios": selectedSkills,
    });
    Navigator.pop(context);
  }
}
