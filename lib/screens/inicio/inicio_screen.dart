import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/dinero.dart';
import '../../core/fechas.dart';
import '../../core/marca.dart';
import '../../data/respaldos/respaldo_service.dart';
import '../../domain/dashboard.dart';
import '../../providers/providers.dart';
import '../../widgets/comunes.dart';

/// Pantalla de inicio: resumen del negocio.
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

class _Contenido extends StatelessWidget {
  const _Contenido(this.r, {this.recordarRespaldo = false});

  final ResumenDashboard r;
  final bool recordarRespaldo;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // 3 indicadores por fila en pantallas anchas, 1 en teléfono.
      const espacio = 12.0;
      // En pantallas grandes el contenido no pasa de 1100 px de ancho.
      final ancho = (constraints.maxWidth > 1132 ? 1100.0 : constraints.maxWidth - 32);
      final margen = (constraints.maxWidth - ancho) / 2;
      final porFila = ancho >= 720 ? 3 : (ancho >= 480 ? 2 : 1);
      final anchoTarjeta = (ancho - espacio * (porFila - 1)) / porFila;

      return ListView(
        padding: EdgeInsets.symmetric(horizontal: margen, vertical: 16),
        children: [
          if (recordarRespaldo) ...[
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
          Wrap(
            spacing: espacio,
            runSpacing: espacio,
            children: [
              SizedBox(
                width: anchoTarjeta,
                child: _Indicador(
                  etiqueta: 'Cobrado en ${r.mes.nombre}',
                  valor: formatoDinero(r.cobradoMes),
                  detalle: '${r.pagosMes} ${r.pagosMes == 1 ? 'pago recibido' : 'pagos recibidos'}',
                ),
              ),
              SizedBox(
                width: anchoTarjeta,
                child: _Indicador(
                  etiqueta: 'Por cobrar (vencido)',
                  valor: formatoDinero(r.porCobrar),
                  detalle: r.clientesConAdeudo == 0
                      ? 'Todos al corriente'
                      : '${r.clientesConAdeudo} '
                          '${r.clientesConAdeudo == 1 ? 'cliente con adeudo' : 'clientes con adeudo'}',
                  icono: r.clientesConAdeudo == 0 ? Icons.check_circle : Icons.warning_amber,
                  colorIcono: r.clientesConAdeudo == 0
                      ? Colors.green
                      : Theme.of(context).colorScheme.error,
                  onTap: () => context.go('/adeudos'),
                ),
              ),
              SizedBox(
                width: anchoTarjeta,
                child: _Indicador(
                  etiqueta: 'Clientes activos',
                  valor: '${r.activos}',
                  detalle: '${r.suspendidos} '
                      '${r.suspendidos == 1 ? 'suspendido' : 'suspendidos'} · '
                      '${r.cancelados} ${r.cancelados == 1 ? 'cancelado' : 'cancelados'}',
                  onTap: () => context.go('/clientes'),
                ),
              ),
            ],
          ),
          const SizedBox(height: espacio),
          _MedidorMes(r),
          const SeccionTitulo('Próximos vencimientos (7 días)'),
          if (r.proximosVencimientos.isEmpty)
            const _Vacio('Nada vence en los próximos 7 días.')
          else
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final m in r.proximosVencimientos)
                    ListTile(
                      leading: const Icon(Icons.event),
                      title: Text(m.cliente),
                      subtitle: Text(
                        '${m.mes.nombre} · vence ${formatoFechaCorta(m.vencimiento)}',
                      ),
                      trailing: Text(formatoDinero(m.monto - m.pagado)),
                      onTap: () => context.push('/clientes/${m.clienteId}'),
                    ),
                ],
              ),
            ),
          const SeccionTitulo('Pagos recientes'),
          if (r.pagosRecientes.isEmpty)
            const _Vacio('Aún no hay pagos registrados.')
          else
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final p in r.pagosRecientes)
                    ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text(p.cliente),
                      subtitle: Text(formatoFechaCorta(p.fecha)),
                      trailing: Text(formatoDinero(p.monto)),
                      onTap: () => context.push('/clientes/${p.clienteId}'),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 24),
        ],
      );
    });
  }
}

/// Indicador (stat tile): etiqueta, valor grande y una línea de detalle.
class _Indicador extends StatelessWidget {
  const _Indicador({
    required this.etiqueta,
    required this.valor,
    required this.detalle,
    this.icono,
    this.colorIcono,
    this.onTap,
  });

  final String etiqueta;
  final String valor;
  final String detalle;
  final IconData? icono;
  final Color? colorIcono;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(etiqueta,
                  style: texto.labelLarge?.copyWith(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              Text(valor,
                  style: texto.headlineMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (icono != null) ...[
                    Icon(icono, size: 16, color: colorIcono),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Text(detalle,
                        style: texto.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Medidor: cuánto de las mensualidades del mes ya está pagado.
class _MedidorMes extends StatelessWidget {
  const _MedidorMes(this.r);

  final ResumenDashboard r;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final porcentaje = (r.avanceMes * 100).round();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mensualidades de ${r.mes.nombre}',
                style: texto.labelLarge?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text(
              r.esperadoMes == 0
                  ? 'Aún no hay mensualidades este mes'
                  : '${formatoDinero(r.cubiertoMes)} de ${formatoDinero(r.esperadoMes)} · $porcentaje%',
              style: texto.titleMedium,
            ),
            const SizedBox(height: 12),
            Semantics(
              label: 'Avance de cobro del mes',
              value: '$porcentaje%',
              child: LinearProgressIndicator(
                value: r.avanceMes,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
                color: scheme.primary,
                backgroundColor: scheme.primaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              r.esperadoMes == 0
                  ? ''
                  : 'Falta ${formatoDinero(r.esperadoMes - r.cubiertoMes)} por pagar de este mes',
              style: texto.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _Vacio extends StatelessWidget {
  const _Vacio(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(texto, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
