import 'package:flutter/material.dart';
import 'package:project_servify/screens/home_screen.dart';

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
      routes: {'home': (_) => const HomeScreen()},
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey[300],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color.fromARGB(255, 31, 122, 158),
          foregroundColor: Colors.white,
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
