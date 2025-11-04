import 'package:flutter/material.dart';
import 'package:project_servify/services/auth_service.dart';

enum TipoUsuario { usuario, proveedor }

class RegistroForm extends StatefulWidget {
  final AuthService authService;

  const RegistroForm({super.key, required this.authService});

  @override
  State<RegistroForm> createState() => _RegistroFormState();
}

class _RegistroFormState extends State<RegistroForm> {
  final _formKey = GlobalKey<FormState>();

  TipoUsuario _tipo = TipoUsuario.usuario;
  bool _acceptedTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  bool _loading = false;
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final List<String> _oficios = ['Electricista', 'Plomero', 'Albañil', 'Pintor'];
  List<String> _oficiosSeleccionados = [];

  // Registro con correo
void _register() async {
  if (_formKey.currentState!.validate() && _acceptedTerms) {
    try {
      // Llama a tu AuthService
      final role = _tipo == TipoUsuario.usuario ? 'user' : 'provider';
      await widget.authService.registerWithEmail(
        email: _correoController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nombreController.text.trim(),
        role: role,
        phone: _telefonoController.text.trim(),
        description: _descripcionController.text.trim(),
        oficios: _oficiosSeleccionados,
      );

      // Registro exitoso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso')),
      );

      // Redirige a home
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar: $e')),
      );
    }
  } else if (!_acceptedTerms) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Debes aceptar Términos y Condiciones')),
    );
  }
}


  // Google Sign-In
  Future<void> _registerWithGoogle() async {
    final role = _tipo == TipoUsuario.usuario ? 'user' : 'provider';

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conectando con Google...')),
    );

    try {
      final user = await widget.authService.signInWithGoogle(role: role);
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro exitoso con Google ✅')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se completó el registro')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Text(
              'REGISTRO',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Registrar como:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),

          // Radios
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _tipo = TipoUsuario.usuario),
                  child: Row(
                    children: [
                      Radio<TipoUsuario>(
                        value: TipoUsuario.usuario,
                        groupValue: _tipo,
                        onChanged: (v) => setState(() => _tipo = v!),
                      ),
                      const SizedBox(width: 4),
                      const Text('Usuario', style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _tipo = TipoUsuario.proveedor),
                  child: Row(
                    children: [
                      Radio<TipoUsuario>(
                        value: TipoUsuario.proveedor,
                        groupValue: _tipo,
                        onChanged: (v) => setState(() => _tipo = v!),
                      ),
                      const SizedBox(width: 4),
                      const Text('Proveedor', style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Campos
          TextFormField(
            controller: _nombreController,
            decoration: const InputDecoration(labelText: 'NOMBRE'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _apellidosController,
            decoration: const InputDecoration(labelText: 'APELLIDOS'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _correoController,
            decoration: const InputDecoration(labelText: 'CORREO'),
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v == null || !v.contains('@') ? 'Correo inválido' : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _telefonoController,
            decoration: const InputDecoration(labelText: 'TELÉFONO'),
            keyboardType: TextInputType.phone,
            validator: (v) => v == null || v.trim().length < 10 ? 'Teléfono inválido' : null,
          ),
          const SizedBox(height: 8),

          if (_tipo == TipoUsuario.proveedor) ...[
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'OFICIO (agrega uno)'),
              items: _oficios.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) {
                if (value != null && !_oficiosSeleccionados.contains(value)) {
                  setState(() => _oficiosSeleccionados.add(value));
                }
              },
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _oficiosSeleccionados
                  .map((e) => Chip(
                        label: Text(e),
                        onDeleted: () => setState(() => _oficiosSeleccionados.remove(e)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: 'DESCRIPCIÓN (opcional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
          ],

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
            validator: (v) => v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
          ),
          const SizedBox(height: 8),
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
              Checkbox(value: _acceptedTerms, onChanged: (v) => setState(() => _acceptedTerms = v!)),
              const Expanded(child: Text('Acepto Términos y Condiciones')),
            ],
          ),
          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: _acceptedTerms ? _register : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('REGISTRARME', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('O continua con'),
              ),
              Expanded(child: Divider()),
            ],
          ),

         GestureDetector(
              onTap: _loading ? null : () async {
                setState(() => _loading = true);
                final role = _tipo == TipoUsuario.usuario ? 'user' : 'provider';

                try {
                  final userCredential = await widget.authService.signInWithGoogle(role: role);

                  if (userCredential != null && userCredential.user != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Registro exitoso con Google')),
                    );
                    // Redirige a home
                    print('Intentando navegar a home...'); // Añade esto
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No se completó el registro')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error Google: $e')),
                  );
                }

                setState(() => _loading = false);
              },
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.g_mobiledata, size: 32),
                    SizedBox(width: 8),
                    Text(
                      "Registrarme con Google",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}
