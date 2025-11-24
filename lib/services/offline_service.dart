// lib/services/offline_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import 'package:project_servify/models/anuncios_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  // Stream para escuchar cambios de conectividad
  final _connectivityController = StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityController.stream;

  // Lista de IDs de anuncios guardados offline
  final Set<String> _cachedAnunciosIds = {};
  
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  /// Inicializar el servicio de offline
  Future<void> initialize() async {
    // Solo funciona en Web
    if (!kIsWeb) {
      print('[OfflineService] Solo disponible en Web');
      return;
    }

    // Monitorear conectividad
    Connectivity().onConnectivityChanged.listen((result) {
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;
      
      if (wasOnline != _isOnline) {
        _connectivityController.add(_isOnline);
        print('[OfflineService] Estado de conexión: ${_isOnline ? "ONLINE" : "OFFLINE"}');
      }
    });

    // Verificar estado inicial
    final connectivity = await Connectivity().checkConnectivity();
    _isOnline = connectivity != ConnectivityResult.none;

    // Cargar IDs de anuncios cacheados
    await _loadCachedAnunciosIds();

    print('[OfflineService] Inicializado. Online: $_isOnline');
  }

  /// Guardar anuncio para modo offline
  Future<bool> saveAnuncioOffline(AnuncioModel anuncio) async {
    if (!kIsWeb) return false;

    try {
      // Convertir el anuncio a un Map serializable
      final Map<String, dynamic> anuncioMap = {
        'id': anuncio.id,
        'titulo': anuncio.titulo,
        'descripcion': anuncio.descripcion,
        'precio': anuncio.precio,
        'proveedorId': anuncio.proveedorId,
        'imagenes': anuncio.imagenes,
        'categoria': anuncio.categoria,
        'createdAt': anuncio.createdAt?.toIso8601String(),
      };
      
      // Llamar a la función JavaScript directamente
      await _sendMessageToSW({
        'action': 'CACHE_ANUNCIO',
        'data': anuncioMap,
      });

      _cachedAnunciosIds.add(anuncio.id);
      await _saveCachedIds();

      print('[OfflineService] Anuncio guardado offline: ${anuncio.titulo}');
      return true;
    } catch (e) {
      print('[OfflineService] Error guardando anuncio offline: $e');
      return false;
    }
  }

  /// Eliminar anuncio del modo offline
  Future<bool> removeAnuncioOffline(String anuncioId) async {
    if (!kIsWeb) return false;

    try {
      await _sendMessageToSW({
        'action': 'REMOVE_ANUNCIO',
        'data': {'id': anuncioId},
      });

      _cachedAnunciosIds.remove(anuncioId);
      await _saveCachedIds();

      print('[OfflineService] Anuncio eliminado del modo offline: $anuncioId');
      return true;
    } catch (e) {
      print('[OfflineService] Error eliminando anuncio offline: $e');
      return false;
    }
  }

  /// Verificar si un anuncio está guardado offline
  bool isAnuncioSavedOffline(String anuncioId) {
    return _cachedAnunciosIds.contains(anuncioId);
  }

  /// Obtener todos los anuncios guardados offline
  Future<List<AnuncioModel>> getCachedAnuncios() async {
    if (!kIsWeb) return [];

    try {
      final response = await _sendMessageToSWWithResponse({
        'action': 'GET_CACHED_ANUNCIOS',
      });

      if (response != null && response['anuncios'] != null) {
        final List<dynamic> anunciosData = response['anuncios'];
        return anunciosData.map((data) {
          // Convertir el String de fecha de vuelta a DateTime si existe
          if (data['createdAt'] is String) {
            try {
              data['createdAt'] = DateTime.parse(data['createdAt']);
            } catch (e) {
              data['createdAt'] = null;
            }
          }
          return AnuncioModel.fromMap(data as Map<String, dynamic>);
        }).toList();
      }

      return [];
    } catch (e) {
      print('[OfflineService] Error obteniendo anuncios cacheados: $e');
      return [];
    }
  }

  /// Limpiar todo el caché offline
  Future<void> clearAllCache() async {
    if (!kIsWeb) return;

    try {
      await _sendMessageToSW({'action': 'CLEAR_CACHE'});
      _cachedAnunciosIds.clear();
      await _saveCachedIds();
      
      print('[OfflineService] Todo el caché eliminado');
    } catch (e) {
      print('[OfflineService] Error limpiando caché: $e');
    }
  }

  /// Obtener tamaño estimado del caché
  Future<String> getCacheSize() async {
    if (!kIsWeb) return '0 MB';

    try {
      // Esto es una estimación aproximada
      final cachedAnuncios = await getCachedAnuncios();
      final estimatedSize = cachedAnuncios.length * 0.5; // ~500KB por anuncio
      
      if (estimatedSize < 1) {
        return '${(estimatedSize * 1024).toStringAsFixed(0)} KB';
      }
      return '${estimatedSize.toStringAsFixed(2)} MB';
    } catch (e) {
      return '0 MB';
    }
  }

  // ============================================
  // MÉTODOS PRIVADOS - COMUNICACIÓN CON JS
  // ============================================

  /// Enviar mensaje al Service Worker (sin respuesta)
  Future<void> _sendMessageToSW(Map<String, dynamic> message) async {
    if (!kIsWeb) return;
    
    try {
      final messageJson = jsonEncode(message);
      
      // Llamar función JavaScript directamente con dart:js
      js.context.callMethod('eval', ['''
        if (window.sendMessageToSW) {
          window.sendMessageToSW($messageJson);
        } else {
          console.error('sendMessageToSW no disponible');
        }
      ''']);
      
    } catch (e) {
      print('[OfflineService] Error enviando mensaje: $e');
      rethrow;
    }
  }

  /// Enviar mensaje al Service Worker y esperar respuesta
  Future<Map<String, dynamic>?> _sendMessageToSWWithResponse(
    Map<String, dynamic> message,
  ) async {
    if (!kIsWeb) return null;
    
    try {
      final messageJson = jsonEncode(message);
      
      // Usar Completer para esperar la respuesta de la Promise
      final completer = Completer<Map<String, dynamic>?>();
      
      // Crear callback único
      final callbackName = 'swCallback_${DateTime.now().millisecondsSinceEpoch}';
      
      // Registrar callback en window
      js.context[callbackName] = js.allowInterop((dynamic result) {
        try {
          if (result != null) {
            final resultMap = jsonDecode(jsonEncode(result)) as Map<String, dynamic>;
            completer.complete(resultMap);
          } else {
            completer.complete(null);
          }
        } catch (e) {
          completer.completeError(e);
        }
      });
      
      // Llamar función JavaScript
      js.context.callMethod('eval', ['''
        (async function() {
          try {
            if (window.sendMessageToSWWithResponse) {
              const result = await window.sendMessageToSWWithResponse($messageJson);
              window.$callbackName(result);
            } else {
              console.error('sendMessageToSWWithResponse no disponible');
              window.$callbackName(null);
            }
          } catch (error) {
            console.error('Error en sendMessageToSWWithResponse:', error);
            window.$callbackName(null);
          }
        })();
      ''']);
      
      // Esperar respuesta con timeout
      final result = await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('[OfflineService] Timeout esperando respuesta del SW');
          return null;
        },
      );
      
      // Limpiar callback
      js.context.deleteProperty(callbackName);
      
      return result;
      
    } catch (e) {
      print('[OfflineService] Error en comunicación con SW: $e');
      return null;
    }
  }

  /// Guardar en localStorage
  Future<void> _saveToLocalStorage(String key, String value) async {
    if (!kIsWeb) return;
    
    try {
      final valueJson = jsonEncode(value);
      js.context.callMethod('eval', [
        "localStorage.setItem('$key', $valueJson);"
      ]);
    } catch (e) {
      print('[OfflineService] Error guardando en localStorage: $e');
    }
  }

  /// Obtener de localStorage
  Future<String?> _getFromLocalStorage(String key) async {
    if (!kIsWeb) return null;
    
    try {
      final result = js.context.callMethod('eval', [
        "localStorage.getItem('$key')"
      ]);
      return result?.toString();
    } catch (e) {
      print('[OfflineService] Error leyendo localStorage: $e');
      return null;
    }
  }

  /// Cargar IDs de anuncios cacheados desde localStorage
  Future<void> _loadCachedAnunciosIds() async {
    try {
      final stored = await _getFromLocalStorage('cached_anuncios_ids');
      if (stored != null && stored != 'null') {
        final List<dynamic> ids = jsonDecode(stored);
        _cachedAnunciosIds.addAll(ids.cast<String>());
      }
    } catch (e) {
      print('[OfflineService] Error cargando IDs cacheados: $e');
    }
  }

  /// Guardar IDs en localStorage
  Future<void> _saveCachedIds() async {
    try {
      await _saveToLocalStorage(
        'cached_anuncios_ids',
        jsonEncode(_cachedAnunciosIds.toList()),
      );
    } catch (e) {
      print('[OfflineService] Error guardando IDs: $e');
    }
  }

  void dispose() {
    _connectivityController.close();
  }
}
