enum TipoEquipo {
  pc('PC'),
  consola('Consola');

  const TipoEquipo(this.value);

  final String value;

  static TipoEquipo fromValue(String value) {
    return values.firstWhere(
      (tipo) => tipo.value == value,
      orElse: () => throw FormatException('Tipo de equipo desconocido: $value'),
    );
  }
}

enum EstadoEquipo {
  disponible('Disponible'),
  daniosMenores('Daños menores'),
  defectuoso('Defectuoso'),
  enMantenimiento('En mantenimiento');

  const EstadoEquipo(this.value);

  final String value;

  static EstadoEquipo fromValue(String value) {
    return values.firstWhere(
      (estado) => estado.value == value,
      orElse: () =>
          throw FormatException('Estado de equipo desconocido: $value'),
    );
  }
}

class Equipo {
  const Equipo({
    this.equipoId,
    required this.nombre,
    this.descripcion,
    required this.tarifaPorHora,
    this.imagen,
    required this.tipo,
    required this.estado,
  });

  final int? equipoId;
  final String nombre;
  final String? descripcion;
  final double tarifaPorHora;
  final String? imagen;
  final TipoEquipo tipo;
  final EstadoEquipo estado;

  factory Equipo.fromJson(Map<String, dynamic> json) {
    return Equipo(
      equipoId: _parseInt(json['equipo_id']),
      nombre: _parseString(json['nombre'], 'nombre'),
      descripcion: json['descripcion'] as String?,
      tarifaPorHora: _parseDouble(json['tarifa_por_hora'], 'tarifa_por_hora'),
      imagen: json['imagen'] as String?,
      tipo: TipoEquipo.fromValue(_parseString(json['tipo'], 'tipo')),
      estado: EstadoEquipo.fromValue(_parseString(json['estado'], 'estado')),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (equipoId != null) 'equipo_id': equipoId,
      'nombre': nombre,
      'descripcion': descripcion,
      'tarifa_por_hora': tarifaPorHora,
      'imagen': imagen,
      'tipo': tipo.value,
      'estado': estado.value,
    };
  }
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw FormatException('Valor entero inválido: $value');
}

double _parseDouble(dynamic value, String field) {
  if (value is num) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw FormatException('El campo $field debe ser un número');
}

String _parseString(dynamic value, String field) {
  if (value is String) return value;
  throw FormatException('El campo $field debe ser texto');
}
