import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dinero.dart';
import '../../core/etiquetas.dart';
import '../../core/fechas.dart';
import '../../data/db/database.dart';
import '../../domain/clientes.dart';
import '../../domain/cobranza.dart';
import '../../domain/reportes.dart' show numeroComprobante;
import '../../domain/vencimientos.dart';
import '../../providers/providers.dart';
import '../../providers/sesion.dart';
import '../../widgets/comunes.dart';
import '../../widgets/disposicion.dart';
import '../pagos/comprobante_screen.dart';
import 'dialogos.dart';
import 'estado_cuenta_screen.dart';
import 'acciones_cliente.dart';
import 'modales.dart';

/// Ficha del cliente: datos, estado, instalaciones, equipos e historial.
class ClienteDetalleScreen extends ConsumerWidget {
  const ClienteDetalleScreen({super.key, required this.clienteId, this.enModal = false});

  final int clienteId;

  /// Si se muestra dentro de un modal (ver modales.dart): lleva botón de cerrar.
  final bool enModal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cliente = ref.watch(clienteProvider(clienteId));
    AppBar barraVacia() => AppBar(
          leading: enModal ? const _BotonCerrar() : null,
          automaticallyImplyLeading: !enModal,
        );

    return cliente.when(
      loading: () => Scaffold(
        appBar: barraVacia(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(appBar: barraVacia(), body: ErrorVista(e)),
      data: (c) {
        if (c == null) {
          return Scaffold(
            appBar: barraVacia(),
            body: const Center(child: Text('El cliente no existe.')),
          );
        }
        return _Ficha(cliente: c, enModal: enModal);
      },
    );
  }
}

class _BotonCerrar extends StatelessWidget {
  const _BotonCerrar();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Cerrar',
      icon: const Icon(Icons.close),
      onPressed: () => cerrarModal<void>(context),
    );
  }
}

class _Ficha extends ConsumerWidget {
  const _Ficha({required this.cliente, this.enModal = false});

  final Cliente cliente;
  final bool enModal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planes = ref.watch(todosLosPlanesProvider);
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
        leading: enModal ? const _BotonCerrar() : null,
        automaticallyImplyLeading: !enModal,
        title: Text(cliente.nombre),
      ),
      floatingActionButton: cliente.estado == EstadoCliente.cancelado
          ? null
          : FloatingActionButton.extended(
              onPressed: () => registrarPagoConComprobante(context, cliente.id),
              icon: const Icon(Icons.payments),
              label: const Text('Registrar pago'),
            ),
      body: ContenidoCentrado(
        anchoMaximo: 960,
        child: ListView(
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
                  const SizedBox(height: 8),
                  // Gestión del cliente a la vista (antes estaba en un menú).
                  BotonesCliente(cliente: cliente),
                  const Divider(height: 24),
                  _Dato('Plan', nombrePlan),
                  _Dato('Contratación',
                      textoContratacion(cliente.tipoContratacion, cliente.tipoContratacionDetalle)),
                  _Dato('Teléfono', cliente.telefono),
                  _Dato('Dirección', cliente.direccion),
                  _Dato('Zona', cliente.zona),
                  _Dato('Referencia', cliente.referencia),
                  _Dato('Alta', formatoFechaCorta(cliente.fechaAlta)),
                  _Dato(
                    'Cobro desde',
                    primerMesDeCobro(
                      primerMesCobro: cliente.primerMesCobro,
                      fechaAlta: cliente.fechaAlta,
                    ).nombre,
                  ),
                  _Dato('Notas', cliente.notas),
                ],
              ),
            ),
          ),
          _PestanasCliente(cliente: cliente),
        ],
      ),
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

