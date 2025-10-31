import 'package:flutter/material.dart';

class RegistroProveedorScreen extends StatefulWidget {
  const RegistroProveedorScreen({super.key});

  @override
  State<RegistroProveedorScreen> createState() => _RegistroProveedorScreenState();
}

class _RegistroProveedorScreenState extends State<RegistroProveedorScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _acceptedTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  List<String> _oficiosSeleccionados = [];

  final List<String> _oficios = [
    'Electricista',
    'Plomero',
    'Albañil',
    'Pintor',
  ];


  void _registerProvider() {
    if (_formKey.currentState!.validate() && _acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proveedor registrado correctamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F3B81),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              'crear_cuenta',
              (route) => false,
            );
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'REGISTRO',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(labelText: 'NOMBRE COMPLETO'),
                      validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
                    ),
                    TextFormField(
                      controller: _correoController,
                      decoration: const InputDecoration(labelText: 'CORREO'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => !v!.contains('@') ? 'Correo inválido' : null,
                    ),
                    TextFormField(
                      controller: _telefonoController,
                      decoration: const InputDecoration(labelText: 'TELÉFONO'),
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.length < 10 ? 'Teléfono inválido' : null,
                    ),

                    // Selector múltiple de oficios
                    DropdownButtonFormField<String>(
                      items: _oficios.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      decoration: const InputDecoration(labelText: 'OFICIOS'),
                      onChanged: (value) {
                        if (value != null && !_oficiosSeleccionados.contains(value)) {
                          setState(() => _oficiosSeleccionados.add(value));
                        }
                      },
                    ),
                    Wrap(
                      spacing: 8,
                      children: _oficiosSeleccionados
                          .map((e) => Chip(
                                label: Text(e),
                                onDeleted: () => setState(() => _oficiosSeleccionados.remove(e)),
                              ))
                          .toList(),
                    ),

                    TextFormField(
                      controller: _descripcionController,
                      decoration: const InputDecoration(labelText: 'DESCRIPCIÓN'),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'CONTRASEÑA',
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                    ),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'CONFIRMA CONTRASEÑA',
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      validator: (v) => v != _passwordController.text ? 'No coinciden' : null,
                    ),

                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptedTerms,
                          onChanged: (v) => setState(() => _acceptedTerms = v!),
                        ),
                        const Expanded(
                          child: Text('Acepto Términos y Condiciones'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _acceptedTerms ? _registerProvider : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'REGISTRARME',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
