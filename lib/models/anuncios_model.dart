class AnuncioModel {
  String id;
  String titulo;
  String descripcion;
  double precio;
  String proveedorId;
  List<String> imagenes;
  DateTime? createdAt; // Opcional: fecha de creación
  String? categoria;   // Opcional: categoría del servicio

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
      imagenes: json["imagenes"] != null 
          ? List<String>.from(json["imagenes"]) 
          : [],
      createdAt: json["createdAt"] != null
          ? (json["createdAt"] as dynamic).toDate()
          : null,
      categoria: json["categoria"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "titulo": titulo,
      "descripcion": descripcion,
      "precio": precio,
      "proveedorId": proveedorId,
      "imagenes": imagenes,
      "createdAt": createdAt ?? DateTime.now(),
      "categoria": categoria,
    };
  }
}
