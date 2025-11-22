import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Screens
import 'package:project_servify/screens/home_screen.dart';
import 'package:project_servify/screens/inicio_usuarios_screen.dart';
import 'package:project_servify/screens/crear_cuenta_screen.dart';
import 'package:project_servify/screens/recuperar_pass_screen.dart';
import 'package:project_servify/screens/notifications_screen.dart';
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
        'notifications': (_) => const NotificationsScreen(),
        'home': (_) => const HomeScreen(),
        'inicio_usuarios': (_) => const InicioUsuariosScreen(),
        'crear_cuenta': (_) => const CrearCuentaScreen(),
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
          backgroundColor: Color.fromARGB(255, 255, 123, 0),
          focusColor: Colors.white,
          foregroundColor: Color.fromARGB(255, 255, 255, 255),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            side: BorderSide(
              color: Color.fromARGB(255, 255, 124, 1),
              width: 1.5,
            ),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
