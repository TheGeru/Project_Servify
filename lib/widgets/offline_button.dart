import 'package:flutter/material.dart';
import 'package:project_servify/models/anuncios_model.dart';
import 'package:project_servify/services/offline_service.dart';

class OfflineButton extends StatefulWidget {
  final AnuncioModel anuncio;
  final bool compact;

  const OfflineButton({super.key, required this.anuncio, this.compact = false});

  @override
  State<OfflineButton> createState() => _OfflineButtonState();
}

class _OfflineButtonState extends State<OfflineButton> {
  final _offlineService = OfflineService();
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  void _checkStatus() {
    if (mounted) {
      setState(() {
        _isSaved = _offlineService.isAnuncioSavedOffline(widget.anuncio.id);
      });
    }
  }

  Future<void> _toggleOffline() async {
    bool success;
    String message;
    Color color;

    if (_isSaved) {
      success = await _offlineService.removeAnuncioOffline(widget.anuncio.id);
      message = 'Eliminado de descargas';
      color = Colors.orange;
    } else {
      success = await _offlineService.saveAnuncioOffline(widget.anuncio);
      message = 'Guardado para ver sin conexión';
      color = Colors.green;
    }

    if (success && mounted) {
      _checkStatus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return IconButton(
        icon: Icon(
          _isSaved ? Icons.download_done : Icons.download_outlined,
          color: _isSaved ? Colors.green : Colors.grey[700],
        ),
        onPressed: _toggleOffline,
        tooltip: _isSaved ? 'Guardado' : 'Descargar',
      );
    }

    return ElevatedButton.icon(
      onPressed: _toggleOffline,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isSaved ? Colors.green.shade50 : Colors.blue.shade50,
        foregroundColor: _isSaved
            ? Colors.green.shade800
            : Colors.blue.shade800,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(
          color: _isSaved ? Colors.green.shade200 : Colors.blue.shade200,
        ),
      ),
      icon: Icon(
        _isSaved ? Icons.check_circle : Icons.download_for_offline,
        size: 18,
      ),
      label: Text(
        _isSaved ? 'Disponible Offline' : 'Descargar',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
