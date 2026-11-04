import 'package:drift/drift.dart';

import '../../core/mes.dart';
import '../../domain/cobranza.dart';
import '../../domain/vencimientos.dart';
import '../db/database.dart';
import 'vencimientos_repository.dart';

/// Datos que captura la pantalla "Registrar pago".
class DatosPago {
  const DatosPago({
    required this.monto,
    required this.fecha,
    this.metodo = MetodoPago.efectivo,
    this.folio,
    this.notas,
    this.registradoPor,
  });

  final int monto;
  final DateTime fecha;
  final MetodoPago metodo;

  /// Referencia bancaria (transferencia o depósito). El folio del comprobante
  /// es el número del pago y lo asigna el sistema.
  final String? folio;
  final String? notas;

  /// Usuario que registra el pago (sesión actual).
  final int? registradoPor;
}

/// Un pago con los meses que cubrió.
class PagoConDetalle {
  const PagoConDetalle({required this.pago, required this.meses, this.cargos = const []});

  final Pago pago;

  /// Mes y monto aplicado a cada mes.
  final List<({Mes mes, int monto})> meses;

  /// Cargos extra que cubrió el pago.
  final List<({String concepto, int monto})> cargos;
}

/// Error de regla de negocio que se muestra tal cual al usuario.
class PagoNoPermitido implements Exception {
  const PagoNoPermitido(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Registro de pagos y cálculo de saldos por mes.
///
/// El reparto de cada pago lo decide [aplicarPago] (domain/cobranza.dart):
/// primero el mes pendiente más antiguo y, si sobra, meses adelantados.
class PagosRepository {
  /// [ahora] permite fijar la fecha en las pruebas.
  PagosRepository(this._db, {DateTime Function()? ahora})
      : _ahora = ahora ?? DateTime.now,
        _vencimientos = VencimientosRepository(_db);

  final AppDatabase _db;
  final DateTime Function() _ahora;
  final VencimientosRepository _vencimientos;

  /// Máximo de meses que un solo pago puede adelantar.
  static const maxMesesAdelantados = 24;

  // ----- Saldos por mes -----

  /// Meses del cliente con lo pagado (sin contar pagos cancelados).
  Selectable<PeriodoSaldo> _consultaPeriodos(int clienteId) {
    return _db.customSelect(
      '''
      SELECT p.id, p.mes, p.fecha_vencimiento, p.monto, p.es_cortesia,
        COALESCE((
          SELECT SUM(pa.monto)
          FROM pago_aplicaciones pa
          JOIN pagos pg ON pg.id = pa.pago_id
          WHERE pa.periodo_id = p.id AND pg.cancelado = 0
        ), 0) AS pagado
      FROM periodos p
      WHERE p.cliente_id = ?
      ORDER BY p.mes
      ''',
      variables: [Variable.withInt(clienteId)],
      readsFrom: {_db.periodos, _db.pagoAplicaciones, _db.pagos},
    ).map((row) => PeriodoSaldo(
          id: row.read<int>('id'),
          mes: Mes.parse(row.read<String>('mes')),
          vencimiento: row.read<DateTime>('fecha_vencimiento'),
          monto: row.read<int>('monto'),
          pagado: row.read<int>('pagado'),
          esCortesia: row.read<bool>('es_cortesia'),
        ));
  }

  Stream<List<PeriodoSaldo>> vigilarPeriodos(int clienteId) =>
      _consultaPeriodos(clienteId).watch();

  Future<List<PeriodoSaldo>> obtenerPeriodos(int clienteId) =>
      _consultaPeriodos(clienteId).get();

  // ----- Registrar pago -----

  /// Calcula cómo se repartiría un pago sin guardarlo (para la vista previa).
  static ResultadoAplicacion previsualizar({
    required Cliente cliente,
    required List<PeriodoSaldo> periodos,
    List<CargoSaldo> cargos = const [],
    required int monto,
  }) {
    return aplicarPago(
      monto: monto,
      periodos: periodos,
      cargos: cargos,
      precioMensual: cliente.precioMensual,
      diaCorte: cliente.diaCorte,
      primerMes: primerMesDeCobro(
          primerMesCobro: cliente.primerMesCobro, fechaAlta: cliente.fechaAlta),
      maxPeriodosNuevos: maxMesesAdelantados,
    );
  }

  /// Número (folio) que tendrá el siguiente pago: el id que le asignará SQLite.
  /// Solo es informativo: el folio definitivo es el id con que se guarde.
  Future<int> siguienteFolio() async {
    final secuencia = await _db
        .customSelect("SELECT seq FROM sqlite_sequence WHERE name = 'pagos'")
        .getSingleOrNull();
    if (secuencia != null) return secuencia.read<int>('seq') + 1;
    final maximo =
        await _db.customSelect('SELECT MAX(id) AS m FROM pagos').getSingleOrNull();
    return (maximo?.readNullable<int>('m') ?? 0) + 1;
  }

  /// Guarda el pago, crea los meses adelantados que hagan falta y registra
  /// a qué meses se aplicó. Devuelve el id del pago.
  Future<int> registrarPago(int clienteId, DatosPago datos) {
    return _db.transaction(() async {
      final cliente = await (_db.select(_db.clientes)..where((c) => c.id.equals(clienteId)))
          .getSingleOrNull();
      if (cliente == null) {
        throw const PagoNoPermitido('El cliente no existe.');
      }
      if (cliente.estado == EstadoCliente.cancelado) {
        throw const PagoNoPermitido(
            'El cliente está cancelado. Reactívalo antes de registrar un pago.');
      }
      if (datos.monto <= 0) {
        throw const PagoNoPermitido('El monto debe ser mayor a \$0.');
      }

      // Asegura que existan los meses que ya le corresponden antes de repartir.
      await _vencimientos.generarParaCliente(clienteId, _ahora());
      final periodos = await obtenerPeriodos(clienteId);
      final cargos = await _vencimientos.consultaCargos(clienteId).get();
      final resultado = previsualizar(
          cliente: cliente, periodos: periodos, cargos: cargos, monto: datos.monto);
      if (resultado.sobrante > 0) {
        throw const PagoNoPermitido(
            'El pago cubre más de $maxMesesAdelantados meses adelantados. Revisa el monto.');
      }

      // Crear los meses nuevos (pago adelantado) y recordar su id.
      final idsNuevos = <Mes, int>{};
      for (final p in resultado.periodosNuevos) {
        idsNuevos[p.mes] = await _db.into(_db.periodos).insert(PeriodosCompanion.insert(
              clienteId: clienteId,
              mes: p.mes.toString(),
              fechaVencimiento: p.vencimiento,
              monto: p.monto,
            ));
      }

      final pagoId = await _db.into(_db.pagos).insert(PagosCompanion.insert(
            clienteId: clienteId,
            fechaPago: datos.fecha,
            monto: datos.monto,
            metodo: datos.metodo,
            folio: Value(datos.folio),
            notas: Value(datos.notas),
            registradoPor: Value(datos.registradoPor),
            creadoEn: Value(DateTime.now()),
          ));

      for (final a in resultado.aplicaciones) {
        await _db.into(_db.pagoAplicaciones).insert(PagoAplicacionesCompanion.insert(
              pagoId: pagoId,
              periodoId: a.periodoId ?? idsNuevos[a.mes]!,
              monto: a.monto,
            ));
      }
      for (final a in resultado.aplicacionesCargos) {
        await _db.into(_db.cargoAplicaciones).insert(CargoAplicacionesCompanion.insert(
              pagoId: pagoId,
              cargoId: a.cargoId,
              monto: a.monto,
            ));
      }
      return pagoId;
    });
  }

  // ----- Cancelar pago -----

  /// Marca el pago como cancelado (no se borra). Los meses que cubría vuelven
  /// a quedar pendientes. El motivo se agrega a las notas del pago.
  Future<void> cancelarPago(int pagoId, {String? motivo}) {
    return _db.transaction(() async {
      final pago = await (_db.select(_db.pagos)..where((p) => p.id.equals(pagoId)))
          .getSingleOrNull();
      if (pago == null || pago.cancelado) return;
      final nota = 'CANCELADO${motivo == null || motivo.isEmpty ? '' : ': $motivo'}';
      await (_db.update(_db.pagos)..where((p) => p.id.equals(pagoId))).write(
        PagosCompanion(
          cancelado: const Value(true),
          notas: Value(pago.notas == null ? nota : '${pago.notas}\n$nota'),
        ),
      );
    });
  }

  // ----- Historial de pagos -----

  /// Pagos del cliente (incluye cancelados), del más reciente al más antiguo.
  Stream<List<PagoConDetalle>> vigilarPagos(int clienteId) {
    final consulta = _db.select(_db.pagos).join([
      leftOuterJoin(
          _db.pagoAplicaciones, _db.pagoAplicaciones.pagoId.equalsExp(_db.pagos.id)),
      leftOuterJoin(
          _db.periodos, _db.periodos.id.equalsExp(_db.pagoAplicaciones.periodoId)),
    ])
      ..where(_db.pagos.clienteId.equals(clienteId))
      ..orderBy([
        OrderingTerm.desc(_db.pagos.fechaPago),
        OrderingTerm.desc(_db.pagos.id),
      ]);

    return consulta.watch().asyncMap((filas) async {
      // Cargos extra cubiertos por los pagos de este cliente.
      final filasCargos = await (_db.select(_db.cargoAplicaciones).join([
        innerJoin(_db.cargos, _db.cargos.id.equalsExp(_db.cargoAplicaciones.cargoId)),
      ])
            ..where(_db.cargos.clienteId.equals(clienteId)))
          .get();
      final cargosPorPago = <int, List<({String concepto, int monto})>>{};
      for (final f in filasCargos) {
        final a = f.readTable(_db.cargoAplicaciones);
        final c = f.readTable(_db.cargos);
        cargosPorPago.putIfAbsent(a.pagoId, () => []).add((concepto: c.concepto, monto: a.monto));
      }

      final pagos = <int, Pago>{};
      final meses = <int, List<({Mes mes, int monto})>>{};
      for (final fila in filas) {
        final pago = fila.readTable(_db.pagos);
        pagos.putIfAbsent(pago.id, () => pago);
        final lista = meses.putIfAbsent(pago.id, () => []);
        final aplicacion = fila.readTableOrNull(_db.pagoAplicaciones);
        final periodo = fila.readTableOrNull(_db.periodos);
        if (aplicacion != null && periodo != null) {
          lista.add((mes: Mes.parse(periodo.mes), monto: aplicacion.monto));
        }
      }
      return [
        for (final p in pagos.values)
          PagoConDetalle(
            pago: p,
            meses: meses[p.id]!..sort((a, b) => a.mes.compareTo(b.mes)),
            cargos: cargosPorPago[p.id] ?? const [],
          ),
      ];
    });
  }
}
