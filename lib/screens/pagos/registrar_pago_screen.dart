import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dinero.dart';
import '../../core/etiquetas.dart';
import '../../core/fechas.dart';
import '../../data/db/database.dart';
import '../../data/repositories/pagos_repository.dart';
import '../../domain/clientes.dart';
import '../../domain/cobranza.dart';
import '../../providers/providers.dart';
import '../../widgets/comunes.dart';
import '../../widgets/disposicion.dart';

/// Registrar un pago de un cliente, con vista previa de cómo se reparte.
class RegistrarPagoScreen extends ConsumerWidget {
  const RegistrarPagoScreen({super.key, required this.clienteId});

  final int clienteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cliente = ref.watch(clienteProvider(clienteId));
    final periodos = ref.watch(periodosProvider(clienteId));
    final cargos = ref.watch(cargosProvider(clienteId));

    Widget cuerpo;
    if (cliente.hasError) {
      cuerpo = ErrorVista(cliente.error!);
    } else if (periodos.hasError) {
      cuerpo = ErrorVista(periodos.error!);
    } else if (cargos.hasError) {
      cuerpo = ErrorVista(cargos.error!);
    } else if (!cliente.hasValue || !periodos.hasValue || !cargos.hasValue) {
      cuerpo = const Center(child: CircularProgressIndicator());
    } else if (cliente.requireValue == null) {
      cuerpo = const Center(child: Text('El cliente no existe.'));
    } else {
      cuerpo = _FormularioPago(
        cliente: cliente.requireValue!,
        periodos: periodos.requireValue,
        cargos: cargos.requireValue,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar pago')),
      body: cuerpo,
    );
  }
}

class _FormularioPago extends ConsumerStatefulWidget {
  const _FormularioPago({
    required this.cliente,
    required this.periodos,
    required this.cargos,
  });

  final Cliente cliente;
  final List<PeriodoSaldo> periodos;
  final List<CargoSaldo> cargos;

  @override
  ConsumerState<_FormularioPago> createState() => _FormularioPagoState();
}

