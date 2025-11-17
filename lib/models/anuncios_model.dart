class AnuncioModel {
  String id;
  String titulo;
  String descripcion;
  double precio;
  String proveedorId;        // Relación con usuario
  List<String> imagenes;

  AnuncioModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.precio,
    required this.proveedorId,
    required this.imagenes,
  });

  factory AnuncioModel.fromMap(Map<String, dynamic> json) => AnuncioModel(
        id: json["id"],
        titulo: json["titulo"],
        descripcion: json["descripcion"],
        precio: json["precio"].toDouble(),
        proveedorId: json["proveedorId"],
        imagenes: List<String>.from(json["imagenes"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "titulo": titulo,
        "descripcion": descripcion,
        "precio": precio,
        "proveedorId": proveedorId,
        "imagenes": imagenes,
      };
}
