import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/dinero.dart';
import '../../core/fechas.dart';
import '../../core/marca.dart';
import '../../data/db/database.dart';
import '../../data/repositories/clientes_repository.dart';
import '../../data/respaldos/respaldo_service.dart';
import '../../domain/dashboard.dart';
import '../../providers/providers.dart';
import '../../widgets/comunes.dart';
import '../clientes/modales.dart';
import 'graficas.dart';

/// Pantalla de inicio: resumen del negocio, gráficas y accesos rápidos.
class InicioScreen extends ConsumerWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumen = ref.watch(resumenProvider);
    final ultimoRespaldo = ref.watch(ultimoRespaldoProvider);
    // Recordatorio solo cuando ya se sabe la fecha (no mientras carga o si falla).
    final recordarRespaldo = ultimoRespaldo.when(
      data: (fecha) => necesitaRespaldo(fecha, DateTime.now()),
      loading: () => false,
      error: (_, _) => false,
    );

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        title: const MarcaNetMax(alto: 40, sobreOscuro: true, conLema: true),
        actions: [
          IconButton(
            tooltip: 'Respaldos',
            icon: const Icon(Icons.backup),
            onPressed: () => context.push('/respaldos'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: resumen.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorVista(e),
        data: (r) => _Contenido(r, recordarRespaldo: recordarRespaldo),
      ),
    );
  }
}

class _Contenido extends StatefulWidget {
  const _Contenido(this.r, {this.recordarRespaldo = false});

  final ResumenDashboard r;
  final bool recordarRespaldo;

  @override
  State<_Contenido> createState() => _ContenidoState();
}

class _ContenidoState extends State<_Contenido> {
  /// Meses que muestran las gráficas (6 o 12).
  int _meses = 12;

  List<T> _ultimos<T>(List<T> serie) =>
      serie.length <= _meses ? serie : serie.sublist(serie.length - _meses);

