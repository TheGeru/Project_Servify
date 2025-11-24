// lib/screens/offline_anuncios_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
  List<AnuncioModel> _cachedAnuncios = [];
  bool _isLoading = true;
  String _cacheSize = '0 MB';
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    
    if (kIsWeb) {
      _loadCachedAnuncios();
      _loadCacheSize();
      _listenToConnectivity();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCachedAnuncios() async {
    setState(() => _isLoading = true);
    
    try {
      final anuncios = await _offlineService.getCachedAnuncios();
      if (mounted) {
        setState(() {
          _cachedAnuncios = anuncios;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando anuncios: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadCacheSize() async {
    final size = await _offlineService.getCacheSize();
    if (mounted) {
      setState(() => _cacheSize = size);
    }
  }

  void _listenToConnectivity() {
    _isOnline = _offlineService.isOnline;
    
    _offlineService.connectivityStream.listen((isOnline) {
      if (mounted) {
        setState(() => _isOnline = isOnline);
      }
    });
  }

  Future<void> _clearCache() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ Limpiar Caché'),
        content: const Text(
          '¿Estás seguro de eliminar todos los anuncios guardados para modo offline?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar Todo'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _offlineService.clearAllCache();
      await _loadCachedAnuncios();
      await _loadCacheSize();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Caché eliminado'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToDetail(AnuncioModel anuncio) {
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
    // Mostrar mensaje si no es Web
    if (!kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Modo Offline'),
          backgroundColor: const Color(0xFF0F3B81),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_off,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 24),
                Text(
                  'Modo Offline no disponible',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Esta funcionalidad solo está disponible en la versión Web (PWA)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Anuncios Guardados Offline'),
        backgroundColor: const Color(0xFF0F3B81),
        foregroundColor: Colors.white,
        actions: [
          if (_cachedAnuncios.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearCache,
              tooltip: 'Limpiar todo el caché',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadCachedAnuncios();
              _loadCacheSize();
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner de estado de conexión
          _buildConnectionBanner(),
          
          // Info del caché
          _buildCacheInfo(),
          
          // Lista de anuncios
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _cachedAnuncios.isEmpty
                    ? _buildEmptyState()
                    : _buildAnunciosList(),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: _isOnline ? Colors.green.shade100 : Colors.orange.shade100,
      child: Row(
        children: [
          Icon(
            _isOnline ? Icons.wifi : Icons.wifi_off,
            color: _isOnline ? Colors.green.shade800 : Colors.orange.shade800,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _isOnline 
                ? '🟢 Conectado a internet' 
                : '🔴 Sin conexión - Modo offline activo',
            style: TextStyle(
              color: _isOnline ? Colors.green.shade800 : Colors.orange.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCacheInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Anuncios guardados',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_cachedAnuncios.length}',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Espacio usado',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _cacheSize,
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No hay anuncios guardados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Guarda anuncios desde la pantalla principal para verlos sin conexión',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.home),
              label: const Text('IR A INICIO'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F3B81),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnunciosList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _cachedAnuncios.length,
      itemBuilder: (context, index) {
        final anuncio = _cachedAnuncios[index];
        
        return AnuncioCard(
          anuncio: anuncio,
          onTap: () => _navigateToDetail(anuncio),
          showProviderInfo: true,
        );
      },
    );
  }
}
