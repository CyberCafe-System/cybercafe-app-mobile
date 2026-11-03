class UsuarioPerfil {
  const UsuarioPerfil({
    required this.usuarioId,
    required this.rolId,
    required this.nombre,
    required this.username,
    required this.correo,
    required this.activo,
  });

  final int usuarioId;
  final int rolId;
  final String nombre;
  final String username;
  final String correo;
  final bool activo;

  factory UsuarioPerfil.fromJson(Map<String, dynamic> json) {
    final activo = json['activo'];
    return UsuarioPerfil(
      usuarioId: _parseInt(json['usuario_id'], 'usuario_id'),
      rolId: _parseInt(json['rol_id'], 'rol_id'),
      nombre: _parseString(json['nombre'], 'nombre'),
      username: _parseString(json['username'], 'username'),
      correo: _parseString(json['correo'], 'correo'),
      activo: activo is bool ? activo : true,
    );
  }
}

int _parseInt(dynamic value, String field) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw FormatException('El campo $field debe ser un entero');
}

String _parseString(dynamic value, String field) {
  if (value is String) return value;
  throw FormatException('El campo $field debe ser texto');
}
