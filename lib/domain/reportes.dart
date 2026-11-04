/// Cálculos de los reportes (lógica pura, sin base de datos ni pantallas).
library;

import '../core/mes.dart';
import '../data/db/enums.dart';

/// Un pago vigente con lo que cubrió, para los reportes.
class FilaPago {
  const FilaPago({
    required this.fecha,
    required this.cliente,
    required this.monto,
    required this.metodo,
    this.folio,
    this.cubre = '',
  });

  final DateTime fecha;
  final String cliente;
  final int monto;
  final MetodoPago metodo;
  final String? folio;

  /// Descripción de lo que cubrió: "oct 2026 – dic 2026, Antena no devuelta".
  final String cubre;
}

/// Ingresos de un mes: total, número de pagos y total por método.
class IngresoMes {
  const IngresoMes({
    required this.mes,
    required this.total,
    required this.pagos,
    required this.porMetodo,
  });

  final Mes mes;
  final int total;
  final int pagos;
  final Map<MetodoPago, int> porMetodo;
}

/// Agrupa los pagos por el mes en que se recibieron, de [desde] a [hasta]
/// (incluidos). Devuelve un renglón por mes aunque no haya pagos.
List<IngresoMes> ingresosPorMes(List<FilaPago> pagos, Mes desde, Mes hasta) {
  final resultado = <IngresoMes>[];
  for (var m = desde; m.compareTo(hasta) <= 0; m = m.siguiente()) {
    var total = 0;
    var cuantos = 0;
    final porMetodo = {for (final metodo in MetodoPago.values) metodo: 0};
    for (final p in pagos) {
      if (Mes.deFecha(p.fecha) != m) continue;
      total += p.monto;
      cuantos++;
      porMetodo[p.metodo] = porMetodo[p.metodo]! + p.monto;
    }
    resultado.add(IngresoMes(mes: m, total: total, pagos: cuantos, porMetodo: porMetodo));
  }
  return resultado;
}

/// Suma de una lista de ingresos (para el renglón de totales).
IngresoMes totalIngresos(List<IngresoMes> meses) {
  final porMetodo = {for (final metodo in MetodoPago.values) metodo: 0};
  var total = 0;
  var pagos = 0;
  for (final m in meses) {
    total += m.total;
    pagos += m.pagos;
    for (final metodo in MetodoPago.values) {
      porMetodo[metodo] = porMetodo[metodo]! + (m.porMetodo[metodo] ?? 0);
    }
  }
  return IngresoMes(
    mes: meses.isEmpty ? Mes.deFecha(DateTime.now()) : meses.first.mes,
    total: total,
    pagos: pagos,
    porMetodo: porMetodo,
  );
}

/// Un cliente en el reporte de clientes.
class FilaCliente {
  const FilaCliente({
    required this.nombre,
    this.zona,
    this.telefono,
    required this.precioMensual,
    required this.diaCorte,
    required this.estado,
    this.pagadoHasta,
    required this.adeudo,
  });

  final String nombre;
  final String? zona;
  final String? telefono;
  final int precioMensual;
  final int diaCorte;
  final EstadoCliente estado;
  final Mes? pagadoHasta;
  final int adeudo;
}
