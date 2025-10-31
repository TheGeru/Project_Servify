import 'package:flutter/material.dart';
import 'package:project_servify/screens/home_screen.dart';
import 'package:project_servify/widgets/login_widget.dart';
import 'package:project_servify/screens/recuperar_pass_screen.dart';

class InicioSesionUsuario extends StatelessWidget {
  const InicioSesionUsuario({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F3B81), // Azul oscuro
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Volver a la pantalla principal
            Navigator.pushNamedAndRemoveUntil(context, 'inicio_usuarios', (route) => false);
          },
        ),
      ),
      body: LoginWidget(
        userType: UserType.usuario,
        onLogin: (email, password, userType) async {
          // Simular autenticación
          await Future.delayed(const Duration(seconds: 2));
          
          // Aquí harías tu llamada al backend
          // final response = await AuthService.login(email, password, userType);
        },
        onForgotPassword: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        },
      ),
    );
  }
}