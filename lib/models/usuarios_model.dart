class UsuarioModel {
  final String uid;
  final String nombre;
  final String apellidos;
  final String email;
  final String telefono;
  final String tipo; // "user" | "provider"
  final String? descripcion;
  final String? fotoUrl;
  final String? fotoPublicId;
  final List<String>? oficios;

  UsuarioModel({
    required this.uid,
    required this.nombre,
    required this.apellidos,
    required this.email,
    required this.telefono,
    required this.tipo,
    this.descripcion,
    this.fotoUrl,
    this.fotoPublicId,
    this.oficios,
  });

  factory UsuarioModel.fromMap(Map<String, dynamic>? json) {
    // 1. Protección contra datos nulos generales
    if (json == null) {
      return UsuarioModel(
        uid: '', nombre: '', apellidos: '', email: '', telefono: '', tipo: 'user'
      );
    }

    // 2. Manejo seguro de la lista de Oficios
    List<String> oficiosSeguros = [];
    try {
      if (json['oficios'] != null) {
        if (json['oficios'] is List) {
          oficiosSeguros = List<String>.from(json['oficios'].map((x) => x.toString()));
        } else if (json['oficios'] is String) {
          oficiosSeguros = [json['oficios'].toString()];
        }
      }
    } catch (e) {
      print("Error procesando oficios: $e");
    }

    // 3. Retorno del modelo con conversión segura a String
    return UsuarioModel(
      uid: json["uid"]?.toString() ?? '',
      nombre: json["nombre"]?.toString() ?? json["name"]?.toString() ?? 'Usuario',
      apellidos: json["apellidos"]?.toString() ?? json["lastName"]?.toString() ?? '',
      email: json["email"]?.toString() ?? '',
      telefono: json["telefono"]?.toString() ?? json["phone"]?.toString() ?? '',
      tipo: json["tipo"]?.toString() ?? json["role"]?.toString() ?? 'user',
      descripcion: json["descripcion"]?.toString(),
      fotoUrl: json["fotoUrl"]?.toString(),
      fotoPublicId: json["fotoPublicId"]?.toString(),
      oficios: oficiosSeguros,
    );
  }

  Map<String, dynamic> toMap() => {
    "uid": uid,
    "nombre": nombre,
    "apellidos": apellidos,
    "email": email,
    "telefono": telefono,
    "tipo": tipo,
    "descripcion": descripcion,
    "fotoUrl": fotoUrl,
    "fotoPublicId": fotoPublicId,
    "oficios": oficios,
  };
}