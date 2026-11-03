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

/// Título de sección con botón opcional a la derecha.
class SeccionTitulo extends StatelessWidget {
  const SeccionTitulo(this.titulo, {super.key, this.accion});

  final String titulo;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(titulo, style: Theme.of(context).textTheme.titleMedium),
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
