import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_servify/models/anuncios_model.dart';
import 'package:project_servify/services/anuncios_service.dart';
import 'package:project_servify/widgets/card_container.dart';

class SearchScreen extends StatefulWidget {
  final Function(BuildContext, AnuncioModel)? navigateToServiceDetail;

  const SearchScreen({
    super.key,
    this.navigateToServiceDetail,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _anunciosService = AnunciosService();
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  
  String _searchText = '';
  List<AnuncioModel> _allAnuncios = [];
  List<AnuncioModel> _searchResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnuncios();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadAnuncios() async {
    setState(() => _isLoading = true);
    
    _anunciosService.getAllAnuncios().listen((anuncios) {
      if (mounted) {
        setState(() {
          _allAnuncios = anuncios;
          _isLoading = false;
          if (_searchText.isNotEmpty) {
            _searchServices(_searchText);
          }
        });
      }
    });
  }

  void _searchServices(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _searchText = query;
      });
      return;
    }

    final lowerCaseQuery = query.toLowerCase();
    final results = _allAnuncios.where((anuncio) {
      return anuncio.titulo.toLowerCase().contains(lowerCaseQuery) ||
          anuncio.descripcion.toLowerCase().contains(lowerCaseQuery) ||
          (anuncio.categoria?.toLowerCase().contains(lowerCaseQuery) ?? false);
    }).toList();

    setState(() {
      _searchResults = results;
      _searchText = query;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchServices('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F3B81),
        foregroundColor: Colors.white,
        title: const Text('Buscar Servicios'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // BARRA DE BÚSQUEDA MÁS VISIBLE
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                autofocus: true,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, categoría...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 24),
                  suffixIcon: _searchText.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[600]),
                          onPressed: _clearSearch,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: _searchServices,
              ),
            ),
          ),
          // CONTENIDO
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando servicios...'),
          ],
        ),
      );
    }

    if (_searchText.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Icon(Icons.search, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Busca el servicio que necesitas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Escribe en la barra de arriba para comenzar',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Categorías populares:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Electricidad',
                'Plomería',
                'Carpintería',
                'Jardinería',
                'Pintura',
                'Limpieza',
                'Mecánica',
              ].map((categoria) {
                return ActionChip(
                  label: Text(categoria),
                  avatar: const Icon(Icons.arrow_forward, size: 16),
                  onPressed: () {
                    _searchController.text = categoria;
                    _searchServices(categoria);
                  },
                  backgroundColor: Colors.blue.shade50,
                  labelStyle: TextStyle(color: Colors.blue.shade800),
                );
              }).toList(),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No se encontraron servicios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Intenta con otras palabras clave o explora las categorías',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            '${_searchResults.length} resultado${_searchResults.length != 1 ? 's' : ''} encontrado${_searchResults.length != 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final anuncio = _searchResults[index];
              final currentUser = FirebaseAuth.instance.currentUser;
              final isOwner = currentUser?.uid == anuncio.proveedorId;
              
              return AnuncioCard(
                anuncio: anuncio,
                onTap: () {
                  if (widget.navigateToServiceDetail != null) {
                    widget.navigateToServiceDetail!(context, anuncio);
                  }
                },
                showProviderInfo: !isOwner, // Ocultar info si es el dueño
                // CORRECCIÓN: Solo mostrar botones si es el dueño
                onEdit: isOwner ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Función de editar en desarrollo'),
                    ),
                  );
                } : null,
                onDelete: isOwner ? () async {
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

                  if (confirm == true && mounted) {
                    try {
                      await _anunciosService.deleteAnuncio(
                        anuncio.id,
                        anuncio.proveedorId,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Anuncio eliminado'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // Refrescar búsqueda
                      _searchServices(_searchText);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } : null,
              );
            },
          ),
        ),
      ],
    );
  }
}
