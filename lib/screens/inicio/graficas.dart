/// Gráficas de Inicio: cobranza por mes y actividad de clientes.
///
/// Reglas (skill de visualización): una sola escala por gráfica, barras delgadas
/// con esquinas superiores redondeadas, rejilla discreta, tooltip al pasar el
/// mouse o tocar, leyenda siempre visible cuando hay varias series, y colores
/// de serie validados (incluido daltonismo): verde #0B7A54, ámbar #C97A00,
/// morado #7A5BD6. Los textos usan colores de texto, no de serie.
library;

import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/dinero.dart';
import '../../core/marca.dart';
import '../../core/mes.dart';
import '../../domain/dashboard.dart';

const colorAltas = Color(0xFF0B7A54);
const colorSuspensiones = Color(0xFFC97A00);
const colorCancelaciones = Color(0xFF7A5BD6);

/// "nov" -> "Nov"
String _mesCorto(Mes m) {
  final n = m.nombreCorto.split(' ').first;
  return n[0].toUpperCase() + n.substring(1);
}

TextStyle _estiloEje(BuildContext context) => TextStyle(
      fontFamily: 'Outfit',
      fontSize: 11,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

TextStyle _estiloTooltip({bool negrita = false}) => TextStyle(
      fontFamily: 'Outfit',
      fontSize: 12,
      color: ColoresNetMax.crema,
      fontWeight: negrita ? FontWeight.w600 : FontWeight.w400,
    );

/// Intervalo "bonito" para el eje Y.
double _intervalo(double maximo, {int marcas = 4}) {
  if (maximo <= 0) return 1;
  final bruto = maximo / marcas;
  final potencia = math.pow(10, (math.log(bruto) / math.ln10).floor()).toDouble();
  for (final f in [1, 2, 2.5, 5, 10]) {
    if (bruto <= f * potencia) return f * potencia;
  }
  return 10 * potencia;
}

FlGridData _rejilla(double intervalo) => FlGridData(
      drawVerticalLine: false,
      horizontalInterval: intervalo,
      getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFE6DED0), strokeWidth: 1),
    );

// ---------------------------------------------------------------------------
// Cobranza por mes
// ---------------------------------------------------------------------------

/// Barras: lo cobrado cada mes. El mes actual va en azul; los anteriores, en verde.
class GraficaCobranza extends StatelessWidget {
  const GraficaCobranza({super.key, required this.serie});

  final List<CobranzaMes> serie;

