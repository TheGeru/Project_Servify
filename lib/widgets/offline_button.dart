// lib/widgets/offline_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:project_servify/models/anuncios_model.dart';
import 'package:project_servify/services/offline_service.dart';

class OfflineButton extends StatefulWidget {
  final AnuncioModel anuncio;
  final bool compact; // Versión compacta (solo icono)

  const OfflineButton({
    super.key,
    required this.anuncio,
    this.compact = false,
  });

  @override
  State<OfflineButton> createState() => _OfflineButtonState();
}

class _OfflineButtonState extends State<OfflineButton> {
  final _offlineService = OfflineService();
  bool _isSaved = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _isSaved = _offlineService.isAnuncioSavedOffline(widget.anuncio.id);
    }
  }

  Future<void> _toggleOffline() async {
    if (!kIsWeb) {
      _showNotWebMessage();
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool success;
      
      if (_isSaved) {
        success = await _offlineService.removeAnuncioOffline(widget.anuncio.id);
        if (success && mounted) {
          setState(() => _isSaved = false);
          _showSnackbar(
            '🗑️ Anuncio eliminado del modo offline',
            Colors.orange,
          );
        }
      } else {
        success = await _offlineService.saveAnuncioOffline(widget.anuncio);
        if (success && mounted) {
          setState(() => _isSaved = true);
          _showSnackbar(
            '✅ Anuncio guardado para ver sin conexión',
            Colors.green,
          );
        }
      }

      if (!success && mounted) {
        _showSnackbar('❌ Error al guardar', Colors.red);
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Error: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showNotWebMessage() {
    _showSnackbar(
      '⚠️ Modo offline solo disponible en versión Web',
      Colors.orange,
    );
  }

  @override
  Widget build(BuildContext context) {
    // No mostrar el botón si no es Web
    if (!kIsWeb) return const SizedBox.shrink();

    if (widget.compact) {
      return _buildCompactButton();
    }

    return _buildFullButton();
  }

  Widget _buildCompactButton() {
    return IconButton(
      onPressed: _isLoading ? null : _toggleOffline,
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              _isSaved ? Icons.download_done : Icons.download_outlined,
              color: _isSaved ? Colors.green : Colors.grey[700],
            ),
      tooltip: _isSaved ? 'Guardado offline' : 'Guardar para offline',
    );
  }

  Widget _buildFullButton() {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _toggleOffline,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isSaved ? Colors.green.shade50 : Colors.blue.shade50,
        foregroundColor: _isSaved ? Colors.green.shade800 : Colors.blue.shade800,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: _isSaved ? Colors.green.shade300 : Colors.blue.shade300,
          ),
        ),
      ),
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              _isSaved ? Icons.download_done : Icons.download_outlined,
              size: 20,
            ),
      label: Text(
        _isSaved ? 'Guardado Offline' : 'Guardar Offline',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
