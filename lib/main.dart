import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';

// Screens
import 'package:project_servify/screens/home_screen.dart';
import 'package:project_servify/screens/inicio_usuarios_screen.dart';
import 'package:project_servify/screens/crear_cuenta_screen.dart';
import 'package:project_servify/screens/recuperar_pass_screen.dart';
import 'package:project_servify/screens/notifications_screen.dart';
import 'package:project_servify/screens/offline_anuncios_screen.dart';
import 'package:project_servify/services/offline_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Notificación en segundo plano recibida: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. Inicializar Hive (Base de datos local)
  await Hive.initFlutter();

  // 3. Abrir la caja (box) donde se guardarán los anuncios
  // Esto crea el archivo físico en el celular/navegador
  await Hive.openBox('anuncios_offline');

  // 4. Inicializar servicio de conectividad (Singleton)
  await OfflineService().initialize();

  // 5. Registrar notificaciones en background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();

    // Escuchar notificaciones en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notificación en primer plano: ${message.notification?.title}');
      if (message.notification != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${message.notification!.title}: ${message.notification!.body}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    });
  }

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
        'offline_anuncios': (_) => const OfflineAnunciosScreen(), // Nueva Ruta
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
