/// Acciones de gestión de un cliente (editar, suspender, reactivar, cancelar),
/// visibles en cada renglón de la lista de clientes y en la ficha.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/etiquetas.dart';
import '../../data/db/database.dart';
import '../../providers/providers.dart';
import '../../providers/sesion.dart';
import 'dialogos.dart';
import 'modales.dart';

/// Una acción posible sobre el cliente según su estado.
enum AccionCliente {
  editar('Editar', Icons.edit_outlined),
  suspender('Suspender', Icons.pause_circle_outline),
  reactivar('Reactivar', Icons.play_circle_outline),
  cancelar('Cancelar servicio', Icons.block);

  const AccionCliente(this.etiqueta, this.icono);

  final String etiqueta;
  final IconData icono;

  /// Estado al que lleva la acción (null para editar).
  EstadoCliente? get estadoNuevo => switch (this) {
        AccionCliente.editar => null,
        AccionCliente.suspender => EstadoCliente.suspendido,
        AccionCliente.reactivar => EstadoCliente.activo,
        AccionCliente.cancelar => EstadoCliente.cancelado,
      };
}

/// Acciones disponibles para un cliente en [estado]:
/// activo → suspender o cancelar; suspendido → reactivar o cancelar;
/// cancelado → reactivar. Editar siempre.
List<AccionCliente> accionesDisponibles(EstadoCliente estado) => [
      AccionCliente.editar,
      if (estado == EstadoCliente.activo) AccionCliente.suspender,
      if (estado != EstadoCliente.activo) AccionCliente.reactivar,
      if (estado != EstadoCliente.cancelado) AccionCliente.cancelar,
    ];

/// Ejecuta [accion] sobre [cliente]: abre el formulario de edición o pide
/// confirmación (con motivo opcional) y cambia el estado.
Future<void> ejecutarAccionCliente(
  BuildContext context,
  WidgetRef ref,
  Cliente cliente,
  AccionCliente accion,
) async {
  final nuevo = accion.estadoNuevo;
  if (nuevo == null) {
    await abrirFormularioCliente(context, clienteId: cliente.id);
    return;
  }
  // Se toman antes de esperar: al cambiar el estado el renglón puede
  // desaparecer de la lista (p. ej. con el filtro "Activos").
  final mensajero = ScaffoldMessenger.of(context);
  final repo = ref.read(clientesRepositoryProvider);
  final usuarioId = ref.read(sesionProvider)?.id;
  final motivo = await confirmarCambioEstado(
    context,
    nombreCliente: cliente.nombre,
    nuevo: nuevo,
  );
  if (motivo == null) return;
  try {
    await repo.cambiarEstado(cliente.id, nuevo,
        motivo: motivo.isEmpty ? null : motivo, usuarioId: usuarioId);
    mensajero
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('${cliente.nombre}: ${nuevo.etiqueta.toLowerCase()}')));
  } catch (e) {
    mensajero
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('No se pudo cambiar el estado: $e')));
  }
}

/// Botones de gestión del cliente. Con [compacto] solo se ven los íconos
/// (con su nombre al pasar el mouse); si no, ícono y texto.
class BotonesCliente extends ConsumerWidget {
  const BotonesCliente({super.key, required this.cliente, this.compacto = false});

  final Cliente cliente;
  final bool compacto;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    Color colorDe(AccionCliente a) => switch (a) {
          AccionCliente.editar => scheme.primary,
          AccionCliente.suspender => Colors.orange.shade800,
          AccionCliente.reactivar => Colors.green.shade700,
          AccionCliente.cancelar => scheme.error,
        };

    final botones = [
      for (final a in accionesDisponibles(cliente.estado))
        compacto
            ? IconButton(
                tooltip: a.etiqueta,
                icon: Icon(a.icono),
                color: colorDe(a),
                visualDensity: VisualDensity.compact,
                onPressed: () => ejecutarAccionCliente(context, ref, cliente, a),
              )
            : TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: colorDe(a),
                  visualDensity: VisualDensity.compact,
                ),
                icon: Icon(a.icono, size: 18),
                label: Text(a.etiqueta),
                onPressed: () => ejecutarAccionCliente(context, ref, cliente, a),
              ),
    ];
    return Wrap(spacing: compacto ? 0 : 4, runSpacing: 4, children: botones);
  }
}
