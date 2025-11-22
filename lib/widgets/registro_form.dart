import 'package:flutter/material.dart';
import 'package:project_servify/services/auth_service.dart';
import 'package:project_servify/services/google_services.dart';

class RegistroForm extends StatefulWidget {
  final AuthService authService;
  final GoogleAuthServices googleService;

  const RegistroForm({
    super.key,
    required this.authService,
    required this.googleService,
  });

  @override
  State<RegistroForm> createState() => _RegistroFormState();
}

class _RegistroFormState extends State<RegistroForm> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _acceptedTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar Términos')),
      );
      return;
    }

    try {
      setState(() => _loading = true);

      await widget.authService.registerWithEmail(
        email: _correoController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nombreController.text.trim(),
        lastName: _apellidosController.text.trim(),
        phone: _telefonoController.text.trim(),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _registerGoogle() async {
    try {
      final credential = await widget.googleService.singInWithGoogle();
      if (credential.user == null) return;

      await widget.authService.saveGoogleUser(credential.user!);

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Text("REGISTRO", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          TextFormField(
            controller: _nombreController,
            decoration: const InputDecoration(labelText: 'NOMBRE'),
            validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
          ),
          const SizedBox(height: 10),

          TextFormField(
            controller: _apellidosController,
            decoration: const InputDecoration(labelText: 'APELLIDOS'),
            validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
          ),
          const SizedBox(height: 10),

          TextFormField(
            controller: _correoController,
            decoration: const InputDecoration(labelText: 'CORREO'),
            validator: (v) => !v!.contains('@') ? 'Correo inválido' : null,
          ),
          const SizedBox(height: 10),

          TextFormField(
            controller: _telefonoController,
            decoration: const InputDecoration(labelText: 'TELÉFONO'),
            validator: (v) => v!.length < 10 ? 'Número inválido' : null,
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
            validator: (v) => v!.length < 6 ? 'Min. 6 caracteres' : null,
          ),
          const SizedBox(height: 10),

          TextFormField(
            controller: _confirmController,
            obscureText: _obscureConfirm,
            decoration: InputDecoration(
              labelText: 'CONFIRMAR CONTRASEÑA',
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (v) => v != _passwordController.text ? 'No coincide' : null,
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Checkbox(
                value: _acceptedTerms,
                onChanged: (v) => setState(() => _acceptedTerms = v!),
              ),
              const Text("Acepto Términos y Condiciones"),
            ],
          ),
          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: _loading ? null : _register,
            child: const Text("REGISTRARME"),
          ),
          const SizedBox(height: 10),

          GestureDetector(
            onTap: _registerGoogle,
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: const Center(
                child: Text("Registrarme con Google"),
              ),
            ),
          )
        ],
      ),
    );
  }
}
