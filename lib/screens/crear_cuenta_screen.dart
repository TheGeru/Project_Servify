import 'package:flutter/material.dart';
import 'package:project_servify/services/auth_service.dart';
import 'package:project_servify/widgets/registro_form.dart';
import 'package:project_servify/services/google_services.dart';

enum TipoUsuario { usuario, proveedor }


class CrearCuentaScreen extends StatelessWidget {
  const CrearCuentaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 25, 64, 119),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            children: [
              // Logo circular
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/servify_logo.png',
                    width: 120,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.home_repair_service, size: 80, color: Color(0xFF1A237E)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Card con el formulario
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: RegistroForm(authService: AuthService(), googleService: GoogleAuthServices()), // <-- Aquí usamos el widget separado
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
