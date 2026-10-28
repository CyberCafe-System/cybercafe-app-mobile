import 'package:flutter/material.dart';

const Color adminMarron = Color(0xFF2C1E16);
const Color adminAmbar = Color(0xFFB06B05);
const Color adminFondo = Color(0xFFF4F6F9);
const Color adminVerde = Color(0xFF2E7D32);
const Color adminRojo = Color(0xFFD32F2F);
const Color adminAzul = Color(0xFF1565C0);

class ReporteActionBar extends StatelessWidget {
  const ReporteActionBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onRefresh,
    required this.onPdf,
    this.exportando = false,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onRefresh;
  final VoidCallback onPdf;
  final bool exportando;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: const Icon(Icons.search, color: adminAmbar),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _AccionRedonda(
          icon: Icons.refresh_rounded,
          tooltip: 'Actualizar reportes',
          onPressed: onRefresh,
        ),
        const SizedBox(width: 10),
        _AccionRedonda(
          icon: Icons.picture_as_pdf_rounded,
          tooltip: 'Exportar PDF',
          onPressed: exportando ? null : onPdf,
          cargando: exportando,
          destacada: true,
        ),
      ],
    );
  }
}

class _AccionRedonda extends StatelessWidget {
  const _AccionRedonda({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.cargando = false,
    this.destacada = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool cargando;
  final bool destacada;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: destacada ? adminRojo : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: (destacada ? Colors.redAccent : Colors.black).withValues(
                alpha: destacada ? 0.25 : 0.05,
              ),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: cargando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(icon, color: destacada ? Colors.white : adminAmbar),
        ),
      ),
    );
  }
}

class ReporteStatCard extends StatelessWidget {
  const ReporteStatCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
    this.detalle,
  });

  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;
  final String? detalle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              maxLines: 1,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (detalle != null) ...[
            const SizedBox(height: 2),
            Text(
              detalle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}

class EstadoChip extends StatelessWidget {
  const EstadoChip({super.key, required this.etiqueta, required this.color});

  final String etiqueta;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        etiqueta,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ReporteEmptyState extends StatelessWidget {
  const ReporteEmptyState({
    super.key,
    required this.icono,
    required this.titulo,
    required this.mensaje,
  });

  final IconData icono;
  final String titulo;
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: adminAmbar.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icono, size: 46, color: adminAmbar),
            ),
            const SizedBox(height: 18),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: adminMarron,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class ReporteErrorState extends StatelessWidget {
  const ReporteErrorState({
    super.key,
    required this.mensaje,
    required this.onRetry,
  });

  final String mensaje;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: adminRojo.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 46,
                color: adminRojo,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No se pudieron cargar los reportes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: adminMarron,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: FilledButton.styleFrom(
                backgroundColor: adminAmbar,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReporteSectionCard extends StatelessWidget {
  const ReporteSectionCard({
    super.key,
    required this.titulo,
    required this.icono,
    required this.child,
    this.color = adminAmbar,
  });

  final String titulo;
  final IconData icono;
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icono, color: color, size: 18),
              ),
              const SizedBox(width: 9),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: adminMarron,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class ReporteInfoRow extends StatelessWidget {
  const ReporteInfoRow({
    super.key,
    required this.etiqueta,
    required this.valor,
    this.icono,
  });

  final String etiqueta;
  final String valor;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icono != null) ...[
            Icon(icono, size: 16, color: adminAmbar),
            const SizedBox(width: 7),
          ],
          SizedBox(
            width: 105,
            child: Text(
              etiqueta,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                color: adminMarron,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
