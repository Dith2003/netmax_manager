import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/dinero.dart';
import '../../core/etiquetas.dart';
import '../../core/fechas.dart';
import '../../data/db/database.dart';
import '../../domain/clientes.dart';
import '../../domain/cobranza.dart';
import '../../providers/providers.dart';
import '../../widgets/comunes.dart';
import 'dialogos.dart';

/// Ficha del cliente: datos, estado, instalaciones, equipos e historial.
class ClienteDetalleScreen extends ConsumerWidget {
  const ClienteDetalleScreen({super.key, required this.clienteId});

  final int clienteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cliente = ref.watch(clienteProvider(clienteId));

    return cliente.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(appBar: AppBar(), body: ErrorVista(e)),
      data: (c) {
        if (c == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('El cliente no existe.')),
          );
        }
        return _Ficha(cliente: c);
      },
    );
  }
}

class _Ficha extends ConsumerWidget {
  const _Ficha({required this.cliente});

  final Cliente cliente;

  Future<void> _cambiarEstado(BuildContext context, WidgetRef ref, EstadoCliente nuevo) async {
    final motivo = await confirmarCambioEstado(
      context,
      nombreCliente: cliente.nombre,
      nuevo: nuevo,
    );
    if (motivo == null) return;
    await ref
        .read(clientesRepositoryProvider)
        .cambiarEstado(cliente.id, nuevo, motivo: motivo.isEmpty ? null : motivo);
    if (context.mounted) mostrarMensaje(context, 'Estado: ${nuevo.etiqueta}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planes = ref.watch(planesProvider);
    final nombrePlan = planes.when(
      data: (lista) {
        for (final p in lista) {
          if (p.id == cliente.planId) return p.nombre;
        }
        return '—';
      },
      loading: () => '…',
      error: (_, _) => '—',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(cliente.nombre),
        actions: [
          IconButton(
            tooltip: 'Editar',
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/clientes/${cliente.id}/editar'),
          ),
          PopupMenuButton<EstadoCliente>(
            tooltip: 'Cambiar estado',
            onSelected: (nuevo) => _cambiarEstado(context, ref, nuevo),
            itemBuilder: (_) => [
              if (cliente.estado != EstadoCliente.activo)
                const PopupMenuItem(value: EstadoCliente.activo, child: Text('Reactivar')),
              if (cliente.estado == EstadoCliente.activo)
                const PopupMenuItem(value: EstadoCliente.suspendido, child: Text('Suspender')),
              if (cliente.estado != EstadoCliente.cancelado)
                const PopupMenuItem(
                    value: EstadoCliente.cancelado, child: Text('Cancelar servicio')),
            ],
          ),
        ],
      ),
      floatingActionButton: cliente.estado == EstadoCliente.cancelado
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.push('/clientes/${cliente.id}/pago'),
              icon: const Icon(Icons.payments),
              label: const Text('Registrar pago'),
            ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          _AvisoEquipoPrestado(cliente: cliente),
          Card(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          formatoDinero(cliente.precioMensual),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      EstadoChip(cliente.estado),
                    ],
                  ),
                  Text('al mes · vence el día ${cliente.diaCorte}'),
                  const Divider(height: 24),
                  _Dato('Plan', nombrePlan),
                  _Dato('Contratación', cliente.tipoContratacion.etiqueta),
                  _Dato('Teléfono', cliente.telefono),
                  _Dato('Dirección', cliente.direccion),
                  _Dato('Zona', cliente.zona),
                  _Dato('Referencia', cliente.referencia),
                  _Dato('Alta', formatoFechaCorta(cliente.fechaAlta)),
                  _Dato('Notas', cliente.notas),
                ],
              ),
            ),
          ),
          _SeccionPagos(cliente: cliente),
          _SeccionInstalaciones(clienteId: cliente.id),
          _SeccionEquipos(cliente: cliente),
          _SeccionHistorial(clienteId: cliente.id),
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato(this.etiqueta, this.valor);

  final String etiqueta;
  final String? valor;

  @override
  Widget build(BuildContext context) {
    if (valor == null || valor!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(etiqueta, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(child: Text(valor!)),
        ],
      ),
    );
  }
}

/// Aviso si el cliente tiene equipo prestado y no hay equipo de NetMAX registrado.
class _AvisoEquipoPrestado extends ConsumerWidget {
  const _AvisoEquipoPrestado({required this.cliente});

