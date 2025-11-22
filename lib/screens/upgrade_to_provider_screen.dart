import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_servify/services/profile_service.dart';
import 'package:project_servify/models/usuarios_model.dart';

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
  final List<String> _selectedOccupations = []; // Cambiado a lista para múltiples oficios
  bool _isLoading = false;
  bool _isDataLoading = true;

  final List<String> _availableOccupations = const [
    'Electricista',
    'Plomero',
    'Cerrajero',
    'Jardinero',
    'Carpintero',
    'Albañil',
    'Pintor',
    'Mecánico',
    'Programador',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      setState(() => _isDataLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        final existingUser = UsuarioModel.fromMap(data);

        // Pre-llenar campos con datos existentes
        _phoneController.text = existingUser.telefono;
        _descriptionController.text = existingUser.descripcion ?? '';

        // Cargar oficios existentes
        if (existingUser.oficios != null && existingUser.oficios!.isNotEmpty) {
          setState(() {
            _selectedOccupations.addAll(
              existingUser.oficios!.where(
                (oficio) => _availableOccupations.contains(oficio),
              ),
            );
          });
        }
      }
    } catch (e) {
      debugPrint('Error al cargar perfil existente: $e');
    } finally {
      setState(() => _isDataLoading = false);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _upgrade() async {
    if (!_formKey.currentState!.validate()) return;

    // Validar que haya al menos un oficio seleccionado
    if (_selectedOccupations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Debes seleccionar al menos un oficio."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Debe iniciar sesión.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Actualizar en Firestore directamente con múltiples oficios
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .update({
        'tipo': 'provider',
        'telefono': _phoneController.text.trim(),
        'descripcion': _descriptionController.text.trim(),
        'oficios': _selectedOccupations,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "¡Felicidades! Ahora eres un proveedor de servicios",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Regresar con resultado positivo para forzar recarga
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al actualizar perfil: $e"),
            backgroundColor: Colors.red,
          ),
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Cargando tu información...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Convertirse en Proveedor'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado con ícono
              Card(
                elevation: 3,
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.business_center,
                        size: 64,
                        color: Color(0xFFFF6B35),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Configura tu Perfil Profesional',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Completa la información para ofrecer tus servicios',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Campo: Teléfono
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Teléfono de Contacto',
                  prefixIcon: const Icon(Icons.phone, color: Color(0xFFFF6B35)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El teléfono es obligatorio';
                  }
                  if (value.length < 10) {
                    return 'Ingresa un teléfono válido de al menos 10 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo: Descripción
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Describe tus Servicios y Experiencia',
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(
                    Icons.description,
                    color: Color(0xFFFF6B35),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  hintText: 'Ej: Tengo 5 años de experiencia en electricidad residencial...',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La descripción es obligatoria';
                  }
                  if (value.length < 20) {
                    return 'La descripción debe tener al menos 20 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Sección: Oficios
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.work, color: Color(0xFFFF6B35)),
                          SizedBox(width: 8),
                          Text(
                            'Selecciona tus Oficios',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Puedes seleccionar múltiples oficios',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableOccupations.map((skill) {
                          final isSelected = _selectedOccupations.contains(skill);
                          return FilterChip(
                            label: Text(skill),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                if (isSelected) {
                                  _selectedOccupations.remove(skill);
                                } else {
                                  _selectedOccupations.add(skill);
                                }
                              });
                            },
                            selectedColor: Colors.orange.shade200,
                            checkmarkColor: Colors.orange.shade900,
                            backgroundColor: Colors.grey.shade200,
                          );
                        }).toList(),
                      ),
                      if (_selectedOccupations.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            '${_selectedOccupations.length} oficio(s) seleccionado(s)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Botón de Upgrade
              ElevatedButton(
                onPressed: _isLoading ? null : _upgrade,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
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
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'GUARDAR Y CONVERTIRME EN PROVEEDOR',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),

              // Botón cancelar
              TextButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
