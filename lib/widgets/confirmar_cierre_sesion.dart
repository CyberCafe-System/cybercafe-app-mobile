import 'package:flutter/material.dart';

/// Pide confirmación antes de cerrar la sesión.
Future<bool> confirmarCierreSesion(BuildContext context) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cerrar sesión'),
      content: const Text('¿Seguro que quieres cerrar sesión?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFB06B05),
            foregroundColor: Colors.white,
          ),
          child: const Text('Cerrar sesión'),
        ),
      ],
    ),
  );

  return resultado ?? false;
}
