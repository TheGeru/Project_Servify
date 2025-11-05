import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project_servify/screens/perfil_usuario_screen.dart';
import 'firebase_options.dart';

// Screens
import 'package:project_servify/screens/home_screen.dart';
import 'package:project_servify/screens/inicio_usuarios_screen.dart';
import 'package:project_servify/screens/crear_cuenta_screen.dart';
import 'package:project_servify/screens/recuperar_pass_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        'perfil': (_) => const PerfilUsuarioScreen(),
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
