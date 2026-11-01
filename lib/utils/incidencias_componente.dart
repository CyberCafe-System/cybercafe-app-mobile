import '../models/componente.dart';
import '../models/incidencia_componente.dart';
import 'busqueda_reportes.dart';

enum FiltroIncidenciasComponente {
  todos('Todos'),
  conIncidencias('Con incidencias'),
  sinIncidencias('Sin incidencias');

  const FiltroIncidenciasComponente(this.etiqueta);

  final String etiqueta;
}

final RegExp _separadorIncidencias = RegExp(r'^\s*-{5,}\s*$', multiLine: true);
final RegExp _encabezadoIncidencia = RegExp(
  r'^\[REVISI[OÓ]N:\s*#?(\d+)\s*\|\s*FECHA:\s*([^\]]+)\]',
  caseSensitive: false,
);
final RegExp _prefijoDescripcion = RegExp(
  r'^Descripci[oó]n:\s*',
  caseSensitive: false,
);

List<IncidenciaComponente> parsearIncidenciasComponente(String? observaciones) {
  final texto = observaciones?.trim();
  if (texto == null || texto.isEmpty) return const [];

  final incidencias = <IncidenciaComponente>[];
  for (final bloqueOriginal in texto.split(_separadorIncidencias)) {
    final bloque = bloqueOriginal.trim();
    if (bloque.isEmpty) continue;

    final encabezado = _encabezadoIncidencia.firstMatch(bloque);
    if (encabezado == null) {
      final descripcion = _limpiarDescripcion(bloque);
      if (descripcion.isNotEmpty) {
        incidencias.add(IncidenciaComponente(descripcion: descripcion));
      }
      continue;
    }

    final descripcion = _limpiarDescripcion(bloque.substring(encabezado.end));
    if (descripcion.isEmpty) continue;

    incidencias.add(
      IncidenciaComponente(
        revisionId: int.tryParse(encabezado.group(1) ?? ''),
        fechaTexto: encabezado.group(2)?.trim(),
        descripcion: descripcion,
      ),
    );
  }

  return incidencias;
}

String _limpiarDescripcion(String texto) {
  return texto.trim().replaceFirst(_prefijoDescripcion, '').trim();
}

bool componenteTieneIncidencias(Componente componente) {
  return parsearIncidenciasComponente(componente.observaciones).isNotEmpty;
}

String numeroSerieComponente(Componente componente) {
  final numeroSerie = componente.numeroSerie?.trim();
  return numeroSerie == null || numeroSerie.isEmpty
      ? 'No registrado'
      : numeroSerie;
}

String descripcionComponente(Componente componente) {
  final descripcion = componente.descripcion?.trim();
  return descripcion == null || descripcion.isEmpty
      ? 'Sin descripción'
      : descripcion;
}

List<Componente> filtrarComponentesIncidencias(
  List<Componente> componentes, {
  String consulta = '',
  FiltroIncidenciasComponente filtro = FiltroIncidenciasComponente.todos,
}) {
  final termino = normalizarTextoBusqueda(consulta);
  final incidenciasPorComponente = <Componente, bool>{
    for (final componente in componentes)
      componente: componenteTieneIncidencias(componente),
  };

  final resultados = componentes.where((componente) {
    final tieneIncidencias = incidenciasPorComponente[componente] ?? false;
    final cumpleFiltro = switch (filtro) {
      FiltroIncidenciasComponente.todos => true,
      FiltroIncidenciasComponente.conIncidencias => tieneIncidencias,
      FiltroIncidenciasComponente.sinIncidencias => !tieneIncidencias,
    };
    if (!cumpleFiltro) return false;
    if (termino.isEmpty) return true;

    final campos = [
      componente.nombre,
      componente.numeroSerie ?? '',
      componente.tipo.value,
      componente.descripcion ?? '',
      componente.observaciones ?? '',
      ...parsearIncidenciasComponente(
        componente.observaciones,
      ).map((incidencia) => incidencia.descripcion),
    ];
    return campos.any(
      (campo) => normalizarTextoBusqueda(campo).contains(termino),
    );
  }).toList();

  resultados.sort((a, b) {
    final incidenciasA = incidenciasPorComponente[a] ?? false;
    final incidenciasB = incidenciasPorComponente[b] ?? false;
    if (incidenciasA != incidenciasB) return incidenciasA ? -1 : 1;
    return normalizarTextoBusqueda(
      a.nombre,
    ).compareTo(normalizarTextoBusqueda(b.nombre));
  });

  return resultados;
}
