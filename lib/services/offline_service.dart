import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_servify/models/anuncios_model.dart';

class OfflineService {
  // Singleton
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  final _connectivity = Connectivity();
  final _connectivityController = StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityController.stream;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  // Nombre de la caja de Hive
  final String _boxName = 'anuncios_offline';

  /// Inicializar monitoreo de red
  Future<void> initialize() async {
    // Verificar estado inicial
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);

    // Escuchar cambios
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  // Manejo robusto de conectividad (ConnectivityResult puede ser List o Enum según versión)
  void _updateConnectionStatus(dynamic result) {
    bool hasConnection = false;

    if (result is List<ConnectivityResult>) {
      hasConnection = !result.contains(ConnectivityResult.none);
    } else if (result is ConnectivityResult) {
      hasConnection = result != ConnectivityResult.none;
    } else if (result is List) {
      // Fallback genérico
      hasConnection =
          result.isNotEmpty && result.first != ConnectivityResult.none;
    }

    // Solo emitimos si cambió el estado
    if (_isOnline != hasConnection) {
      _isOnline = hasConnection;
      _connectivityController.add(_isOnline);
      print("[OfflineService] Estado: ${_isOnline ? 'ONLINE' : 'OFFLINE'}");
    }
  }

  /// Guardar anuncio localmente (Map/JSON)
  Future<bool> saveAnuncioOffline(AnuncioModel anuncio) async {
    try {
      var box = Hive.box(_boxName);

      // Guardamos usando el ID como llave y el Mapa como valor
      await box.put(anuncio.id, anuncio.toMap());

      return true;
    } catch (e) {
      print("Error guardando offline: $e");
      return false;
    }
  }

  /// Eliminar anuncio local
  Future<bool> removeAnuncioOffline(String anuncioId) async {
    try {
      var box = Hive.box(_boxName);
      await box.delete(anuncioId);
      return true;
    } catch (e) {
      print("Error eliminando offline: $e");
      return false;
    }
  }

  /// Verificar si está guardado
  bool isAnuncioSavedOffline(String anuncioId) {
    if (!Hive.isBoxOpen(_boxName)) return false;
    var box = Hive.box(_boxName);
    return box.containsKey(anuncioId);
  }

  /// Obtener todos los anuncios guardados
  List<AnuncioModel> getCachedAnuncios() {
    try {
      if (!Hive.isBoxOpen(_boxName)) return [];

      var box = Hive.box(_boxName);

      // Convertimos los Maps guardados de vuelta a Objetos AnuncioModel
      return box.values.map((dynamic item) {
        // Hive devuelve dynamic, casteamos a Map seguro
        final map = Map<String, dynamic>.from(item as Map);

        // Aseguramos conversión de fechas si es necesario
        if (map['createdAt'] is String) {
          // AnuncioModel.fromMap ya debería manejar esto, pero por seguridad:
          // Dejamos que el modelo haga su trabajo
        }

        return AnuncioModel.fromMap(map);
      }).toList();
    } catch (e) {
      print("Error recuperando cache: $e");
      return [];
    }
  }

  /// Limpiar todo
  Future<void> clearAllCache() async {
    var box = Hive.box(_boxName);
    await box.clear();
  }

  void dispose() {
    _connectivityController.close();
  }
}
