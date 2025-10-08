import 'package:flutter/material.dart';
import 'package:project_servify/screens/home_screem.dart';
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopify',
      initialRoute: 'home',
      routes: {
        'home': (_) => const HomeScreem(),
      },
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey[300],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color.fromARGB(255, 31, 122, 158),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color.fromARGB(255, 31, 122, 158),
          focusColor: Colors.white,
          elevation: 0,
        ),
      ),
    );
  }
}