/// Aviso si el cliente tiene equipo prestado y no hay equipo de NET_MAX registrado.
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
        'Este cliente tiene equipo prestado, pero no hay equipo de NET_MAX registrado. '
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

    final cargos = ref.watch(cargosProvider(cliente.id));
    final puedeCancelar = ref.watch(permisosProvider).cancelarPagos;
    final nombres = ref.watch(nombresUsuariosProvider);
    final resumen = periodos.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => ErrorVista(e),
      data: (lista) {
        final hasta = pagadoHasta(lista);
        final adeudo = calcularAdeudo(lista, DateTime.now(),
            cargos: cargos.when(
                data: (c) => c,
                loading: () => const <CargoSaldo>[],
                error: (_, _) => const <CargoSaldo>[]));
        return ListTile(
          leading: Icon(
            adeudo.tieneAdeudo ? Icons.warning_amber : Icons.verified,
            color: adeudo.tieneAdeudo ? scheme.error : Colors.green,
          ),
          title: Text(hasta == null ? 'Sin meses pagados' : 'Pagado hasta ${hasta.nombre}'),
          subtitle: Text(adeudo.tieneAdeudo
              ? 'Debe ${formatoDinero(adeudo.total)} (${adeudo.descripcion})'
              : 'Al corriente'),
          trailing: const Text('Estado de cuenta ›'),
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => EstadoCuentaScreen(clienteId: cliente.id),
          )),
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SeccionTitulo(
          '', // el nombre está en la pestaña
          descripcion: 'Pagos recibidos de este cliente. Toca uno para ver o descargar su '
              'comprobante.',
        ),
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
                      for (final c in p.cargos) 'Cargo: ${c.concepto}',
                      'N° ${numeroComprobante(p.pago.id)}',
                      if (p.pago.folio != null) 'Ref. ${p.pago.folio}',
                      if (p.pago.registradoPor != null &&
                          nombres[p.pago.registradoPor] != null)
                        'por ${nombres[p.pago.registradoPor]}',
                      if (p.pago.cancelado) 'CANCELADO',
                    ].join(' · ')),
                    onTap: () => abrirComprobante(context, p.pago.id),
                    trailing: PopupMenuButton<String>(
                      tooltip: 'Opciones',
                      onSelected: (opcion) => opcion == 'comprobante'
                          ? abrirComprobante(context, p.pago.id)
                          : _cancelar(context, ref, p.pago),
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                            value: 'comprobante', child: Text('Ver / descargar comprobante')),
                        if (!p.pago.cancelado && puedeCancelar)
                          const PopupMenuItem(value: 'cancelar', child: Text('Cancelar pago')),
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
          '', // el nombre está en la pestaña
          descripcion: 'Visitas para instalar el servicio en el domicilio de este cliente: '
              'fecha, técnico y costo de la instalación, y si ya la pagó.',
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

  /// Registra un cargo extra por un equipo de NET_MAX que el cliente no devolvió.
  Future<void> _cobrarNoDevuelto(BuildContext context, WidgetRef ref, Equipo e) async {
    final datos = await mostrarDialogoCargo(
      context,
      conceptoInicial:
          '${e.tipo}${e.marcaModelo == null ? '' : ' ${e.marcaModelo}'} no devuelto',
      montoInicial: e.costo,
    );
    if (datos == null) return;
    await ref.read(vencimientosRepositoryProvider).agregarCargo(
          clienteId: cliente.id,
          concepto: datos.concepto,
          monto: datos.monto,
          fecha: datos.fecha,
          equipoId: e.id,
          notas: datos.notas,
        );
    if (context.mounted) mostrarMensaje(context, 'Cargo agregado: ${datos.concepto}');
  }

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
          '', // el nombre está en la pestaña
          descripcion: 'Antenas, routers y demás equipo en el domicilio de este cliente. '
              'Si es de NET_MAX (prestado) queda registrado para recuperarlo o cobrarlo si '
              'cancela; si es del cliente, solo como referencia.',
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
                        ? PopupMenuButton<String>(
                            tooltip: 'Opciones del equipo',
                            onSelected: (opcion) => opcion == 'retirar'
                                ? _retirar(context, ref, e)
                                : _cobrarNoDevuelto(context, ref, e),
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                  value: 'retirar', child: Text('Registrar retiro')),
                              if (e.propiedad == PropiedadEquipo.netmax)
                                const PopupMenuItem(
                                    value: 'cobrar', child: Text('Cobrar equipo no devuelto')),
                            ],
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
    final nombres = ref.watch(nombresUsuariosProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SeccionTitulo(
          '', // el nombre está en la pestaña
          descripcion: 'Altas, suspensiones, reactivaciones y cancelaciones, con su motivo.',
        ),
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
                      if (nombres[h.usuarioId] != null) 'por ${nombres[h.usuarioId]}',
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

/// Pestañas de la ficha: Pagos, Instalaciones, Equipos e Historial, para que
/// cada tipo de información se vea por separado.
class _PestanasCliente extends ConsumerStatefulWidget {
  const _PestanasCliente({required this.cliente});

  final Cliente cliente;

  @override
  ConsumerState<_PestanasCliente> createState() => _PestanasClienteState();
}

class _PestanasClienteState extends ConsumerState<_PestanasCliente>
    with SingleTickerProviderStateMixin {
  late final TabController _control = TabController(length: 4, vsync: this)
    ..addListener(() {
      if (!_control.indexIsChanging) setState(() {});
    });

  @override
  void dispose() {
    _control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.cliente;
    int? cuantos<T>(AsyncValue<List<T>> v) => v.whenOrNull(data: (l) => l.length);
    String etiqueta(String nombre, int? n) => n == null || n == 0 ? nombre : '$nombre ($n)';

    final pestanas = [
      (Icons.payments_outlined, etiqueta('Pagos', cuantos(ref.watch(pagosProvider(c.id))))),
      (
        Icons.construction,
        etiqueta('Instalaciones', cuantos(ref.watch(instalacionesProvider(c.id))))
      ),
      (Icons.router_outlined, etiqueta('Equipos', cuantos(ref.watch(equiposProvider(c.id))))),
      (Icons.history, 'Historial'),
    ];
    final contenido = switch (_control.index) {
      0 => _SeccionPagos(cliente: c),
      1 => _SeccionInstalaciones(clienteId: c.id),
      2 => _SeccionEquipos(cliente: c),
      _ => _SeccionHistorial(clienteId: c.id),
    };
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: scheme.surfaceContainerLow,
            child: TabBar(
              controller: _control,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: scheme.secondary,
              unselectedLabelColor: scheme.onSurfaceVariant,
              indicatorColor: scheme.secondary,
              tabs: [
                for (final (icono, texto) in pestanas)
                  Tab(
                    height: 52,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Icon(icono, size: 20), const SizedBox(width: 8), Text(texto)],
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: KeyedSubtree(
              key: ValueKey(_control.index),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: contenido,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
