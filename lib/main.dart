import 'package:flutter/material.dart';
import 'package:project_servify/screens/home_screen.dart';
import 'package:project_servify/screens/inicio_usuarios_screen.dart';
import 'package:project_servify/screens/crear_cuenta_screen.dart';
import 'package:project_servify/screens/registro_usuario_screen.dart';
import 'package:project_servify/screens/registro_proveedor_screen.dart';
import 'package:project_servify/screens/inicio_sesion_usuario.dart';
import 'package:project_servify/screens/inicio_sesion_proveedor.dart';
import 'package:project_servify/screens/recuperar_pass_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Servify',
      debugShowCheckedModeBanner: false,
      initialRoute: 'home',
      routes: {
        'home': (_) => const HomeScreen(),
        'inicio_usuarios': (_) => const InicioUsuariosScreen(),
        'crear_cuenta': (_) => const CrearCuentaScreen(),
        'registro_usuario': (_) => const RegistroUsuarioScreen(),
        'registro_proveedor': (_) => const RegistroProveedorScreen(),
        'inicio_sesion_usuario': (_) => const InicioSesionUsuario(),
        'inicio_sesion_proveedor': (_) => const InicioSesionProveedor(),
        'recuperar_pass': (_) => const RecuperarPassScreen(),
      },
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromARGB(255, 31, 122, 158),
          focusColor: Colors.white,
          elevation: 0,
        ),
      ),
    );
  }
}
