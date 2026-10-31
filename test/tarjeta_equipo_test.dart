import 'package:cybercafe_app_mobile/models/equipo.dart';
import 'package:cybercafe_app_mobile/models/renta_activa.dart';
import 'package:cybercafe_app_mobile/widgets/tarjeta_equipo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra cliente, tiempo restante y progreso de la renta', (
    tester,
  ) async {
    final ahora = DateTime(2026, 10, 30, 10);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 160,
              height: 205,
              child: TarjetaEquipo(
                equipo: Equipo(
                  equipoId: 8,
                  nombre: 'PC-08',
                  tarifaPorHora: 2.5,
                  tipo: TipoEquipo.pc,
                  estado: EstadoEquipo.disponible,
                ),
                ahora: ahora,
                rentaActiva: RentaActivaEquipo(
                  detalleRentaId: 3,
                  rentaId: 20,
                  equipoId: 8,
                  tiempoTotal: 60,
                  minutosTranscurridos: 15,
                  minutosRestantes: 45,
                  consultadaEn: ahora,
                  clienteNombre: 'Ana Pérez',
                ),
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('En uso'), findsOneWidget);
    expect(find.text('Cliente: Ana Pérez'), findsOneWidget);
    expect(find.text('Quedan 45 min'), findsOneWidget);
    expect(find.text('Finaliza a las 10:45'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
