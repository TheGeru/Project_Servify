import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:project_servify/screens/history_screen.dart';
import 'package:project_servify/screens/perfil_usuario_screen.dart';
import 'package:project_servify/screens/service_detail_screen.dart';
import 'package:project_servify/screens/add_service_screen.dart';
import 'package:project_servify/screens/edit_service_screen.dart';
import 'package:project_servify/screens/search_screen.dart';
import 'package:project_servify/screens/notifications_screen.dart';
import 'package:project_servify/models/usuarios_model.dart';
import 'package:project_servify/models/anuncios_model.dart';
import 'package:project_servify/services/anuncios_service.dart';
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
  final _anunciosService = AnunciosService();

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
    if (state == AppLifecycleState.resumed) {
      if (_selectedIndex > 2) {
        setState(() => _selectedIndex = 0);
      }
    }
  }

  void _onItemTapped(int index) {
    final normalizedIndex = index.clamp(0, 2);
    
    if (_selectedIndex == normalizedIndex) {
      return;
    }
    
    setState(() {
      _selectedIndex = normalizedIndex;
    });
  }

  void navigateToServiceDetail(BuildContext context, AnuncioModel anuncio) {
    // Convertir AnuncioModel a ServiceData para compatibilidad
    final serviceData = {
      'titulo': anuncio.titulo,
      'descripcion': anuncio.descripcion,
      'precio': anuncio.precio,
      'categoria': anuncio.categoria ?? 'Servicios',
      'descripcion_completa': anuncio.descripcion,
      'proveedor_id': anuncio.proveedorId,
      'imagenes': anuncio.imagenes,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailScreen(serviceData: serviceData),
      ),
    );
  }

  void navigateToAddService(BuildContext context) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para publicar un servicio.'),
        ),
      );
      Navigator.pushNamed(context, 'inicio_usuarios');
    } else {
      // Navegar y esperar resultado
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddServiceScreen()),
      );
      
      // Si se creó un anuncio, refrescar la vista
      if (result == true && mounted) {
        setState(() {}); // Forzar rebuild para actualizar el stream
      }
    }
  }

  void navigateToSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(
          navigateToServiceDetail: navigateToServiceDetail,
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

  List<Widget> _buildWidgetOptions(UsuarioModel? userModel) {
    return [
      // Vista principal con anuncios dinámicos
      _AnunciosList(
        anunciosService: _anunciosService,
        navigateToServiceDetail: navigateToServiceDetail,
        userModel: userModel,
      ),
      // Historial
      const HistoryScreen(),
      // Perfil
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

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _selectedIndex > 2) {
            setState(() => _selectedIndex = 0);
          }
        });

        if (firebaseUser == null) {
          final widgetOptions = _buildWidgetOptions(null);
          final safeIndex = _selectedIndex.clamp(0, widgetOptions.length - 1);

          return HomeView(
            user: null,
            userModel: null,
            allServices: const [], // Ya no se usa
            selectedIndex: safeIndex,
            widgetOptions: widgetOptions,
            onItemTapped: _onItemTapped,
            navigateToSearch: navigateToSearch,
            navigateToAddService: navigateToAddService,
            navigateToNotifications: navigateToNotifications,
            navigateToServiceDetail: (ctx, data) {}, // No se usa más
          );
        }

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
              return Scaffold(
                backgroundColor: const Color.fromARGB(255, 25, 64, 119),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 80, color: Colors.white54),
                      const SizedBox(height: 20),
                      const Text(
                        "No se encontraron datos del usuario.\nEs posible que la cuenta haya sido eliminada.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 30),
                      
                      ElevatedButton.icon(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color.fromARGB(255, 25, 64, 119),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text("CERRAR SESIÓN Y SALIR"),
                      ),
                    ],
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
              allServices: const [], // Ya no se usa
              selectedIndex: safeIndex,
              widgetOptions: widgetOptions,
              onItemTapped: _onItemTapped,
              navigateToSearch: navigateToSearch,
              navigateToAddService: navigateToAddService,
              navigateToNotifications: navigateToNotifications,
              navigateToServiceDetail: (ctx, data) {}, // No se usa más
            );
          },
        );
      },
    );
  }
}

// Widget para mostrar lista de anuncios
class _AnunciosList extends StatelessWidget {
  final AnunciosService anunciosService;
  final Function(BuildContext, AnuncioModel) navigateToServiceDetail;
  final UsuarioModel? userModel;

  const _AnunciosList({
    required this.anunciosService,
    required this.navigateToServiceDetail,
    this.userModel,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AnuncioModel>>(
      stream: anunciosService.getAllAnuncios(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar servicios: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final anuncios = snapshot.data ?? [];

        if (anuncios.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No hay servicios publicados aún',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                if (userModel?.tipo == 'provider') ...[
                  const SizedBox(height: 16),
                  const Text(
                    '¡Sé el primero en publicar un servicio!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 10, bottom: 80),
          itemCount: anuncios.length,
          itemBuilder: (context, index) {
            final anuncio = anuncios[index];
            final isOwner = userModel?.uid == anuncio.proveedorId;

            return AnuncioCard(
              anuncio: anuncio,
              onTap: () => navigateToServiceDetail(context, anuncio),
              showProviderInfo: !isOwner,
              onEdit: isOwner
                  ? () async {
                      // Navegar a pantalla de edición
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditServiceScreen(anuncio: anuncio),
                        ),
                      );
                      // Si se editó, refrescar
                      if (result == true && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vista actualizada'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    }
                  : null,
              onDelete: isOwner
                  ? () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Eliminar Anuncio'),
                          content: const Text(
                            '¿Estás seguro de eliminar este anuncio?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        try {
                          await anunciosService.deleteAnuncio(
                            anuncio.id,
                            anuncio.proveedorId,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Anuncio eliminado'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  : null,
            );
          },
        );
      },
    );
  }
}
