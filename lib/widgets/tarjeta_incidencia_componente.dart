import 'package:flutter/material.dart';

import '../models/componente.dart';
import '../models/incidencia_componente.dart';
import '../utils/incidencias_componente.dart';

class TarjetaIncidenciaComponente extends StatelessWidget {
  const TarjetaIncidenciaComponente({super.key, required this.componente});

  final Componente componente;

  @override
  Widget build(BuildContext context) {
    final incidencias = parsearIncidenciasComponente(componente.observaciones);
    final tieneIncidencias = incidencias.isNotEmpty;
    final color = tieneIncidencias
        ? const Color(0xFFB06B05)
        : const Color(0xFF43A047);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: color, width: 5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconoComponente(componente.tipo),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      componente.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C1E16),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Tipo: ${componente.tipo.value}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'N.º de serie: ${numeroSerieComponente(componente)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Estado actual:',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _Etiqueta(
                          texto: componente.estado.value,
                          color: _colorEstadoComponente(componente.estado),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!componente.activo) ...[
                const SizedBox(width: 8),
                _Etiqueta(texto: 'Inactivo', color: Colors.grey.shade600),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _DatoComponente(
            icono: Icons.description_outlined,
            etiqueta: 'Descripción',
            valor: descripcionComponente(componente),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                tieneIncidencias
                    ? Icons.warning_amber_rounded
                    : Icons.verified_outlined,
                size: 17,
                color: color,
              ),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'Observaciones',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _Etiqueta(
                texto: tieneIncidencias
                    ? '${incidencias.length} incidencia${incidencias.length == 1 ? '' : 's'}'
                    : 'Sin incidencias',
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!tieneIncidencias)
            const Text(
              'Sin incidencias registradas.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            for (final incidencia in incidencias) ...[
              _DetalleIncidencia(incidencia: incidencia),
              if (incidencia != incidencias.last) const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

class _DetalleIncidencia extends StatelessWidget {
  const _DetalleIncidencia({required this.incidencia});

  final IncidenciaComponente incidencia;

  @override
  Widget build(BuildContext context) {
    final tieneEncabezado =
        incidencia.revisionId != null || incidencia.fechaTexto != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tieneEncabezado) ...[
            Row(
              children: [
                if (incidencia.revisionId != null)
                  Text(
                    'Revisión #${incidencia.revisionId}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF2C1E16),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                if (incidencia.revisionId != null &&
                    incidencia.fechaTexto != null)
                  const SizedBox(width: 6),
                if (incidencia.fechaTexto != null)
                  Expanded(
                    child: Text(
                      incidencia.fechaTexto!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          Text(
            incidencia.descripcion,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _DatoComponente extends StatelessWidget {
  const _DatoComponente({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 15, color: Colors.grey),
        const SizedBox(width: 7),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$etiqueta: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: valor),
              ],
            ),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.texto, required this.color});

  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

Color _colorEstadoComponente(EstadoComponente estado) {
  switch (estado) {
    case EstadoComponente.disponible:
      return const Color(0xFF43A047);
    case EstadoComponente.daniosMenores:
      return const Color(0xFFF9A825);
    case EstadoComponente.requiereReemplazo:
      return const Color(0xFFD84343);
  }
}

IconData _iconoComponente(TipoComponente tipo) {
  switch (tipo) {
    case TipoComponente.mouse:
      return Icons.mouse_outlined;
    case TipoComponente.teclado:
      return Icons.keyboard_outlined;
    case TipoComponente.monitor:
      return Icons.monitor_outlined;
    case TipoComponente.control:
      return Icons.sports_esports_outlined;
  }
}
