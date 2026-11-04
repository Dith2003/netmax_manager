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

  /// Lo que se debía de ese mes antes de este pago.
  final int saldoAntes;

  const Aplicacion({
    required this.mes,
    this.periodoId,
    required this.monto,
    required this.saldoAntes,
  });

  /// True si con este pago el mes queda totalmente pagado.
  bool get completo => monto >= saldoAntes;

  /// True si el mes no existía y lo crea este pago (pago adelantado).
  bool get esNuevo => periodoId == null;

  @override
  String toString() => 'Aplicacion($mes, id: $periodoId, monto: $monto)';
}

/// Cargo extra (p. ej. equipo no devuelto) con lo pagado hasta ahora.
/// Se debe desde su [fecha]; los pagos lo cubren en orden de fecha junto con los meses.
class CargoSaldo {
  const CargoSaldo({
    required this.id,
    required this.concepto,
    required this.fecha,
    required this.monto,
    this.pagado = 0,
  });

  final int id;
  final String concepto;
  final DateTime fecha;
  final int monto;
  final int pagado;

  int get saldo {
    final s = monto - pagado;
    return s > 0 ? s : 0;
  }

  bool get liquidado => saldo == 0;
}

class AplicacionCargo {
  const AplicacionCargo({
    required this.cargoId,
    required this.concepto,
    required this.monto,
    required this.saldoAntes,
  });

  final int cargoId;
  final String concepto;
  final int monto;
  final int saldoAntes;

  bool get completo => monto >= saldoAntes;
}

class ResultadoAplicacion {
  /// En qué meses se reparte el pago y cuánto a cada uno.
  final List<Aplicacion> aplicaciones;

  /// Qué cargos extra cubre el pago y cuánto a cada uno.
  final List<AplicacionCargo> aplicacionesCargos;

  /// Periodos que hay que crear en la base de datos (pago adelantado).
  final List<PeriodoSaldo> periodosNuevos;

  /// Dinero que no se pudo aplicar (solo si se rebasa [maxPeriodosNuevos]).
  final int sobrante;

  const ResultadoAplicacion({
    required this.aplicaciones,
    this.aplicacionesCargos = const [],
    required this.periodosNuevos,
    required this.sobrante,
  });
}

/// Reparte un pago de [monto] centavos entre los periodos y cargos del cliente.
///
/// [periodos]: todos los periodos existentes del cliente (cualquier orden).
/// [cargos]: cargos extra vigentes; se cubren junto con los meses por fecha
/// (vencimiento del mes o fecha del cargo), del más antiguo al más reciente.
/// [precioMensual] y [diaCorte]: se usan para crear los meses nuevos.
/// [primerMes]: mes con el que empezar si el cliente aún no tiene periodos.
ResultadoAplicacion aplicarPago({
  required int monto,
  required List<PeriodoSaldo> periodos,
  required int precioMensual,
  required int diaCorte,
  required Mes primerMes,
  List<CargoSaldo> cargos = const [],
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
  final aplicacionesCargos = <AplicacionCargo>[];
  var restante = monto;

  // 1. Cubrir lo pendiente (meses y cargos), del más antiguo al más reciente.
  //    Con la misma fecha va primero el mes.
  final pendientes = <({DateTime fecha, int orden, PeriodoSaldo? periodo, CargoSaldo? cargo})>[
    for (final (i, p) in ordenados.indexed)
      if (p.saldo > 0) (fecha: p.vencimiento, orden: i, periodo: p, cargo: null),
    for (final c in cargos)
      if (c.saldo > 0) (fecha: c.fecha, orden: 1 << 30, periodo: null, cargo: c),
  ]..sort((a, b) {
      final f = a.fecha.compareTo(b.fecha);
      return f != 0 ? f : a.orden.compareTo(b.orden);
    });

  for (final item in pendientes) {
    if (restante == 0) break;
    final p = item.periodo;
    final c = item.cargo;
    if (p != null) {
      final saldo = p.saldo;
      final aplicado = saldo < restante ? saldo : restante;
      aplicaciones.add(Aplicacion(
          mes: p.mes, periodoId: p.id, monto: aplicado, saldoAntes: saldo));
      restante -= aplicado;
    } else if (c != null) {
      final saldo = c.saldo;
      final aplicado = saldo < restante ? saldo : restante;
      aplicacionesCargos.add(AplicacionCargo(
          cargoId: c.id, concepto: c.concepto, monto: aplicado, saldoAntes: saldo));
      restante -= aplicado;
    }
  }
  // Los meses se muestran en orden de mes.
  aplicaciones.sort((a, b) => a.mes.compareTo(b.mes));

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
    aplicaciones.add(
        Aplicacion(mes: siguiente, monto: aplicado, saldoAntes: precioMensual));
    restante -= aplicado;
    siguiente = siguiente.siguiente();
  }

  return ResultadoAplicacion(
    aplicaciones: aplicaciones,
    aplicacionesCargos: aplicacionesCargos,
    periodosNuevos: nuevos,
    sobrante: restante,
  );
}