  final Cliente cliente;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipos = ref.watch(equiposProvider(cliente.id));
    final instalados = equipos.when(
      data: (l) => l
          .where((e) => e.propiedad == PropiedadEquipo.netmax && e.fechaRetiro == null)
          .length,
      loading: () => -1,
      error: (_, _) => -1,
    );
    if (instalados < 0 ||
        !faltaRegistrarEquipoPrestado(
          esEquipoPrestado: cliente.tipoContratacion == TipoContratacion.equipoPrestado,
          equiposNetmaxInstalados: instalados,
        )) {
      return const SizedBox.shrink();
    }
    return MaterialBanner(
      leading: const Icon(Icons.warning_amber),
      content: const Text(
        'Este cliente tiene equipo prestado, pero no hay equipo de NetMAX registrado. '
        'Regístralo para poder recuperarlo si cancela.',
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final datos = await mostrarDialogoEquipo(
              context,
              propiedadSugerida: PropiedadEquipo.netmax,
            );
            if (datos != null) {
              await ref.read(clientesRepositoryProvider).agregarEquipo(cliente.id, datos);
            }
          },
          child: const Text('Registrar equipo'),
        ),
      ],
    );
  }
}

class _SeccionPagos extends ConsumerWidget {
  const _SeccionPagos({required this.cliente});

  final Cliente cliente;

