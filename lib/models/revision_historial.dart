import 'equipo.dart';
import 'revision_equipo.dart';

class RevisionHistorialItem {
  const RevisionHistorialItem({
    required this.revision,
    required this.equipoNombre,
    this.equipoTipo,
    this.clienteNombre,
    this.usuarioNombre,
  });

  final RevisionEquipo revision;
  final String equipoNombre;
  final TipoEquipo? equipoTipo;
  final String? clienteNombre;
  final String? usuarioNombre;
}