  @override
  Widget build(BuildContext context) {
    final r = widget.r;
    return LayoutBuilder(builder: (context, constraints) {
      const espacio = 16.0;
      // En pantallas grandes el contenido no pasa de 1240 px de ancho.
      final ancho = constraints.maxWidth > 1272 ? 1240.0 : constraints.maxWidth - 32;
      final margen = (constraints.maxWidth - ancho) / 2;
      final escritorio = ancho >= 960;
      final porFila = ancho >= 960 ? 4 : 2;
      final anchoIndicador = (ancho - espacio * (porFila - 1)) / porFila;

      final cobranza = _ultimos(r.cobranza);
      final actividad = _ultimos(r.actividad);

      final selectorMeses = SegmentedButton<int>(
        segments: const [
          ButtonSegment(value: 6, label: Text('6 meses')),
          ButtonSegment(value: 12, label: Text('12 meses')),
        ],
        selected: {_meses},
        showSelectedIcon: false,
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
        onSelectionChanged: (s) => setState(() => _meses = s.first),
      );

      final graficaCobranza = _TarjetaGrafica(
        titulo: 'Cobranza por mes',
        subtitulo: _textoCobranza(cobranza),
        accion: escritorio ? null : selectorMeses,
        child: cobranza.isEmpty
            ? const _SinDatos('Aún no hay pagos registrados.')
            : GraficaCobranza(serie: cobranza),
      );
      final graficaActividad = _TarjetaGrafica(
        titulo: 'Actividad de clientes',
        subtituloWidget: LeyendaActividad(serie: actividad),
        child: actividad.isEmpty
            ? const _SinDatos('Aún no hay movimientos de clientes.')
            : GraficaActividad(serie: actividad),
      );

      final vencimientos = _TarjetaLista(
        titulo: 'Próximos vencimientos',
        subtitulo: 'Mensualidades sin pagar que vencen en los próximos 7 días',
        vacio: 'Nada vence en los próximos 7 días.',
        filas: [
          for (final m in r.proximosVencimientos)
            ListTile(
              leading: const Icon(Icons.event),
              title: Text(m.cliente),
              subtitle: Text('${m.mes.nombre} · vence ${formatoFechaCorta(m.vencimiento)}'),
              trailing: Text(formatoDinero(m.monto - m.pagado)),
              onTap: () => abrirFichaCliente(context, m.clienteId),
            ),
        ],
      );
      final recientes = _TarjetaLista(
        titulo: 'Pagos recientes',
        subtitulo: 'Los últimos pagos registrados',
        vacio: 'Aún no hay pagos registrados.',
        filas: [
          for (final p in r.pagosRecientes)
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: Text(p.cliente),
              subtitle: Text(formatoFechaCorta(p.fecha)),
              trailing: Text(formatoDinero(p.monto)),
              onTap: () => abrirFichaCliente(context, p.clienteId),
            ),
        ],
      );

      Widget dosColumnas(Widget a, Widget b) => escritorio
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: a),
                const SizedBox(width: espacio),
                Expanded(child: b),
              ],
            )
          : Column(children: [a, const SizedBox(height: espacio), b]);

      return ListView(
        padding: EdgeInsets.symmetric(horizontal: margen, vertical: espacio),
        children: [
          if (widget.recordarRespaldo) ...[
            Card(
              margin: EdgeInsets.zero,
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('Haz un respaldo de tu información'),
                subtitle: const Text('No hay un respaldo de los últimos 7 días.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/respaldos'),
              ),
            ),
            const SizedBox(height: espacio),
          ],
          _Encabezado(r: r, selectorMeses: escritorio ? selectorMeses : null),
          const SizedBox(height: espacio),
          Wrap(
            spacing: espacio,
            runSpacing: espacio,
            children: [
              for (final indicador in _indicadores(context, r))
                SizedBox(width: anchoIndicador, child: indicador),
            ],
          ),
          const SizedBox(height: espacio),
          dosColumnas(graficaCobranza, graficaActividad),
          const SizedBox(height: espacio),
          dosColumnas(vencimientos, recientes),
          const SizedBox(height: 24),
        ],
      );
    });
  }

  String _textoCobranza(List<CobranzaMes> serie) {
    if (serie.isEmpty) return '';
    final total = serie.fold<int>(0, (s, c) => s + c.total);
    final promedio = total ~/ serie.length;
    return 'Total ${formatoDinero(total)} · promedio ${formatoDinero(promedio)} al mes';
  }

  List<Widget> _indicadores(BuildContext context, ResumenDashboard r) {
    final scheme = Theme.of(context).colorScheme;

    // Variación de lo cobrado contra el mes anterior.
    _Variacion? variacion;
    if (r.cobranza.length >= 2) {
      final anterior = r.cobranza[r.cobranza.length - 2];
      if (anterior.total > 0) {
        final cambio = ((r.cobradoMes - anterior.total) * 100 / anterior.total).round();
        final nombre = anterior.mes.nombreCorto.split(' ').first;
        variacion = _Variacion(
          texto: '${cambio >= 0 ? '+' : ''}$cambio% vs $nombre (a la fecha)',
          sube: cambio >= 0,
        );
      }
    }
    final altasMes = r.actividad.isEmpty ? 0 : r.actividad.last.altas;
    final porcentaje = (r.avanceMes * 100).round();

    return [
      _Indicador(
        icono: Icons.payments,
        etiqueta: 'Cobrado en ${r.mes.nombre}',
        valor: formatoDinero(r.cobradoMes),
        detalle: '${r.pagosMes} ${r.pagosMes == 1 ? 'pago recibido' : 'pagos recibidos'}',
        variacion: variacion,
        onTap: () => context.push('/reportes/comprobantes'),
        ayuda: 'Ver comprobantes de pago',
      ),
      _Indicador(
        icono: Icons.money_off,
        etiqueta: 'Por cobrar (vencido)',
        valor: formatoDinero(r.porCobrar),
        detalle: r.clientesConAdeudo == 0
            ? 'Todos al corriente'
            : '${r.clientesConAdeudo} '
                '${r.clientesConAdeudo == 1 ? 'cliente con adeudo' : 'clientes con adeudo'}',
        iconoDetalle: r.clientesConAdeudo == 0 ? Icons.check_circle : Icons.warning_amber,
        colorDetalle: r.clientesConAdeudo == 0 ? Colors.green : scheme.error,
        onTap: () => context.go('/adeudos'),
        ayuda: 'Ver adeudos',
      ),
      _Indicador(
        icono: Icons.people,
        etiqueta: 'Clientes activos',
        valor: '${r.activos}',
        detalle: '${r.suspendidos} ${r.suspendidos == 1 ? 'suspendido' : 'suspendidos'} · '
            '${r.cancelados} ${r.cancelados == 1 ? 'cancelado' : 'cancelados'}',
        variacion: altasMes == 0
            ? null
            : _Variacion(
                texto: '+$altasMes ${altasMes == 1 ? 'alta' : 'altas'} este mes', sube: true),
        onTap: () => context.go('/clientes'),
        ayuda: 'Ver clientes',
      ),
      _Indicador(
        icono: Icons.donut_large,
        etiqueta: 'Mensualidades de ${r.mes.nombre}',
        valor: r.esperadoMes == 0 ? '—' : '$porcentaje%',
        detalle: r.esperadoMes == 0
            ? 'Aún no hay mensualidades este mes'
            : '${formatoDinero(r.cubiertoMes)} de ${formatoDinero(r.esperadoMes)}',
        medidor: r.esperadoMes == 0 ? null : r.avanceMes,
      ),
    ];
  }
}

// ---------------------------------------------------------------------------
// Encabezado con acciones rápidas
// ---------------------------------------------------------------------------

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.r, this.selectorMeses});

  final ResumenDashboard r;
  final Widget? selectorMeses;

  Future<void> _registrarPago(BuildContext context) async {
    final id = await showDialog<int>(context: context, builder: (_) => const _SelectorCliente());
    if (id != null && context.mounted) await registrarPagoConComprobante(context, id);
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final hoy = DateTime.now();
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumen del negocio', style: texto.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
            Text('Hoy es ${formatoFechaCorta(hoy)}',
                style: texto.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: () => _registrarPago(context),
              icon: const Icon(Icons.payments),
              label: const Text('Registrar pago'),
            ),
            OutlinedButton.icon(
              onPressed: () => nuevoCliente(context),
              icon: const Icon(Icons.person_add),
              label: const Text('Nuevo cliente'),
            ),
            ?selectorMeses,
          ],
        ),
      ],
    );
  }
}

