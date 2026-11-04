import 'package:flutter/material.dart';

import '../core/etiquetas.dart';
import '../data/db/enums.dart';

/// Etiqueta de color con el estado del cliente.
class EstadoChip extends StatelessWidget {
  const EstadoChip(this.estado, {super.key});

  final EstadoCliente estado;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (fondo, texto) = switch (estado) {
      EstadoCliente.activo => (Colors.green.shade100, Colors.green.shade900),
      EstadoCliente.suspendido => (Colors.orange.shade100, Colors.orange.shade900),
      EstadoCliente.cancelado => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(12)),
      child: Text(
        estado.etiqueta,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: texto),
      ),
    );
  }
}

/// Vista de error genérica para AsyncValue.
class ErrorVista extends StatelessWidget {
  const ErrorVista(this.error, {super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text('Ocurrió un error:\n$error', textAlign: TextAlign.center),
      ),
    );
  }
}

/// Título de sección con explicación y botón opcionales ([titulo] vacío: solo la
/// explicación, p. ej. dentro de una pestaña que ya lleva el nombre).
class SeccionTitulo extends StatelessWidget {
  const SeccionTitulo(this.titulo, {super.key, this.accion, this.descripcion, this.icono});

  final String titulo;
  final Widget? accion;

  /// Texto corto que explica para qué sirve la sección.
  final String? descripcion;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 8, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icono != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(icono, size: 20, color: scheme.secondary),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (titulo.isNotEmpty) Text(titulo, style: texto.titleMedium),
                if (descripcion != null)
                  Padding(
                    padding: EdgeInsets.only(top: titulo.isEmpty ? 0 : 2, right: 8),
                    child: Text(descripcion!,
                        style: texto.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                  ),
              ],
            ),
          ),
          ?accion,
        ],
      ),
    );
  }
}

/// Muestra un mensaje corto en la parte inferior.
void mostrarMensaje(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(mensaje)));
}

/// Pide confirmación con un diálogo Sí/No. Devuelve true si confirmó.
Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  String textoSi = 'Sí',
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('No'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(textoSi),
        ),
      ],
    ),
  );
  return ok ?? false;
}
