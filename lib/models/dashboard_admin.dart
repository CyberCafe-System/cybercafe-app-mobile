class ResumenGeneralAdmin {
  const ResumenGeneralAdmin({
    required this.totalIngresos,
    required this.totalIngresosVentas,
    required this.totalIngresosRentas,
    required this.cantidadVentas,
    required this.cantidadRentas,
    required this.sesionesRentaActivas,
    required this.totalClientes,
    required this.totalEquipos,
    required this.equiposDisponibles,
    required this.equiposEnMantenimientoOAveriados,
    required this.productosStockBajo,
  });

  final double totalIngresos;
  final double totalIngresosVentas;
  final double totalIngresosRentas;
  final int cantidadVentas;
  final int cantidadRentas;
  final int sesionesRentaActivas;
  final int totalClientes;
  final int totalEquipos;
  final int equiposDisponibles;
  final int equiposEnMantenimientoOAveriados;
  final int productosStockBajo;

  factory ResumenGeneralAdmin.fromJson(Map<String, dynamic> json) {
    return ResumenGeneralAdmin(
      totalIngresos: _double(json['total_ingresos']),
      totalIngresosVentas: _double(json['total_ingresos_ventas']),
      totalIngresosRentas: _double(json['total_ingresos_rentas']),
      cantidadVentas: _int(json['cantidad_ventas']),
      cantidadRentas: _int(json['cantidad_rentas']),
      sesionesRentaActivas: _int(json['sesiones_renta_activas']),
      totalClientes: _int(json['total_clientes']),
      totalEquipos: _int(json['total_equipos']),
      equiposDisponibles: _int(json['equipos_disponibles']),
      equiposEnMantenimientoOAveriados: _int(
        json['equipos_en_mantenimiento_o_averiados'],
      ),
      productosStockBajo: _int(json['productos_stock_bajo']),
    );
  }
}

class ResumenDiarioAdmin {
  const ResumenDiarioAdmin({
    required this.fecha,
    required this.totalDia,
    required this.ingresosVentasHoy,
    required this.ingresosRentasHoy,
    required this.cantidadVentasHoy,
    required this.cantidadRentasHoy,
    required this.rentasPendientesPagoHoy,
  });

  final DateTime fecha;
  final double totalDia;
  final double ingresosVentasHoy;
  final double ingresosRentasHoy;
  final int cantidadVentasHoy;
  final int cantidadRentasHoy;
  final int rentasPendientesPagoHoy;

  factory ResumenDiarioAdmin.fromJson(Map<String, dynamic> json) {
    return ResumenDiarioAdmin(
      fecha: _date(json['fecha']) ?? DateTime.now(),
      totalDia: _double(json['total_dia']),
      ingresosVentasHoy: _double(json['ingresos_ventas_hoy']),
      ingresosRentasHoy: _double(json['ingresos_rentas_hoy']),
      cantidadVentasHoy: _int(json['cantidad_ventas_hoy']),
      cantidadRentasHoy: _int(json['cantidad_rentas_hoy']),
      rentasPendientesPagoHoy: _int(json['rentas_pendientes_pago_hoy']),
    );
  }
}

class DashboardAdminData {
  const DashboardAdminData({
    required this.general,
    required this.hoy,
    required this.semana,
  });

  final ResumenGeneralAdmin general;
  final ResumenDiarioAdmin hoy;
  final List<ResumenDiarioAdmin> semana;
}

double _double(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

DateTime? _date(dynamic value) {
  if (value is String) return DateTime.tryParse(value);
  return null;
}
