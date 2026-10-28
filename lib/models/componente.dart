enum TipoComponente {
  mouse('Mouse'),
  teclado('Teclado'),
  monitor('Monitor'),
  control('Control');

  const TipoComponente(this.value);

  final String value;

  static TipoComponente fromValue(String value) {
    return values.firstWhere(
      (tipo) => tipo.value == value,
      orElse: () =>
          throw FormatException('Tipo de componente desconocido: $value'),
    );
  }
}

enum EstadoComponente {
  disponible('Disponible'),
  daniosMenores('Daños menores'),
  requiereReemplazo('Requiere reemplazo');

  const EstadoComponente(this.value);

  final String value;

  static EstadoComponente fromValue(String value) {
    return values.firstWhere(
      (estado) => estado.value == value,
      orElse: () =>
          throw FormatException('Estado de componente desconocido: $value'),
    );
  }
}

class Componente {
  const Componente({
    this.componenteId,
    this.equipoId,
    required this.nombre,
    this.numeroSerie,
    required this.tipo,
    required this.estado,
    this.descripcion,
    this.observaciones,
    this.imagen,
    this.activo = true,
  });

  final int? componenteId;
  final int? equipoId;
  final String nombre;
  final String? numeroSerie;
  final TipoComponente tipo;
  final EstadoComponente estado;
  final String? descripcion;
  final String? observaciones;
  final String? imagen;
  final bool activo;

  factory Componente.fromJson(Map<String, dynamic> json) {
    return Componente(
      componenteId: _parseInt(json['componente_id']),
      equipoId: _parseInt(json['equipo_id']),
      nombre: _parseString(json['nombre'], 'nombre'),
      numeroSerie: json['numero_serie'] as String?,
      tipo: TipoComponente.fromValue(_parseString(json['tipo'], 'tipo')),
      estado: EstadoComponente.fromValue(
        _parseString(json['estado'], 'estado'),
      ),
      descripcion: json['descripcion'] as String?,
      observaciones: json['observaciones'] as String?,
      imagen: json['imagen'] as String?,
      activo: json['activo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (componenteId != null) 'componente_id': componenteId,
      'equipo_id': equipoId,
      'nombre': nombre,
      'numero_serie': numeroSerie,
      'tipo': tipo.value,
      'estado': estado.value,
      'descripcion': descripcion,
      'observaciones': observaciones,
      'imagen': imagen,
      'activo': activo,
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

String _parseString(dynamic value, String field) {
  if (value is String) return value;
  throw FormatException('El campo $field debe ser texto');
}
