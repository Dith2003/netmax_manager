/// Cálculos del resumen de inicio (lógica pura, sin base de datos ni pantallas).
library;

import '../core/mes.dart';
import '../data/db/enums.dart';

/// Un pago vigente, lo mínimo para sumar lo cobrado.
typedef PagoResumen = ({int clienteId, String cliente, DateTime fecha, int monto});

/// Un mes de cobro con su saldo y el nombre/estado del cliente.
typedef MesResumen = ({
  int clienteId,
  String cliente,
  EstadoCliente estado,
  Mes mes,
  DateTime vencimiento,
  int monto,
  int pagado,
  bool esCortesia,
});

class ResumenDashboard {
  const ResumenDashboard({
    required this.mes,
    required this.cobradoMes,
    required this.pagosMes,
    required this.esperadoMes,
    required this.cubiertoMes,
    required this.porCobrar,
    required this.clientesConAdeudo,
    required this.clientesPorEstado,
    required this.proximosVencimientos,
    required this.pagosRecientes,
  });

  /// Mes del resumen (el mes actual).
  final Mes mes;

  /// Dinero recibido este mes (pagos vigentes con fecha en el mes).
  final int cobradoMes;

  /// Número de pagos recibidos este mes.
  final int pagosMes;

  /// Suma de las mensualidades del mes (sin cortesías).
  final int esperadoMes;

  /// Cuánto de las mensualidades del mes ya está pagado.
  final int cubiertoMes;

  /// Adeudo total de todos los clientes (meses vencidos + cargos).
  final int porCobrar;
  final int clientesConAdeudo;

  final Map<EstadoCliente, int> clientesPorEstado;

  /// Meses que vencen en los próximos días y aún tienen saldo.
  final List<MesResumen> proximosVencimientos;

  /// Últimos pagos recibidos (más reciente primero).
  final List<PagoResumen> pagosRecientes;

  int get activos => clientesPorEstado[EstadoCliente.activo] ?? 0;
  int get suspendidos => clientesPorEstado[EstadoCliente.suspendido] ?? 0;
  int get cancelados => clientesPorEstado[EstadoCliente.cancelado] ?? 0;

  /// Avance de cobro de las mensualidades del mes, de 0 a 1.
  double get avanceMes =>
      esperadoMes == 0 ? 0.0 : (cubiertoMes / esperadoMes).clamp(0.0, 1.0);
}

/// Suma lo cobrado en el mes [mes] y cuenta los pagos.
({int total, int pagos}) cobradoEnMes(List<PagoResumen> pagos, Mes mes) {
  var total = 0;
  var cuantos = 0;
  for (final p in pagos) {
    if (Mes.deFecha(p.fecha) == mes) {
      total += p.monto;
      cuantos++;
    }
  }
  return (total: total, pagos: cuantos);
}

/// Mensualidades del mes: cuánto se espera cobrar y cuánto ya está pagado.
/// Las cortesías no cuentan.
({int esperado, int cubierto}) avanceDelMes(List<MesResumen> meses, Mes mes) {
  var esperado = 0;
  var cubierto = 0;
  for (final m in meses) {
    if (m.mes != mes || m.esCortesia) continue;
    esperado += m.monto;
    cubierto += m.pagado > m.monto ? m.monto : m.pagado;
  }
  return (esperado: esperado, cubierto: cubierto);
}

/// Meses con saldo que vencen desde [hoy] hasta [dias] días después,
/// de clientes activos, ordenados por fecha de vencimiento.
List<MesResumen> proximosAVencer(List<MesResumen> meses, DateTime hoy, {int dias = 7}) {
  final desde = DateTime(hoy.year, hoy.month, hoy.day);
  final hasta = DateTime(hoy.year, hoy.month, hoy.day + dias);
  final lista = meses.where((m) {
    if (m.esCortesia || m.estado != EstadoCliente.activo) return false;
    if (m.pagado >= m.monto) return false;
    return !m.vencimiento.isBefore(desde) && !m.vencimiento.isAfter(hasta);
  }).toList()
    ..sort((a, b) {
      final f = a.vencimiento.compareTo(b.vencimiento);
      return f != 0 ? f : a.cliente.compareTo(b.cliente);
    });
  return lista;
}

/// Los [n] pagos más recientes.
List<PagoResumen> recientes(List<PagoResumen> pagos, {int n = 5}) {
  final ordenados = [...pagos]..sort((a, b) => b.fecha.compareTo(a.fecha));
  return ordenados.take(n).toList();
}