  Future<void> _cancelar(BuildContext context, WidgetRef ref, Pago pago) async {
    final motivo = await confirmarCancelarPago(context, monto: formatoDinero(pago.monto));
    if (motivo == null) return;
    await ref
        .read(pagosRepositoryProvider)
        .cancelarPago(pago.id, motivo: motivo.isEmpty ? null : motivo);
    if (context.mounted) mostrarMensaje(context, 'Pago cancelado');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodos = ref.watch(periodosProvider(cliente.id));
    final pagos = ref.watch(pagosProvider(cliente.id));
    final scheme = Theme.of(context).colorScheme;

    final resumen = periodos.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => ErrorVista(e),
      data: (lista) {
        final hasta = pagadoHasta(lista);
        final adeudo = calcularAdeudo(lista, DateTime.now());
        return ListTile(
          leading: Icon(
            adeudo.tieneAdeudo ? Icons.warning_amber : Icons.verified,
            color: adeudo.tieneAdeudo ? scheme.error : Colors.green,
          ),
          title: Text(hasta == null ? 'Sin meses pagados' : 'Pagado hasta ${hasta.nombre}'),
          subtitle: Text(adeudo.tieneAdeudo
              ? 'Debe ${formatoDinero(adeudo.total)} '
                  '(${adeudo.meses} ${adeudo.meses == 1 ? 'mes vencido' : 'meses vencidos'})'
              : 'Al corriente'),
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SeccionTitulo('Pagos'),
        resumen,
        pagos.when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) => ErrorVista(e),
          data: (lista) {
            if (lista.isEmpty) return const _Vacio('Sin pagos registrados');
            return Column(
              children: [
                for (final p in lista)
                  ListTile(
                    leading: Icon(
                      p.pago.cancelado ? Icons.block : Icons.receipt_long,
                      color: p.pago.cancelado ? scheme.outline : null,
                    ),
                    title: Text(
                      '${formatoDinero(p.pago.monto)} · ${p.pago.metodo.etiqueta}',
                      style: p.pago.cancelado
                          ? const TextStyle(decoration: TextDecoration.lineThrough)
                          : null,
                    ),
                    subtitle: Text([
                      formatoFechaCorta(p.pago.fechaPago),
                      if (p.meses.isNotEmpty)
                        'Cubre ${describirMeses(p.meses.map((m) => m.mes).toList())}',
                      if (p.pago.folio != null) 'Folio ${p.pago.folio}',
                      if (p.pago.cancelado) 'CANCELADO',
                    ].join(' · ')),
                    trailing: p.pago.cancelado
                        ? null
                        : PopupMenuButton<String>(
                            tooltip: 'Opciones',
                            onSelected: (_) => _cancelar(context, ref, p.pago),
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'cancelar', child: Text('Cancelar pago')),
                            ],
                          ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SeccionInstalaciones extends ConsumerWidget {
  const _SeccionInstalaciones({required this.clienteId});

  final int clienteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instalaciones = ref.watch(instalacionesProvider(clienteId));
    final repo = ref.read(clientesRepositoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SeccionTitulo(
          'Instalaciones',
          accion: TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Agregar'),
            onPressed: () async {
              final datos = await mostrarDialogoInstalacion(context);
              if (datos != null) await repo.agregarInstalacion(clienteId, datos);
            },
          ),
        ),
        instalaciones.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => ErrorVista(e),
          data: (lista) {
            if (lista.isEmpty) return const _Vacio('Sin instalaciones registradas');
            return Column(
              children: [
                for (final i in lista)
                  ListTile(
                    leading: const Icon(Icons.construction),
                    title: Text(formatoFechaCorta(i.fecha)),
                    subtitle: Text([
                      if (i.costo > 0) formatoDinero(i.costo),
                      if (i.tecnico != null) 'Técnico: ${i.tecnico}',
                      if (i.notas != null) i.notas!,
                    ].join(' · ')),
                    trailing: i.costo > 0
                        ? FilterChip(
                            label: Text(i.pagado ? 'Pagada' : 'Pendiente'),
                            selected: i.pagado,
                            onSelected: (v) => repo.marcarInstalacionPagada(i.id, v),
                          )
                        : null,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SeccionEquipos extends ConsumerWidget {
  const _SeccionEquipos({required this.cliente});

  final Cliente cliente;

  Future<void> _retirar(BuildContext context, WidgetRef ref, Equipo e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar retiro'),
        content: Text('¿Se retiró "${e.tipo}" del domicilio del cliente hoy?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sí, se retiró'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref
          .read(clientesRepositoryProvider)
          .registrarRetiro(e.id, soloFecha(DateTime.now()));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipos = ref.watch(equiposProvider(cliente.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SeccionTitulo(
          'Equipos',
          accion: TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Agregar'),
            onPressed: () async {
              final datos = await mostrarDialogoEquipo(
                context,
                propiedadSugerida:
                    cliente.tipoContratacion == TipoContratacion.equipoPrestado
                        ? PropiedadEquipo.netmax
                        : PropiedadEquipo.cliente,
              );
              if (datos != null) {
                await ref.read(clientesRepositoryProvider).agregarEquipo(cliente.id, datos);
              }
            },
          ),
        ),
        equipos.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => ErrorVista(e),
          data: (lista) {
            if (lista.isEmpty) return const _Vacio('Sin equipos registrados');
            return Column(
              children: [
                for (final e in lista)
                  ListTile(
                    leading: Icon(
                      e.fechaRetiro == null ? Icons.router : Icons.inventory_2_outlined,
                    ),
                    title: Text([e.tipo, if (e.marcaModelo != null) e.marcaModelo!].join(' · ')),
                    subtitle: Text([
                      e.propiedad.etiqueta,
                      if (e.numeroSerie != null) 'Serie ${e.numeroSerie}',
                      if (e.fechaEntrega != null) 'Entregado ${formatoFechaCorta(e.fechaEntrega!)}',
                      if (e.fechaRetiro != null) 'Retirado ${formatoFechaCorta(e.fechaRetiro!)}',
                    ].join(' · ')),
                    trailing: e.fechaRetiro == null
                        ? TextButton(
                            onPressed: () => _retirar(context, ref, e),
                            child: const Text('Retirar'),
                          )
                        : null,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SeccionHistorial extends ConsumerWidget {
  const _SeccionHistorial({required this.clienteId});

  final int clienteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historial = ref.watch(historialProvider(clienteId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SeccionTitulo('Historial de estados'),
        historial.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => ErrorVista(e),
          data: (lista) {
            if (lista.isEmpty) return const _Vacio('Sin movimientos');
            return Column(
              children: [
                for (final h in lista)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.history),
                    title: Text(h.estadoAnterior == null
                        ? h.estadoNuevo.etiqueta
                        : '${h.estadoAnterior!.etiqueta} → ${h.estadoNuevo.etiqueta}'),
                    subtitle: Text([
                      formatoFechaCorta(h.fecha),
                      if (h.motivo != null) h.motivo!,
                    ].join(' · ')),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Vacio extends StatelessWidget {
  const _Vacio(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(texto, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
