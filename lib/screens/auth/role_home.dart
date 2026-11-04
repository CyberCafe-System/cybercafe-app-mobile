import 'package:flutter/widgets.dart';

import '../admin/admin_main_screen.dart';
import '../asistente/dashboard_screen.dart';

/// Devuelve la pantalla principal según el rol, o `null` si no tiene acceso.
Widget? homePorRol(int? rolId) {
  switch (rolId) {
    case 1:
      return const AdminMainScreen();
    case 3:
      return const DashboardAsistente();
    default:
      return null;
  }
}