class EstadoAdeudo {
  final int total;
  final int meses;

  /// Cargos extra pendientes que forman parte del adeudo.
  final int cargos;

  /// Fecha del adeudo más antiguo (mes vencido o cargo); null si no debe.
  final DateTime? vencidoDesde;

  const EstadoAdeudo({
    required this.total,
    required this.meses,
    this.cargos = 0,
    this.vencidoDesde,
  });

  bool get tieneAdeudo => total > 0;

  /// "2 meses vencidos y 1 cargo", "1 mes vencido", "1 cargo".
  String get descripcion {
    final partes = [
      if (meses > 0) '$meses ${meses == 1 ? 'mes vencido' : 'meses vencidos'}',
      if (cargos > 0) '$cargos ${cargos == 1 ? 'cargo' : 'cargos'}',
    ];
    return partes.join(' y ');
  }
}

/// Calcula cuánto debe un cliente a la fecha [hoy].
/// Un mes cuenta como adeudo a partir del día siguiente a su vencimiento;
/// un cargo extra se debe desde su fecha.
EstadoAdeudo calcularAdeudo(List<PeriodoSaldo> periodos, DateTime hoy,
    {List<CargoSaldo> cargos = const []}) {
  final hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);
  var total = 0;
  var meses = 0;
  var numCargos = 0;
  DateTime? desde;
  for (final p in periodos) {
    if (p.saldo > 0 && p.vencimiento.isBefore(hoySinHora)) {
      total += p.saldo;
      meses++;
      if (desde == null || p.vencimiento.isBefore(desde)) desde = p.vencimiento;
    }
  }
  for (final c in cargos) {
    if (c.saldo > 0 && !c.fecha.isAfter(hoySinHora)) {
      total += c.saldo;
      numCargos++;
      if (desde == null || c.fecha.isBefore(desde)) desde = c.fecha;
    }
  }
  return EstadoAdeudo(total: total, meses: meses, cargos: numCargos, vencidoDesde: desde);
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

/// Describe una lista de meses de forma corta:
/// [oct 2026] -> "oct 2026"; [oct, nov, dic 2026] -> "oct 2026 – dic 2026";
/// meses no consecutivos -> "ago 2026, oct 2026".
String describirMeses(List<Mes> meses) {
  if (meses.isEmpty) return '';
  final ordenados = [...meses]..sort();
  if (ordenados.length == 1) return ordenados.first.nombreCorto;
  var consecutivos = true;
  for (var i = 1; i < ordenados.length; i++) {
    if (ordenados[i - 1].siguiente() != ordenados[i]) {
      consecutivos = false;
      break;
    }
  }
  if (consecutivos) {
    return '${ordenados.first.nombreCorto} – ${ordenados.last.nombreCorto}';
  }
  return ordenados.map((m) => m.nombreCorto).join(', ');
}
