import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

//import 'package:project_servify/screens/history_screen.dart';
import 'package:project_servify/screens/perfil_usuario_screen.dart';
import 'package:project_servify/screens/service_detail_screen.dart';
import 'package:project_servify/screens/add_service_screen.dart';
import 'package:project_servify/screens/search_screen.dart';
import 'package:project_servify/screens/notifications_screen.dart';
//import 'package:project_servify/screens/perfil_proveedor_screen.dart';
import 'package:project_servify/models/usuarios_model.dart';
import 'package:project_servify/widgets/home_view.dart';
import 'package:project_servify/widgets/card_container.dart';

typedef ServiceData = Map<String, dynamic>;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // CORRECCIÓN: Resetear índice cuando la app vuelve al foreground
    if (state == AppLifecycleState.resumed) {
      if (_selectedIndex > 2) {
        setState(() => _selectedIndex = 0);
      }
    }
  }

  void _onItemTapped(int index) {
    // CORRECCIÓN: Validar y normalizar el índice
    final normalizedIndex = index.clamp(0, 2);
    
    if (_selectedIndex == normalizedIndex) {
      return; // Ya estamos en esa pestaña
    }
    
    setState(() {
      _selectedIndex = normalizedIndex;
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

  // CORRECCIÓN: Método helper para crear widgets de forma consistente
  List<Widget> _buildWidgetOptions(UsuarioModel? userModel) {
    return [
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
        userModel: userModel ?? UsuarioModel(
          uid: '',
          nombre: 'Invitado',
          apellidos: '',
          email: '',
          telefono: '',
          tipo: 'user',
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final firebaseUser = snapshot.data;

        // CORRECCIÓN: Validar índice cuando cambia la autenticación
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _selectedIndex > 2) {
            setState(() => _selectedIndex = 0);
          }
        });

        // Usuario no autenticado
        if (firebaseUser == null) {
          final widgetOptions = _buildWidgetOptions(null);
          final safeIndex = _selectedIndex.clamp(0, widgetOptions.length - 1);

          return HomeView(
            user: null,
            userModel: null,
            allServices: allServices,
            selectedIndex: safeIndex,
            widgetOptions: widgetOptions,
            onItemTapped: _onItemTapped,
            navigateToSearch: navigateToSearch,
            navigateToAddService: navigateToAddService,
            navigateToNotifications: navigateToNotifications,
            navigateToServiceDetail: navigateToServiceDetail,
          );
        }

        // Usuario autenticado - Escuchar Firestore
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Color.fromARGB(255, 25, 64, 119),
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const Scaffold(
                backgroundColor: Color.fromARGB(255, 25, 64, 119),
                body: Center(
                  child: Text(
                    "Error cargando datos del usuario",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }

            final data = userSnapshot.data!.data()!;
            final usuarioModel = UsuarioModel.fromMap(data);

            final widgetOptions = _buildWidgetOptions(usuarioModel);
            final safeIndex = _selectedIndex.clamp(0, widgetOptions.length - 1);

            return HomeView(
              user: firebaseUser,
              userModel: usuarioModel,
              allServices: allServices,
              selectedIndex: safeIndex,
              widgetOptions: widgetOptions,
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
