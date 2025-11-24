class AnuncioModel {
  String id;
  String titulo;
  String descripcion;
  double precio;
  String proveedorId;
  // CAMBIO IMPORTANTE: Ahora es una lista de mapas, no de strings simples
  List<Map<String, dynamic>> imagenes; 
  DateTime? createdAt;
  String? categoria;

  AnuncioModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.precio,
    required this.proveedorId,
    this.imagenes = const [],
    this.createdAt,
    this.categoria,
  });

  factory AnuncioModel.fromMap(Map<String, dynamic> json) {
    return AnuncioModel(
      id: json["id"] ?? '',
      titulo: json["titulo"] ?? '',
      descripcion: json["descripcion"] ?? '',
      precio: (json["precio"] ?? 0).toDouble(),
      proveedorId: json["proveedorId"] ?? '',
      // Convertimos la lista de JSON a Lista de Mapas
      imagenes: json["imagenes"] != null
          ? List<Map<String, dynamic>>.from(json["imagenes"])
          : [],
      // CORRECCIÓN: Manejar tanto Timestamp como String
      createdAt: _parseDateTime(json["createdAt"]),
      categoria: json["categoria"],
    );
  }

  // MÉTODO HELPER para parsear fechas de múltiples formatos
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    
    try {
      // Si es un Timestamp de Firestore
      if (value.runtimeType.toString().contains('Timestamp')) {
        return (value as dynamic).toDate();
      }
      
      // Si es un String (ISO 8601)
      if (value is String) {
        return DateTime.parse(value);
      }
      
      // Si ya es DateTime
      if (value is DateTime) {
        return value;
      }
      
      return null;
    } catch (e) {
      print('Error parseando fecha: $e');
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "titulo": titulo,
      "descripcion": descripcion,
      "precio": precio,
      "proveedorId": proveedorId,
      "imagenes": imagenes, // Guardamos la estructura completa {url, public_id}
      "createdAt": createdAt ?? DateTime.now(),
      "categoria": categoria,
    };
  }
}
