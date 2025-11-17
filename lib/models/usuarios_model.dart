class UsuarioModel {
  final String uid;
  final String nombre;
  final String apellidos;
  final String email;
  final String telefono;
  final String tipo; // "user" | "provider"
  final String? descripcion;
  final String? fotoUrl;
  final List<String>? oficios;

  //**
  //*ESTE FUNCIONA PARA PASAR DATOS DE FIREBASE 
  //*A LA APP Y LUEGO A OTRAS PARTES DE LA APP*//
  UsuarioModel({
    required this.uid,
    required this.nombre,
    required this.apellidos,
    required this.email,
    required this.telefono,
    required this.tipo,
    this.descripcion,
    this.fotoUrl,
    this.oficios,
  });

  factory UsuarioModel.fromMap(Map<String, dynamic> json) => UsuarioModel(
    uid: json["uid"] ?? '',
    nombre: json["nombre"] ?? '',
    apellidos: json["apellidos"] ?? '',
    email: json["email"] ?? '',
    telefono: json["telefono"] ?? '',
    tipo: json["tipo"] ?? 'user',
    descripcion: json["descripcion"],
    fotoUrl: json["fotoUrl"],
    oficios: json["oficios"] != null
        ? List<String>.from(json["oficios"])
        : <String>[],
  );

  Map<String, dynamic> toMap() => {
    "uid": uid,
    "nombre": nombre,
    "apellidos": apellidos,
    "email": email,
    "telefono": telefono,
    "tipo": tipo,
    "descripcion": descripcion,
    "fotoUrl": fotoUrl,
    "oficios": oficios,
  };
}
