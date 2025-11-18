import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:project_servify/screens/history_screen.dart';
import 'package:project_servify/screens/perfil_usuario_screen.dart';
import 'package:project_servify/screens/service_detail_screen.dart';
import 'package:project_servify/screens/add_service_screen.dart';
import 'package:project_servify/screens/search_screen.dart';
import 'package:project_servify/screens/notifications_screen.dart';
import 'package:project_servify/screens/perfil_proveedor_screen.dart';
import 'package:project_servify/models/usuarios_model.dart';
// Importamos la vista (el diseño)
import 'package:project_servify/widgets/home_view.dart';
import 'package:project_servify/widgets/card_container.dart';

typedef ServiceData = Map<String, dynamic>;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- 1. PROPIEDADES (ESTADO Y DATOS) ---
  int _selectedIndex = 0;
  final List<Map<String, String>> allServices = const [
    {
      'titulo': 'Carpintería',
      'categoria': 'Servicios',
      'descripcion': 'Ofrecemos servicios de carpintería a medida.',
    },
    {
      'titulo': 'Plomería',
      'categoria': 'Servicios',
      'descripcion': 'Reparación y mantenimiento de sistemas de plomería.',
    },
    {
      'titulo': 'Electricidad',
      'categoria': 'Servicios',
      'descripcion':
          'Instalación y reparación de sistemas eléctricos de tu casa u oficina.',
    },
    {
      'titulo': 'Jardinería',
      'categoria': 'Servicios',
      'descripcion':
          'Mantenimiento y diseño de jardines para tus áreas verdes.',
    },
    {
      'titulo': 'Plomería Urgente',
      'categoria': 'Servicios',
      'descripcion': 'Mantenimiento y diseño de tus tuberías de tu casa.',
    },
  ];

  // --- 2. MÉTODOS Y FUNCIONES (LÓGICA) ---

  void _onItemTapped(int index) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final maxIndex = currentUser != null ? 2 : 2;

    if (index > maxIndex) {
      index = 0;
    }

    setState(() {
      _selectedIndex = index;
      if (index != 0) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    });
  }

  void navigateToServiceDetail(BuildContext context, ServiceData serviceData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailScreen(serviceData: serviceData),
      ),
    );
  }

  void navigateToAddService(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para publicar un servicio.'),
        ),
      );
      Navigator.pushNamed(context, 'inicio_usuarios');
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddServiceScreen()),
      );
    }
  }

  void navigateToSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(
          // Convertir la lista a Map<String, String> para compatibilidad de SearchScreen
          allServices: allServices
              .map((s) => s.map((k, v) => MapEntry(k, v.toString())))
              .toList(),
          navigateToServiceDetail: (ctx, title) {
            final service = allServices.firstWhere((s) => s['titulo'] == title);
            navigateToServiceDetail(ctx, service);
          },
        ),
      ),
    );
  }

  void navigateToNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
  }

  // --- 3. CONSTRUCCIÓN (STREAM BUILDER) ---

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final firebaseUser = snapshot.data;

        if (firebaseUser == null && _selectedIndex > 2) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _selectedIndex = 0);
              }
            });
          }
        // Si NO hay usuario autenticado → Home sin datos
        if (firebaseUser == null) {
          return HomeView(
            user: null,
            userModel: null,
            allServices: allServices,
            selectedIndex: _selectedIndex.clamp(0, 2),
            widgetOptions: [
              _ServicesList(
                navigateToServiceDetail: navigateToServiceDetail,
                services: allServices,
              ),
              SearchScreen(
                allServices: allServices,
                navigateToServiceDetail: (ctx, title) {
                  final service = allServices.firstWhere(
                    (s) => s['titulo'] == title,
                  );
                  navigateToServiceDetail(ctx, service);
                },
              ),
              PerfilUsuarioScreen(
                //podria mejorarse, segun no es la mejor opcion pero
                //por tiempo es como lo pude arreglar
                userModel: UsuarioModel(
                  uid: '',
                  nombre: 'Invitado',
                  apellidos: '',
                  email: '',
                  telefono: '',
                  tipo: 'user',
                ),
              ),
            ],
              onItemTapped: _onItemTapped,
              navigateToSearch: navigateToSearch,
              navigateToAddService: navigateToAddService,
              navigateToNotifications: navigateToNotifications,
              navigateToServiceDetail: navigateToServiceDetail,
          );
        }

        // SI hay usuario → Escuchar Firestore
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const Center(
                child: Text("Error cargando datos del usuario"),
              );
            }

            // Aquí usamos el snapshot correcto (userSnapshot)
            final data = userSnapshot.data!.data()!;
            final usuarioModel = UsuarioModel.fromMap(data);

            return HomeView(
              user: firebaseUser,
              userModel: usuarioModel,
              allServices: allServices,
              selectedIndex: _selectedIndex.clamp(0, 2),
              widgetOptions: [
                _ServicesList(
                  navigateToServiceDetail: navigateToServiceDetail,
                  services: allServices,
                ),
                SearchScreen(
                  allServices: allServices,
                  navigateToServiceDetail: (ctx, title) {
                    final service = allServices.firstWhere(
                      (s) => s['titulo'] == title,
                    );
                    navigateToServiceDetail(ctx, service);
                  },
                ),
                PerfilUsuarioScreen(userModel: usuarioModel),
              ],
                onItemTapped: _onItemTapped,
                navigateToSearch: navigateToSearch,
                navigateToAddService: navigateToAddService,
                navigateToNotifications: navigateToNotifications,
                navigateToServiceDetail: navigateToServiceDetail,
            );
          },
        );
      },
    );
  }
}

// Mantenemos _ServicesList aquí, o puedes moverlo también si lo deseas.
class _ServicesList extends StatelessWidget {
  final Function(BuildContext, ServiceData) navigateToServiceDetail;
  final List<Map<String, String>> services;

  const _ServicesList({
    required this.navigateToServiceDetail,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ...services.map(
          (service) => CardContainer(
            titulo: service['titulo']!,
            categoria: service['categoria']!,
            descripcion: service['descripcion']!,
            onTap: () {
              navigateToServiceDetail(context, service);
            },
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}
