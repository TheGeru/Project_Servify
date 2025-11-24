import 'dart:io'; // <--- 1. Para manejar el archivo nuevo
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // <--- 2. Para seleccionar foto
import 'package:project_servify/models/anuncios_model.dart';
import 'package:project_servify/services/anuncios_service.dart';
import 'package:project_servify/services/cloudinary_service.dart'; // <--- 3. Para subir/borrar foto

class EditServiceScreen extends StatefulWidget {
  final AnuncioModel anuncio;

  const EditServiceScreen({super.key, required this.anuncio});

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _anunciosService = AnunciosService();
  final _cloudinaryService = CloudinaryService(); // Instancia para manejar la foto

  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late TextEditingController _precioController;

  File? _nuevaImagen; // Variable para la nueva foto si selecciona una

  final List<String> _categorias = [
    'Electricidad',
    'Plomería',
    'Carpintería',
    'Jardinería',
    'Pintura',
    'Limpieza',
    'Albañilería',
    'Mecánica',
    'Programación',
    'Otro',
  ];

  String? _categoriaSeleccionada;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.anuncio.titulo);
    _descripcionController = TextEditingController(text: widget.anuncio.descripcion);
    _precioController = TextEditingController(text: widget.anuncio.precio.toString());
    _categoriaSeleccionada = widget.anuncio.categoria;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  // Función para elegir nueva foto
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _nuevaImagen = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateAnuncio() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos correctamente'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_categoriaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una categoría'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final precio = double.parse(_precioController.text.trim());
      
      // Lista de imágenes final (empezamos con las que ya tenía)
      List<Map<String, dynamic>> imagenesFinales = widget.anuncio.imagenes;

      // SI EL USUARIO SELECCIONÓ UNA NUEVA FOTO:
      if (_nuevaImagen != null) {
        // 1. Subir la nueva foto
        final result = await _cloudinaryService.uploadImage(
          _nuevaImagen!, 
          folder: 'services_images'
        );

        if (result != null) {
          // 2. (Opcional) Borrar la foto anterior de Cloudinary si existía
          if (widget.anuncio.imagenes.isNotEmpty) {
             final oldPublicId = widget.anuncio.imagenes.first['public_id'];
             if (oldPublicId != null) {
               await _cloudinaryService.deleteImage(oldPublicId);
             }
          }

          // 3. Reemplazar la lista con la nueva imagen
          imagenesFinales = [
            {'url': result['url'], 'public_id': result['public_id']}
          ];
        }
      }

      final anuncioActualizado = AnuncioModel(
        id: widget.anuncio.id,
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        precio: precio,
        proveedorId: widget.anuncio.proveedorId,
        imagenes: imagenesFinales, // Usamos la lista actualizada
        createdAt: widget.anuncio.createdAt,
        categoria: _categoriaSeleccionada,
      );

      await _anunciosService.updateAnuncio(anuncioActualizado);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('¡Anuncio actualizado exitosamente!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar anuncio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verificar si hay imagen actual (URL)
    String? currentImageUrl;
    if (widget.anuncio.imagenes.isNotEmpty) {
      currentImageUrl = widget.anuncio.imagenes.first['url'];
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Editar Servicio'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- SECCIÓN DE FOTO ---
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.orange.shade200),
                    image: _nuevaImagen != null
                        ? DecorationImage(
                            image: FileImage(_nuevaImagen!),
                            fit: BoxFit.cover,
                          )
                        : (currentImageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(currentImageUrl),
                                fit: BoxFit.cover,
                              )
                            : null),
                  ),
                  child: (_nuevaImagen == null && currentImageUrl == null)
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 50, color: Colors.orange),
                            Text("Agregar Foto", style: TextStyle(color: Colors.grey))
                          ],
                        )
                      : Container(
                          // Sombrita para que se note que se puede editar
                          alignment: Alignment.bottomRight,
                          padding: const EdgeInsets.all(10),
                          child: const CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 20,
                            child: Icon(Icons.edit, color: Colors.orange),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              // -----------------------

              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: const [
                      Icon(Icons.edit, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Modifica los campos que desees actualizar',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                  labelText: 'Título del Servicio',
                  prefixIcon: const Icon(Icons.title, color: Colors.orange),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El título es obligatorio';
                  }
                  if (value.length < 10) {
                    return 'El título debe tener al menos 10 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: const Icon(Icons.category, color: Colors.orange),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _categorias.map((categoria) {
                  return DropdownMenuItem(
                    value: categoria,
                    child: Text(categoria),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _categoriaSeleccionada = value);
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descripcionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Descripción Detallada',
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.description, color: Colors.orange),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La descripción es obligatoria';
                  }
                  if (value.length < 30) {
                    return 'La descripción debe tener al menos 30 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _precioController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Precio (MXN)',
                  prefixIcon: const Icon(Icons.attach_money, color: Colors.orange),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El precio es obligatorio';
                  }
                  final precio = double.tryParse(value);
                  if (precio == null || precio <= 0) {
                    return 'Ingresa un precio válido mayor a 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _isLoading ? null : _updateAnuncio,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save),
                          SizedBox(width: 10),
                          Text(
                            'GUARDAR CAMBIOS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}