  @override
  Widget build(BuildContext context) {
    final maximo = serie.fold<int>(0, (m, c) => math.max(m, c.total)).toDouble();
    final intervalo = _intervalo(maximo == 0 ? 100000 : maximo);
    final techo = (maximo / intervalo).ceil() * intervalo;
    final anchoBarra = serie.length > 8 ? 14.0 : 22.0;

    return Semantics(
      label: 'Gráfica de lo cobrado por mes',
      child: BarChart(
        BarChartData(
          maxY: techo == 0 ? intervalo : techo,
          alignment: BarChartAlignment.spaceAround,
          gridData: _rejilla(intervalo),
          borderData: FlBorderData(
            show: true,
            border: const Border(bottom: BorderSide(color: ColoresNetMax.linea)),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 58,
                interval: intervalo,
                getTitlesWidget: (valor, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(formatoDineroCorto(valor.round()), style: _estiloEje(context)),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                getTitlesWidget: (valor, meta) {
                  final i = valor.toInt();
                  if (i < 0 || i >= serie.length) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(_mesCorto(serie[i].mes), style: _estiloEje(context)),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => ColoresNetMax.azul,
              tooltipBorderRadius: BorderRadius.circular(8),
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              maxContentWidth: 180,
              getTooltipItem: (grupo, _, _, _) {
                final c = serie[grupo.x];
                return BarTooltipItem(
                  '${c.mes.nombre}\n',
                  _estiloTooltip(),
                  children: [
                    TextSpan(text: formatoDinero(c.total), style: _estiloTooltip(negrita: true)),
                    TextSpan(
                      text: '\n${c.pagos} ${c.pagos == 1 ? 'pago' : 'pagos'}',
                      style: _estiloTooltip(),
                    ),
                  ],
                );
              },
            ),
          ),
          barGroups: [
            for (final (i, c) in serie.indexed)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: c.total.toDouble(),
                    width: anchoBarra,
                    color: i == serie.length - 1 ? ColoresNetMax.azul : ColoresNetMax.verde,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Actividad de clientes
// ---------------------------------------------------------------------------

/// Barras agrupadas por mes: altas, suspensiones y cancelaciones.
class GraficaActividad extends StatelessWidget {
  const GraficaActividad({super.key, required this.serie});

  final List<ActividadMes> serie;

  static const series = [
    ('Altas', colorAltas),
    ('Suspensiones', colorSuspensiones),
    ('Cancelaciones', colorCancelaciones),
  ];

  static List<int> valores(ActividadMes a) => [a.altas, a.suspensiones, a.cancelaciones];

  @override
  Widget build(BuildContext context) {
    final maximo = serie.fold<int>(0, (m, a) => math.max(m, valores(a).reduce(math.max)));
    final intervalo = math.max(1.0, _intervalo(maximo.toDouble()).ceilToDouble());
    final techo = math.max(intervalo, (maximo / intervalo).ceil() * intervalo);
    final anchoBarra = serie.length > 8 ? 5.0 : 9.0;

    return Semantics(
      label: 'Gráfica de altas, suspensiones y cancelaciones por mes',
      child: BarChart(
        BarChartData(
          maxY: techo,
          alignment: BarChartAlignment.spaceAround,
          gridData: _rejilla(intervalo),
          borderData: FlBorderData(
            show: true,
            border: const Border(bottom: BorderSide(color: ColoresNetMax.linea)),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: intervalo,
                getTitlesWidget: (valor, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text('${valor.round()}', style: _estiloEje(context)),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                getTitlesWidget: (valor, meta) {
                  final i = valor.toInt();
                  if (i < 0 || i >= serie.length) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(_mesCorto(serie[i].mes), style: _estiloEje(context)),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => ColoresNetMax.azul,
              tooltipBorderRadius: BorderRadius.circular(8),
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              maxContentWidth: 200,
              getTooltipItem: (grupo, _, rod, indice) {
                final a = serie[grupo.x];
                final (nombre, _) = series[indice];
                return BarTooltipItem(
                  '${a.mes.nombre}\n',
                  _estiloTooltip(),
                  children: [
                    TextSpan(
                      text: '$nombre: ${valores(a)[indice]}',
                      style: _estiloTooltip(negrita: true),
                    ),
                  ],
                );
              },
            ),
          ),
          barGroups: [
            for (final (i, a) in serie.indexed)
              BarChartGroupData(
                x: i,
                barsSpace: 2,
                barRods: [
                  for (final (j, (_, color)) in series.indexed)
                    BarChartRodData(
                      toY: valores(a)[j].toDouble(),
                      width: anchoBarra,
                      color: color,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Leyenda de la gráfica de actividad, con el total del periodo de cada serie.
class LeyendaActividad extends StatelessWidget {
  const LeyendaActividad({super.key, required this.serie});

  final List<ActividadMes> serie;

  @override
  Widget build(BuildContext context) {
    final totales = [0, 0, 0];
    for (final a in serie) {
      final v = GraficaActividad.valores(a);
      for (var i = 0; i < 3; i++) {
        totales[i] += v[i];
      }
    }
    final texto = Theme.of(context).textTheme;
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        for (final (i, (nombre, color)) in GraficaActividad.series.indexed)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
              ),
              const SizedBox(width: 6),
              Text(nombre, style: texto.bodySmall),
              const SizedBox(width: 4),
              Text('${totales[i]}', style: texto.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
      ],
    );
  }
}