/// Diálogo para elegir a quién se le registra un pago.
class _SelectorCliente extends ConsumerStatefulWidget {
  const _SelectorCliente();

  @override
  ConsumerState<_SelectorCliente> createState() => _SelectorClienteState();
}

class _SelectorClienteState extends ConsumerState<_SelectorCliente> {
  String _busqueda = '';

  @override
  Widget build(BuildContext context) {
    final clientes = ref.watch(clientesProvider(FiltroClientes(busqueda: _busqueda)));
    return AlertDialog(
      title: const Text('¿Quién paga?'),
      content: SizedBox(
        width: 460,
        height: 420,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar por nombre, teléfono o zona',
              ),
              onChanged: (v) => setState(() => _busqueda = v),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: clientes.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => ErrorVista(e),
                data: (lista) {
                  final vigentes =
                      lista.where((c) => c.estado != EstadoCliente.cancelado).toList();
                  if (vigentes.isEmpty) {
                    return const Center(child: Text('No se encontraron clientes.'));
                  }
                  return ListView.builder(
                    itemCount: vigentes.length,
                    itemBuilder: (context, i) {
                      final c = vigentes[i];
                      return ListTile(
                        title: Text(c.nombre),
                        subtitle: Text([
                          if (c.zona != null) c.zona!,
                          formatoDinero(c.precioMensual),
                        ].join(' · ')),
                        trailing: c.estado == EstadoCliente.activo ? null : EstadoChip(c.estado),
                        onTap: () => Navigator.of(context).pop(c.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Piezas
// ---------------------------------------------------------------------------

class _Variacion {
  const _Variacion({required this.texto, required this.sube});

  final String texto;
  final bool sube;
}

/// Indicador (stat tile): etiqueta, valor grande, detalle y, opcionalmente,
/// variación o medidor. Al pasar el mouse se resalta y se puede abrir.
class _Indicador extends StatelessWidget {
  const _Indicador({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    required this.detalle,
    this.iconoDetalle,
    this.colorDetalle,
    this.variacion,
    this.medidor,
    this.onTap,
    this.ayuda,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;
  final String detalle;
  final IconData? iconoDetalle;
  final Color? colorDetalle;
  final _Variacion? variacion;
  final double? medidor;
  final VoidCallback? onTap;
  final String? ayuda;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final tarjeta = Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: ColoresNetMax.verde.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(etiqueta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: texto.labelLarge?.copyWith(color: scheme.onSurfaceVariant)),
                  ),
                  Icon(icono, size: 20, color: ColoresNetMax.verde),
                ],
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(valor,
                    style: texto.headlineMedium?.copyWith(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 4),
              if (medidor != null) ...[
                Semantics(
                  label: 'Avance de cobro del mes',
                  value: valor,
                  child: LinearProgressIndicator(
                    value: medidor,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    color: scheme.primary,
                    backgroundColor: scheme.primaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Row(
                children: [
                  if (iconoDetalle != null) ...[
                    Icon(iconoDetalle, size: 16, color: colorDetalle),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Text(detalle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: texto.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                  ),
                ],
              ),
              if (variacion != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      variacion!.sube ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: variacion!.sube ? ColoresNetMax.verde : scheme.error,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(variacion!.texto,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: texto.bodySmall?.copyWith(
                              color: scheme.onSurface, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
    return ayuda == null ? tarjeta : Tooltip(message: ayuda!, child: tarjeta);
  }
}

class _TarjetaGrafica extends StatelessWidget {
  const _TarjetaGrafica({
    required this.titulo,
    this.subtitulo,
    this.subtituloWidget,
    this.accion,
    required this.child,
  });

  final String titulo;
  final String? subtitulo;
  final Widget? subtituloWidget;
  final Widget? accion;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text(titulo, style: texto.titleMedium),
                ?accion,
              ],
            ),
            const SizedBox(height: 4),
            if (subtitulo != null && subtitulo!.isNotEmpty)
              Text(subtitulo!,
                  style: texto.bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ?subtituloWidget,
            const SizedBox(height: 16),
            SizedBox(height: 240, child: child),
          ],
        ),
      ),
    );
  }
}

class _TarjetaLista extends StatelessWidget {
  const _TarjetaLista({
    required this.titulo,
    required this.subtitulo,
    required this.vacio,
    required this.filas,
  });

  final String titulo;
  final String subtitulo;
  final String vacio;
  final List<Widget> filas;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: texto.titleMedium),
                Text(subtitulo,
                    style: texto.bodySmall
                        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          if (filas.isEmpty)
            Padding(padding: const EdgeInsets.all(16), child: Text(vacio, style: texto.bodySmall))
          else
            ...filas,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SinDatos extends StatelessWidget {
  const _SinDatos(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Center(
        child: Text(texto, style: Theme.of(context).textTheme.bodySmall),
      );
}
