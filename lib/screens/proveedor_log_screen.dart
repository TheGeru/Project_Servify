import 'package:flutter/material.dart';
import 'package:project_servify/widgets/login_widget.dart';
import 'package:project_servify/screens/recuperar_pass_screen.dart';

class ProveedorLogScreen extends StatelessWidget {
  const ProveedorLogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginWidget(
        userType: UserType.proveedor,
        primaryColor: const Color(0xFF0F172A),
        buttonColor: const Color(0xFF10B981),
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
              builder: (context) => const RecuperarPassScreen(),
            ),
          );
        },
      ),
    );
  }
}