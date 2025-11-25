import 'package:flutter/material.dart';
import 'package:project_servify/models/anuncios_model.dart';
import 'package:project_servify/services/offline_service.dart';
import 'package:project_servify/widgets/card_container.dart';
import 'package:project_servify/screens/service_detail_screen.dart';

class OfflineAnunciosScreen extends StatefulWidget {
  const OfflineAnunciosScreen({super.key});

  @override
  State<OfflineAnunciosScreen> createState() => _OfflineAnunciosScreenState();
}

class _OfflineAnunciosScreenState extends State<OfflineAnunciosScreen> {
  final _offlineService = OfflineService();
  List<AnuncioModel> _anuncios = [];
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _loadData();

    // Inicializar estado de red
    _isOnline = _offlineService.isOnline;

    // Escuchar cambios de red para actualizar el banner rojo/verde
    _offlineService.connectivityStream.listen((status) {
      if (mounted) setState(() => _isOnline = status);
    });
  }

  void _loadData() {
    setState(() {
      _anuncios = _offlineService.getCachedAnuncios();
    });
  }

  void _navigateToDetail(AnuncioModel anuncio) {
    // Creamos el mapa de datos que ServiceDetailScreen espera
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mis Descargas'),
        backgroundColor: const Color(0xFF0F3B81),
        foregroundColor: Colors.white,
        actions: [
          if (_anuncios.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Borrar todo',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Borrar todo"),
                    content: const Text(
                      "¿Estás seguro de vaciar tus descargas?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text("Cancelar"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text("Borrar"),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await _offlineService.clearAllCache();
                  _loadData();
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Banner de estado de conexión
          Container(
            width: double.infinity,
            color: _isOnline ? Colors.green.shade600 : Colors.redAccent,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isOnline ? Icons.wifi : Icons.wifi_off,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _isOnline ? "Conectado a Internet" : "Modo Sin Conexión",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Lista
          Expanded(
            child: _anuncios.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.save_alt, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "No tienes anuncios guardados",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Descarga servicios para verlos offline",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    itemCount: _anuncios.length,
                    itemBuilder: (context, index) {
                      final anuncio = _anuncios[index];

                      // Reutilizamos tu Widget AnuncioCard existente
                      return AnuncioCard(
                        anuncio: anuncio,
                        showProviderInfo: true,
                        onTap: () => _navigateToDetail(anuncio),
                        // Eliminación individual
                        onDelete: () async {
                          await _offlineService.removeAnuncioOffline(
                            anuncio.id,
                          );
                          _loadData(); // Recargar lista
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Eliminado"),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
