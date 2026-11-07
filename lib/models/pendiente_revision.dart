class PendienteRevision {
  const PendienteRevision({
    required this.detalleRentaId,
    required this.equipoId,
    this.rentaId,
    this.clienteNombre,
  });

  final int detalleRentaId;
  final int equipoId;
  final int? rentaId;
  final String? clienteNombre;
}
