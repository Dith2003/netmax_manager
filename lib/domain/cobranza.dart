/// Reglas de cobranza de NetMAX (lógica pura, sin base de datos ni pantallas).
///
/// - Cada mes de servicio de un cliente es un periodo con su propio monto.
/// - Un pago se aplica siempre al periodo pendiente MÁS ANTIGUO primero.
/// - Si sobra dinero, se crean los meses siguientes (pago adelantado).
/// - Los meses de cortesía no generan saldo.
/// - Adeudo = saldo de los periodos cuya fecha de vencimiento ya pasó.
library;

import '../core/mes.dart';

class PeriodoSaldo {
  /// Id en la base de datos; null si el periodo todavía no existe.
  final int? id;
  final Mes mes;
  final DateTime vencimiento;
  final int monto;
  final int pagado;
  final bool esCortesia;

  const PeriodoSaldo({
    this.id,
    required this.mes,
    required this.vencimiento,
    required this.monto,
    this.pagado = 0,
    this.esCortesia = false,
  });

  /// Lo que falta pagar de este mes (nunca negativo).
  int get saldo {
    if (esCortesia) return 0;
    final s = monto - pagado;
    return s > 0 ? s : 0;
  }

  bool get liquidado => saldo == 0;
}

class Aplicacion {
  final Mes mes;

  /// Id del periodo existente, o null si el periodo es nuevo.
  final int? periodoId;
  final int monto;

  const Aplicacion({required this.mes, this.periodoId, required this.monto});

  @override
  String toString() => 'Aplicacion($mes, id: $periodoId, monto: $monto)';
}

class ResultadoAplicacion {
  /// En qué meses se reparte el pago y cuánto a cada uno.
  final List<Aplicacion> aplicaciones;

  /// Periodos que hay que crear en la base de datos (pago adelantado).
  final List<PeriodoSaldo> periodosNuevos;

  /// Dinero que no se pudo aplicar (solo si se rebasa [maxPeriodosNuevos]).
  final int sobrante;

  const ResultadoAplicacion({
    required this.aplicaciones,
    required this.periodosNuevos,
    required this.sobrante,
  });
}

/// Reparte un pago de [monto] centavos entre los periodos del cliente.
///
/// [periodos]: todos los periodos existentes del cliente (cualquier orden).
/// [precioMensual] y [diaCorte]: se usan para crear los meses nuevos.
/// [primerMes]: mes con el que empezar si el cliente aún no tiene periodos.
ResultadoAplicacion aplicarPago({
  required int monto,
  required List<PeriodoSaldo> periodos,
  required int precioMensual,
  required int diaCorte,
  required Mes primerMes,
  int maxPeriodosNuevos = 24,
}) {
  if (monto <= 0) {
    throw ArgumentError.value(monto, 'monto', 'debe ser mayor a 0');
  }
  if (precioMensual <= 0) {
    throw ArgumentError.value(precioMensual, 'precioMensual', 'debe ser mayor a 0');
  }

  final ordenados = [...periodos]..sort((a, b) => a.mes.compareTo(b.mes));
  final aplicaciones = <Aplicacion>[];
  var restante = monto;

  // 1. Cubrir lo pendiente, del más antiguo al más reciente.
  for (final p in ordenados) {
    if (restante == 0) break;
    final saldo = p.saldo;
    if (saldo == 0) continue;
    final aplicado = saldo < restante ? saldo : restante;
    aplicaciones.add(Aplicacion(mes: p.mes, periodoId: p.id, monto: aplicado));
    restante -= aplicado;
  }

  // 2. Si sobra, crear los meses siguientes (pago adelantado).
  final nuevos = <PeriodoSaldo>[];
  var siguiente = ordenados.isEmpty ? primerMes : ordenados.last.mes.siguiente();
  while (restante > 0 && nuevos.length < maxPeriodosNuevos) {
    final aplicado = precioMensual < restante ? precioMensual : restante;
    nuevos.add(PeriodoSaldo(
      mes: siguiente,
      vencimiento: siguiente.fechaVencimiento(diaCorte),
      monto: precioMensual,
    ));
    aplicaciones.add(Aplicacion(mes: siguiente, monto: aplicado));
    restante -= aplicado;
    siguiente = siguiente.siguiente();
  }

  return ResultadoAplicacion(
    aplicaciones: aplicaciones,
    periodosNuevos: nuevos,
    sobrante: restante,
  );
}

class EstadoAdeudo {
  final int total;
  final int meses;

  /// Fecha de vencimiento del mes más antiguo sin pagar (null si no debe).
  final DateTime? vencidoDesde;

  const EstadoAdeudo({required this.total, required this.meses, this.vencidoDesde});

  bool get tieneAdeudo => total > 0;
}

/// Calcula cuánto debe un cliente a la fecha [hoy].
/// Un mes cuenta como adeudo a partir del día siguiente a su vencimiento.
EstadoAdeudo calcularAdeudo(List<PeriodoSaldo> periodos, DateTime hoy) {
  final hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);
  var total = 0;
  var meses = 0;
  DateTime? desde;
  for (final p in periodos) {
    if (p.saldo > 0 && p.vencimiento.isBefore(hoySinHora)) {
      total += p.saldo;
      meses++;
      if (desde == null || p.vencimiento.isBefore(desde)) desde = p.vencimiento;
    }
  }
  return EstadoAdeudo(total: total, meses: meses, vencidoDesde: desde);
}

/// Último mes pagado de forma continua desde el primero ("pagado hasta").
/// Devuelve null si el primer mes no está liquidado o no hay periodos.
Mes? pagadoHasta(List<PeriodoSaldo> periodos) {
  final ordenados = [...periodos]..sort((a, b) => a.mes.compareTo(b.mes));
  Mes? ultimo;
  for (final p in ordenados) {
    if (!p.liquidado) break;
    ultimo = p.mes;
  }
  return ultimo;
}
