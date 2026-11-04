import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dinero.dart';
import '../../core/etiquetas.dart';
import '../../data/db/database.dart';
import '../../data/repositories/vencimientos_repository.dart' show OperacionNoPermitida;
import '../../providers/providers.dart';
import '../../widgets/comunes.dart';
import '../../widgets/disposicion.dart';
import 'dialogo_plan.dart';

/// Configuración: catálogo de planes y tipos de contratación.
class ConfiguracionScreen extends ConsumerWidget {
  const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final escritorio = esEscritorio(context);
    return Scaffold(
      appBar: escritorio ? null : AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          ContenidoCentrado(
            anchoMaximo: 900,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (escritorio)
                  const EncabezadoSeccion(
                    titulo: 'Configuración',
                    descripcion: 'Planes de internet y tipos de contratación de tus clientes',
                    icono: Icons.settings,
                  ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _TarjetaPlanes(),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _TarjetaContrataciones(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Encabezado de cada tarjeta: ícono, título, explicación y acción opcional.
class _Cabecera extends StatelessWidget {
  const _Cabecera({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    this.accion,
  });

  final IconData icono;
  final String titulo;
  final String descripcion;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icono, color: scheme.secondary),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: texto.titleMedium),
                      const SizedBox(height: 2),
                      Text(descripcion,
                          style: texto.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ),
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

class _TarjetaPlanes extends ConsumerWidget {
  const _TarjetaPlanes();

  Future<void> _nuevo(BuildContext context, WidgetRef ref) async {
    final datos = await mostrarDialogoPlan(context);
    if (datos == null) return;
    await ref.read(planesRepositoryProvider).crear(datos);
    if (context.mounted) mostrarMensaje(context, 'Plan creado: ${datos.nombre}');
  }

  Future<void> _editar(BuildContext context, WidgetRef ref, Plan plan) async {
    final datos = await mostrarDialogoPlan(context, plan: plan);
    if (datos == null) return;
    await ref.read(planesRepositoryProvider).actualizar(plan.id, datos);
    if (context.mounted) mostrarMensaje(context, 'Plan actualizado: ${datos.nombre}');
  }

  Future<void> _cambiarActivo(BuildContext context, WidgetRef ref, Plan plan, bool activo) async {
    try {
      await ref.read(planesRepositoryProvider).cambiarActivo(plan.id, activo);
      if (context.mounted) {
        mostrarMensaje(context, activo ? 'Plan activado' : 'Plan desactivado');
      }
    } on OperacionNoPermitida catch (e) {
      if (context.mounted) mostrarMensaje(context, e.mensaje);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planes = ref.watch(planesConUsoProvider);
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Cabecera(
            icono: Icons.speed,
            titulo: 'Planes de internet',
            descripcion: 'Los planes que se eligen al registrar un cliente. El precio es el '
                'sugerido: a cada cliente se le puede poner el suyo. Un plan desactivado ya no '
                'aparece para clientes nuevos, pero quien lo tiene lo conserva.',
            accion: FilledButton.icon(
              onPressed: () => _nuevo(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo plan'),
            ),
          ),
          const Divider(height: 1),
          planes.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
            ),
            error: (e, _) => ErrorVista(e),
            data: (lista) => Column(
              children: [
                for (final (plan: p, clientes: n) in lista)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          p.activo ? scheme.secondaryContainer : scheme.surfaceContainerHighest,
                      child: Icon(Icons.wifi,
                          color: p.activo ? scheme.secondary : scheme.onSurfaceVariant),
                    ),
                    title: Text(p.nombre),
                    subtitle: Text([
                      '${p.velocidadMbps} Mbps',
                      '${formatoDinero(p.precioBase)} al mes',
                      n == 0 ? 'sin clientes' : '$n cliente${n == 1 ? '' : 's'}',
                      if (!p.activo) 'desactivado',
                    ].join(' · ')),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Editar plan',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _editar(context, ref, p),
                        ),
                        Tooltip(
                          message: p.activo ? 'Desactivar plan' : 'Activar plan',
                          child: Switch(
                            value: p.activo,
                            onChanged: (v) => _cambiarActivo(context, ref, p, v),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _TarjetaContrataciones extends ConsumerWidget {
  const _TarjetaContrataciones();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personalizadas = ref.watch(contratacionesPersonalizadasProvider);
    final texto = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Cabecera(
            icono: Icons.handshake_outlined,
            titulo: 'Tipos de contratación',
            descripcion: 'Cómo se contrató el servicio. Para un acuerdo distinto elige '
                '«Otro (personalizado)» al registrar al cliente y escribe en qué consiste.',
          ),
          const Divider(height: 1),
          for (final t in TipoContratacion.values)
            ListTile(
              leading: Icon(switch (t) {
                TipoContratacion.compraEquipo => Icons.shopping_bag_outlined,
                TipoContratacion.equipoPropio => Icons.router_outlined,
                TipoContratacion.equipoPrestado => Icons.assignment_return_outlined,
                TipoContratacion.otro => Icons.edit_note,
              }),
              title: Text(t.etiqueta),
              subtitle: Text(t.descripcion),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: personalizadas.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => ErrorVista(e),
              data: (lista) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Personalizados en uso', style: texto.labelLarge),
                  const SizedBox(height: 8),
                  if (lista.isEmpty)
                    Text('Todavía no hay contrataciones personalizadas.',
                        style: texto.bodySmall?.copyWith(color: scheme.onSurfaceVariant))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final d in lista)
                          Chip(
                            avatar: const Icon(Icons.edit_note, size: 18),
                            label: Text(
                                '${d.detalle} · ${d.clientes} cliente${d.clientes == 1 ? '' : 's'}'),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