class _FormularioPagoState extends ConsumerState<_FormularioPago> {
  final _monto = TextEditingController();
  final _folio = TextEditingController();
  final _notas = TextEditingController();
  DateTime _fecha = soloFecha(DateTime.now());
  MetodoPago _metodo = MetodoPago.efectivo;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    // Sugerencia: lo que debe, o una mensualidad si está al corriente.
    final adeudo =
        calcularAdeudo(widget.periodos, DateTime.now(), cargos: widget.cargos).total;
    _monto.text = _centavosATexto(adeudo > 0 ? adeudo : widget.cliente.precioMensual);
  }

  @override
  void dispose() {
    _monto.dispose();
    _folio.dispose();
    _notas.dispose();
    super.dispose();
  }

  static String _centavosATexto(int centavos) {
    final pesos = centavos ~/ 100;
    final cent = centavos % 100;
    return cent == 0 ? '$pesos' : '$pesos.${cent.toString().padLeft(2, '0')}';
  }

  /// Monto capturado en centavos, o null si no es válido.
  int? get _centavos {
    if (validarMontoObligatorio(_monto.text) != null) return null;
    return textoACentavos(_monto.text);
  }

  void _usarMonto(int centavos) => setState(() => _monto.text = _centavosATexto(centavos));

  Future<void> _elegirFecha() async {
    final f = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );
    if (f != null) setState(() => _fecha = soloFecha(f));
  }

  Future<void> _guardar(ResultadoAplicacion reparto) async {
    final monto = _centavos;
    if (monto == null) return;
    final meses = [
      if (reparto.aplicaciones.isNotEmpty)
        describirMeses(reparto.aplicaciones.map((a) => a.mes).toList()),
      for (final c in reparto.aplicacionesCargos) c.concepto,
    ].join(', ');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar pago'),
        content: Text(
          '${widget.cliente.nombre}\n'
          '${formatoDinero(monto)} en ${_metodo.etiqueta.toLowerCase()}\n'
          'Cubre: $meses',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Revisar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _guardando = true);
    try {
      final pagoId = await ref.read(pagosRepositoryProvider).registrarPago(
            widget.cliente.id,
            DatosPago(
              monto: monto,
              fecha: _fecha,
              metodo: _metodo,
              folio: textoONull(_folio.text),
              notas: textoONull(_notas.text),
            ),
          );
      if (!mounted) return;
      mostrarMensaje(context, 'Pago registrado: ${formatoDinero(monto)}');
      // Devuelve el id del pago para mostrar su comprobante (ver modales.dart).
      Navigator.of(context).pop(pagoId);
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      mostrarMensaje(context, e is PagoNoPermitido ? e.mensaje : 'No se pudo guardar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.cliente;
    final adeudo = calcularAdeudo(widget.periodos, DateTime.now(), cargos: widget.cargos);
    final hasta = pagadoHasta(widget.periodos);
    final monto = _centavos;
    final reparto = monto == null
        ? null
        : PagosRepository.previsualizar(
            cliente: c, periodos: widget.periodos, cargos: widget.cargos, monto: monto);
    final excede = reparto != null && reparto.sobrante > 0;
    final cancelado = c.estado == EstadoCliente.cancelado;
    final scheme = Theme.of(context).colorScheme;

    final resumenCliente = Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: scheme.secondaryContainer,
          child: Text(c.nombre.isEmpty ? '?' : c.nombre[0].toUpperCase(),
              style: TextStyle(color: scheme.onSecondaryContainer)),
        ),
        title: Text(c.nombre, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(
          '${formatoDinero(c.precioMensual)} al mes · vence el día ${c.diaCorte}\n'
          '${hasta == null ? 'Sin meses pagados' : 'Pagado hasta ${hasta.nombre}'}',
        ),
        isThreeLine: true,
        trailing: adeudo.tieneAdeudo
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Debe', style: Theme.of(context).textTheme.labelSmall),
                  Text(
                    formatoDinero(adeudo.total),
                    style: TextStyle(color: scheme.error, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            : const Text('Al corriente'),
      ),
    );

    final campoFecha = InkWell(
      onTap: _elegirFecha,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha de pago',
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(formatoFecha(_fecha)),
      ),
    );
    final campoMetodo = DropdownButtonFormField<MetodoPago>(
      initialValue: _metodo,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Método'),
      items: [
        for (final m in MetodoPago.values) DropdownMenuItem(value: m, child: Text(m.etiqueta)),
      ],
      onChanged: (m) {
        if (m != null) setState(() => _metodo = m);
      },
    );

    final datosPago = SeccionFormulario(
      titulo: 'Datos del pago',
      icono: Icons.payments_outlined,
      children: [
        if (cancelado)
          Text('El cliente está cancelado. Reactívalo para registrar pagos.',
              style: TextStyle(color: scheme.error)),
        TextFormField(
          controller: _monto,
          decoration: const InputDecoration(
            labelText: 'Monto recibido *',
            prefixText: '\$ ',
          ),
          style: Theme.of(context).textTheme.titleLarge,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validarMontoObligatorio,
          onChanged: (_) => setState(() {}),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            if (adeudo.tieneAdeudo)
              ActionChip(
                label: Text('Lo que debe (${formatoDinero(adeudo.total)})'),
                onPressed: () => _usarMonto(adeudo.total),
              ),
            for (final n in [1, 2, 3, 6, 12])
              ActionChip(
                label: Text('$n ${n == 1 ? 'mes' : 'meses'}'),
                onPressed: () => _usarMonto(n * c.precioMensual),
              ),
          ],
        ),
        FilaCampos(izquierda: campoFecha, derecha: campoMetodo),
        TextField(
          controller: _folio,
          decoration: const InputDecoration(labelText: 'Folio o referencia (opcional)'),
        ),
        TextField(
          controller: _notas,
          decoration: const InputDecoration(labelText: 'Notas (opcional)'),
          maxLines: 2,
        ),
      ],
    );

    final aplicacion = SeccionFormulario(
      titulo: 'Así se aplicará el pago',
      icono: Icons.fact_check_outlined,
      children: [
        if (reparto == null)
          const Text('Escribe un monto válido para ver el reparto.')
        else if (excede)
          Text(
            'El monto cubre más de ${PagosRepository.maxMesesAdelantados} meses '
            'adelantados. Revisa la cantidad.',
            style: TextStyle(color: scheme.error),
          )
        else
          _VistaPrevia(reparto),
        FilledButton.icon(
          onPressed: (reparto == null || excede || cancelado || _guardando)
              ? null
              : () => _guardar(reparto),
          icon: _guardando
              ? const SizedBox.square(
                  dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.payments),
          label: const Text('Registrar pago'),
        ),
      ],
    );

    return LayoutBuilder(builder: (context, limites) {
      // En pantallas anchas: datos a la izquierda y el reparto a la derecha.
      if (limites.maxWidth >= 900) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ContenidoCentrado(
            anchoMaximo: 1100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: Column(children: [resumenCliente, datosPago])),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: aplicacion),
              ],
            ),
          ),
        );
      }
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ContenidoCentrado(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [resumenCliente, datosPago, aplicacion],
            ),
          ),
        ],
      );
    });
  }
}

class _VistaPrevia extends StatelessWidget {
  const _VistaPrevia(this.reparto);

  final ResultadoAplicacion reparto;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Column(
        children: [
          for (final c in reparto.aplicacionesCargos)
            ListTile(
              dense: true,
              leading: Icon(
                c.completo ? Icons.check_circle : Icons.timelapse,
                color: c.completo ? Colors.green : Colors.orange,
              ),
              title: Text(c.concepto),
              subtitle: Text(c.completo
                  ? 'Cargo extra · liquidado'
                  : 'Cargo extra · abono, faltan ${formatoDinero(c.saldoAntes - c.monto)}'),
              trailing: Text(formatoDinero(c.monto)),
            ),
          for (final a in reparto.aplicaciones)
            ListTile(
              dense: true,
              leading: Icon(
                a.completo ? Icons.check_circle : Icons.timelapse,
                color: a.completo ? Colors.green : Colors.orange,
              ),
              title: Text(a.mes.nombreCorto),
              subtitle: Text([
                if (a.esNuevo) 'Adelantado',
                a.completo
                    ? 'Mes completo'
                    : 'Abono, faltan ${formatoDinero(a.saldoAntes - a.monto)}',
              ].join(' · ')),
              trailing: Text(formatoDinero(a.monto)),
            ),
        ],
      ),
    );
  }
}
