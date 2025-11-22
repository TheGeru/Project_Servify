import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_servify/services/profile_service.dart'; // Servicio para el upgrade
import 'package:project_servify/models/usuarios_model.dart'; // UserRole y AppUser

class UpgradeToProviderScreen extends StatefulWidget {
  const UpgradeToProviderScreen({super.key});

  @override
  State<UpgradeToProviderScreen> createState() =>
      _UpgradeToProviderScreenState();
}

class _UpgradeToProviderScreenState extends State<UpgradeToProviderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = ProfileService();

  // Controladores de campos
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Datos de estado
  String _occupation = 'Electricista';
  bool _isLoading = false;
  bool _isDataLoading = true; // Nuevo estado para la carga inicial de perfil

  final List<String> _availableOccupations = const [
    'Electricista',
    'Plomero',
    'Cerrajero',
    'Jardinero',
    'Carpintero',
    'Albañil',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  // --- FUNCIÓN CLAVE: CARGA DEL PERFIL EXISTENTE ---
  Future<void> _loadExistingProfile() async {
    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      setState(() => _isDataLoading = false);
      return;
    }

    try {
      // 1. Intentar obtener el documento de Firestore para pre-llenar los datos.
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        final existingUser = UsuarioModel.fromMap(data);

        // 2. Pre-llenar campos con datos existentes
        _phoneController.text = existingUser.telefono;
        _descriptionController.text = existingUser.descripcion ?? '';

        // 3. Establecer el oficio actual si existe
        if (existingUser.oficios != null && existingUser.oficios!.isNotEmpty) {
          final oficioGuardado = existingUser.oficios!.first;

          if(_availableOccupations.contains(oficioGuardado))
          _occupation = oficioGuardado;
        }
      }
    } catch (e) {
      debugPrint('Error al cargar perfil existente: $e');
    } finally {
      setState(() => _isDataLoading = false);
    }
  }
  // --- FIN DE LA CARGA DE PERFIL ---

  @override
  void dispose() {
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Lógica para actualizar/crear el documento de proveedor en Firestore
  Future<void> _upgrade() async {
    if (!_formKey.currentState!.validate()) return;

    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Debe iniciar sesión.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Llamar al ProfileService para actualizar/crear el documento
      await _profileService.upgradeToProvider(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? 'no-email@servify.com',
        displayName: firebaseUser.displayName,
        phone: _phoneController.text.trim(),
        occupation: _occupation,
        description: _descriptionController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Perfil de Proveedor actualizado con éxito."),
          ),
        );

        // 2. Navegar de vuelta al Home (que forzará la recarga del estado)
        Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al actualizar perfil: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDataLoading) {
      return const Scaffold(
        appBar: null,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Convertirse/Actualizar Proveedor'),
        backgroundColor: const Color(0xFFFF6B35), // Color Proveedor
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Paso Final: Configura tu Perfil Profesional',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const Divider(height: 30),

                  // Campo 1: Oficio
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Tu Oficio Principal',
                      prefixIcon: Icon(Icons.work, color: Color(0xFFFF6B35)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    value: _occupation,
                    items: _availableOccupations.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() => _occupation = newValue);
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Campo 2: Teléfono
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono de Contacto',
                      prefixIcon: Icon(Icons.phone, color: Color(0xFFFF6B35)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 10) {
                        return 'Ingresa un teléfono válido de 10 dígitos.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Campo 3: Descripción
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Describe tus Servicios y Experiencia',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(
                        Icons.description,
                        color: Color(0xFFFF6B35),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Necesitas una descripción de tus servicios.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Botón de Upgrade
                  ElevatedButton(
                    onPressed: _isLoading ? null : _upgrade,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'GUARDAR PERFIL DE PROVEEDOR',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
