class IncidenciaComponente {
  const IncidenciaComponente({
    this.revisionId,
    this.fechaTexto,
    required this.descripcion,
  });

  final int? revisionId;
  final String? fechaTexto;
  final String descripcion;
}
