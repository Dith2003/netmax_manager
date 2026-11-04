import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dinero.dart';
import '../../core/etiquetas.dart';
import '../../core/fechas.dart';
import '../../core/mes.dart';
import '../../data/repositories/vencimientos_repository.dart';
import '../../domain/cobranza.dart';
import '../../domain/vencimientos.dart';
import '../../providers/providers.dart';
import '../../widgets/comunes.dart';

/// Estado de cuenta: todos los meses del cliente con lo pagado y lo que falta.
/// Permite marcar cortesía, agregar un mes a mano y quitar meses sin pagos.
class EstadoCuentaScreen extends ConsumerWidget {
  const EstadoCuentaScreen({super.key, required this.clienteId});

  final int clienteId;

  Future<void> _ejecutar(BuildContext context, Future<void> Function() accion,
      String mensajeOk) async {
    try {
      await accion();
      if (context.mounted) mostrarMensaje(context, mensajeOk);
    } on OperacionNoPermitida catch (e) {
      if (context.mounted) mostrarMensaje(context, e.mensaje);
    }
  }

  Future<void> _agregarMes(
      BuildContext context, WidgetRef ref, List<PeriodoSaldo> periodos) async {
    final existentes = periodos.map((p) => p.mes).toSet();
    final hoy = Mes.deFecha(DateTime.now());
    // Opciones: desde 24 meses atrás hasta 12 meses adelante, sin los que ya existen.
    var m = hoy;
    for (var i = 0; i < 24; i++) {
      m = m.anterior();
    }
    final opciones = <Mes>[];
    for (var i = 0; i <= 36; i++, m = m.siguiente()) {
      if (!existentes.contains(m)) opciones.add(m);
    }
    final elegido = await showDialog<Mes>(
      context: context,
      builder: (context) => _DialogoAgregarMes(opciones: opciones, sugerido: hoy),
    );
    if (elegido == null || !context.mounted) return;
    await _ejecutar(
      context,
      () => ref.read(vencimientosRepositoryProvider).agregarMes(clienteId, elegido),
      'Se agregó ${elegido.nombre}',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cliente = ref.watch(clienteProvider(clienteId));
    final periodos = ref.watch(periodosProvider(clienteId));
    final nombre = cliente.when(
      data: (c) => c?.nombre ?? '',
      loading: () => '',
      error: (_, _) => '',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(nombre.isEmpty ? 'Estado de cuenta' : 'Estado de cuenta · $nombre'),
      ),
      floatingActionButton: periodos.hasValue
          ? FloatingActionButton.extended(
              onPressed: () => _agregarMes(context, ref, periodos.requireValue),
              icon: const Icon(Icons.add),
              label: const Text('Agregar mes'),
            )
          : null,
      body: periodos.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorVista(e),
        data: (lista) {
          final hoy = DateTime.now();
          final adeudo = calcularAdeudo(lista, hoy);
          final ordenados = [...lista]..sort((a, b) => b.mes.compareTo(a.mes));
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              ListTile(
                title: Text(adeudo.tieneAdeudo
                    ? 'Debe ${formatoDinero(adeudo.total)}'
                    : 'Al corriente'),
                subtitle: Text(adeudo.tieneAdeudo
                    ? '${adeudo.meses} ${adeudo.meses == 1 ? 'mes vencido' : 'meses vencidos'}'
                        ' desde ${formatoFechaCorta(adeudo.vencidoDesde!)}'
                    : 'No tiene meses vencidos'),
              ),
              const Divider(height: 1),
              if (ordenados.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Todavía no hay meses de cobro. Se generan a partir del primer mes '
                    'de cobro del cliente, o puedes agregar uno con "Agregar mes".',
                    textAlign: TextAlign.center,
                  ),
                ),
              for (final p in ordenados)
                _FilaMes(
                  periodo: p,
                  hoy: hoy,
                  onCortesia: (valor) => _ejecutar(
                    context,
                    () => ref
                        .read(vencimientosRepositoryProvider)
                        .marcarCortesia(p.id!, cortesia: valor),
                    valor
                        ? '${p.mes.nombre} marcado como cortesía'
                        : '${p.mes.nombre} se vuelve a cobrar',
                  ),
                  onQuitar: () => _ejecutar(
                    context,
                    () => ref.read(vencimientosRepositoryProvider).quitarMes(p.id!),
                    'Se quitó ${p.mes.nombre}',
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FilaMes extends StatelessWidget {
  const _FilaMes({
    required this.periodo,
    required this.hoy,
    required this.onCortesia,
    required this.onQuitar,
  });

  final PeriodoSaldo periodo;
  final DateTime hoy;
  final ValueChanged<bool> onCortesia;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    final p = periodo;
    final situacion = situacionMes(
      esCortesia: p.esCortesia,
      saldo: p.saldo,
      pagado: p.pagado,
      vencimiento: p.vencimiento,
      hoy: hoy,
    );
    final (icono, color) = switch (situacion) {
      SituacionMes.pagado => (Icons.check_circle, Colors.green),
      SituacionMes.cortesia => (Icons.card_giftcard, Colors.blue),
      SituacionMes.abonado => (Icons.timelapse, Colors.orange),
      SituacionMes.pendiente => (Icons.schedule, Colors.grey),
      SituacionMes.vencido => (Icons.error, Theme.of(context).colorScheme.error),
    };

    return ListTile(
      leading: Icon(icono, color: color),
      title: Text(p.mes.nombre),
      subtitle: Text([
        situacion.etiqueta,
        'vence ${formatoFechaCorta(p.vencimiento)}',
        if (p.pagado > 0 && !p.liquidado) 'pagado ${formatoDinero(p.pagado)}',
      ].join(' · ')),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatoDinero(p.monto),
                style: p.esCortesia
                    ? const TextStyle(decoration: TextDecoration.lineThrough)
                    : null,
              ),
              if (p.saldo > 0 && p.pagado > 0)
                Text('falta ${formatoDinero(p.saldo)}',
                    style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          PopupMenuButton<String>(
            tooltip: 'Opciones del mes',
            onSelected: (opcion) {
              switch (opcion) {
                case 'cortesia':
                  onCortesia(!p.esCortesia);
                case 'quitar':
                  onQuitar();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'cortesia',
                child: Text(p.esCortesia ? 'Quitar cortesía (sí se cobra)' : 'Marcar como cortesía'),
              ),
              if (p.pagado == 0)
                const PopupMenuItem(value: 'quitar', child: Text('Quitar este mes')),
            ],
          ),
        ],
      ),
    );
  }
}

class _DialogoAgregarMes extends StatefulWidget {
  const _DialogoAgregarMes({required this.opciones, required this.sugerido});

  final List<Mes> opciones;
  final Mes sugerido;

  @override
  State<_DialogoAgregarMes> createState() => _DialogoAgregarMesState();
}

class _DialogoAgregarMesState extends State<_DialogoAgregarMes> {
  late Mes? _mes = widget.opciones.contains(widget.sugerido)
      ? widget.sugerido
      : (widget.opciones.isEmpty ? null : widget.opciones.first);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar mes de cobro'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Úsalo para cobrar un mes que no se generó solo, por ejemplo a un cliente '
            'suspendido que sí debe pagarlo. Se cobra con el precio actual del cliente.',
          ),
          const SizedBox(height: 16),
          if (_mes == null)
            const Text('No hay meses disponibles para agregar.')
          else
            DropdownButtonFormField<Mes>(
              initialValue: _mes,
              decoration: const InputDecoration(
                labelText: 'Mes',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final m in widget.opciones)
                  DropdownMenuItem(value: m, child: Text(m.nombre)),
              ],
              onChanged: (m) => setState(() => _mes = m),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _mes == null ? null : () => Navigator.of(context).pop(_mes),
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
