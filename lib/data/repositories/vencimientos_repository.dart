import 'package:drift/drift.dart';

import '../../core/mes.dart';
import '../../domain/cobranza.dart';
import '../../domain/vencimientos.dart';
import '../db/database.dart';

/// Error de regla de negocio que se muestra tal cual al usuario.
class OperacionNoPermitida implements Exception {
  const OperacionNoPermitida(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Cliente con adeudo, para la lista de adeudos.
class AdeudoCliente {
  const AdeudoCliente({
    required this.clienteId,
    required this.nombre,
    this.telefono,
    this.zona,
    required this.estado,
    required this.adeudo,
  });

  final int clienteId;
  final String nombre;
  final String? telefono;
  final String? zona;
  final EstadoCliente estado;
  final EstadoAdeudo adeudo;
}

/// Generación de meses de servicio, cortesías, cobros manuales y adeudos.
class VencimientosRepository {
  VencimientosRepository(this._db);

  final AppDatabase _db;

  // ----- Generación automática -----

  /// Crea los meses que le faltan al cliente hasta el mes de [hoy].
  /// Devuelve cuántos meses creó.
  Future<int> generarParaCliente(int clienteId, DateTime hoy) {
    return _db.transaction(() async {
      final cliente = await (_db.select(_db.clientes)..where((c) => c.id.equals(clienteId)))
          .getSingleOrNull();
      if (cliente == null) return 0;

      final existentes = await (_db.selectOnly(_db.periodos)
            ..addColumns([_db.periodos.mes])
            ..where(_db.periodos.clienteId.equals(clienteId)))
          .map((r) => Mes.parse(r.read(_db.periodos.mes)!))
          .get();

      final historial = await (_db.select(_db.historialEstados)
            ..where((h) => h.clienteId.equals(clienteId))
            ..orderBy([(h) => OrderingTerm.asc(h.id)]))
          .map((h) => (fecha: h.fecha, estado: h.estadoNuevo))
          .get();

      final meses = mesesPorGenerar(
        primerMes: primerMesDeCobro(
            primerMesCobro: cliente.primerMesCobro, fechaAlta: cliente.fechaAlta),
        existentes: existentes.toSet(),
        diaCorte: cliente.diaCorte,
        historial: historial,
        hoy: hoy,
      );
      for (final m in meses) {
        await _db.into(_db.periodos).insert(PeriodosCompanion.insert(
              clienteId: clienteId,
              mes: m.toString(),
              fechaVencimiento: m.fechaVencimiento(cliente.diaCorte),
              monto: cliente.precioMensual,
            ));
      }
      return meses.length;
    });
  }

  /// Genera los meses pendientes de todos los clientes (se llama al abrir la app).
  Future<int> generarTodos(DateTime hoy) async {
    final ids = await (_db.selectOnly(_db.clientes)..addColumns([_db.clientes.id]))
        .map((r) => r.read(_db.clientes.id)!)
        .get();
    var total = 0;
    for (final id in ids) {
      total += await generarParaCliente(id, hoy);
    }
    return total;
  }

  /// Si el primer mes de cobro se movió a un mes posterior, quita los meses
  /// anteriores que no tengan ningún pago aplicado.
  Future<void> ajustarAlPrimerMes(int clienteId) async {
    final cliente = await (_db.select(_db.clientes)..where((c) => c.id.equals(clienteId)))
        .getSingleOrNull();
    if (cliente == null) return;
    final primer =
        primerMesDeCobro(primerMesCobro: cliente.primerMesCobro, fechaAlta: cliente.fechaAlta);
    await _db.customStatement(
      '''
      DELETE FROM periodos
      WHERE cliente_id = ? AND mes < ?
        AND NOT EXISTS (SELECT 1 FROM pago_aplicaciones pa WHERE pa.periodo_id = periodos.id)
      ''',
      [clienteId, primer.toString()],
    );
  }

  // ----- Cambios manuales -----

  /// Marca o desmarca un mes como cortesía (no se cobra).
  /// No se permite si el mes ya tiene pagos aplicados.
  Future<void> marcarCortesia(int periodoId, {required bool cortesia}) async {
    if (cortesia && await _tienePagosVigentes(periodoId)) {
      throw const OperacionNoPermitida(
          'Ese mes ya tiene pagos. Cancela el pago antes de marcarlo como cortesía.');
    }
    await (_db.update(_db.periodos)..where((p) => p.id.equals(periodoId)))
        .write(PeriodosCompanion(esCortesia: Value(cortesia)));
  }

  /// Agrega a mano un mes de cobro (p. ej. a un cliente suspendido que sí debe pagarlo).
  Future<void> agregarMes(int clienteId, Mes mes) async {
    final cliente = await (_db.select(_db.clientes)..where((c) => c.id.equals(clienteId)))
        .getSingleOrNull();
    if (cliente == null) throw const OperacionNoPermitida('El cliente no existe.');
    final existe = await (_db.select(_db.periodos)
          ..where((p) => p.clienteId.equals(clienteId) & p.mes.equals(mes.toString())))
        .getSingleOrNull();
    if (existe != null) {
      throw OperacionNoPermitida('${mes.nombre} ya está registrado.');
    }
    await _db.into(_db.periodos).insert(PeriodosCompanion.insert(
          clienteId: clienteId,
          mes: mes.toString(),
          fechaVencimiento: mes.fechaVencimiento(cliente.diaCorte),
          monto: cliente.precioMensual,
        ));
  }

  /// Quita un mes que se generó por error. Solo si nunca tuvo pagos aplicados.
  Future<void> quitarMes(int periodoId) async {
    final usos = await (_db.select(_db.pagoAplicaciones)
          ..where((a) => a.periodoId.equals(periodoId)))
        .get();
    if (usos.isNotEmpty) {
      throw const OperacionNoPermitida(
          'Ese mes tiene pagos registrados (aunque estén cancelados) y no se puede quitar. '
          'Puedes marcarlo como cortesía si no se va a cobrar.');
    }
    await (_db.delete(_db.periodos)..where((p) => p.id.equals(periodoId))).go();
  }

  Future<bool> _tienePagosVigentes(int periodoId) async {
    final fila = await _db.customSelect(
      '''
      SELECT COUNT(*) AS n FROM pago_aplicaciones pa
      JOIN pagos pg ON pg.id = pa.pago_id
      WHERE pa.periodo_id = ? AND pg.cancelado = 0
      ''',
      variables: [Variable.withInt(periodoId)],
      readsFrom: {_db.pagoAplicaciones, _db.pagos},
    ).getSingle();
    return fila.read<int>('n') > 0;
  }

  // ----- Cargos extra -----

  /// Cargos vigentes (no cancelados) del cliente con lo pagado de cada uno.
  Selectable<CargoSaldo> consultaCargos(int clienteId) {
    return _db.customSelect(
      '''
      SELECT c.id, c.concepto, c.fecha, c.monto,
        COALESCE((
          SELECT SUM(ca.monto)
          FROM cargo_aplicaciones ca
          JOIN pagos pg ON pg.id = ca.pago_id
          WHERE ca.cargo_id = c.id AND pg.cancelado = 0
        ), 0) AS pagado
      FROM cargos c
      WHERE c.cliente_id = ? AND c.cancelado = 0
      ORDER BY c.fecha, c.id
      ''',
      variables: [Variable.withInt(clienteId)],
      readsFrom: {_db.cargos, _db.cargoAplicaciones, _db.pagos},
    ).map(_cargoDeFila);
  }

  static CargoSaldo _cargoDeFila(QueryRow f) => CargoSaldo(
        id: f.read<int>('id'),
        concepto: f.read<String>('concepto'),
        fecha: f.read<DateTime>('fecha'),
        monto: f.read<int>('monto'),
        pagado: f.read<int>('pagado'),
      );

  Stream<List<CargoSaldo>> vigilarCargos(int clienteId) => consultaCargos(clienteId).watch();

  /// Agrega un cargo extra (p. ej. "Antena no devuelta"). Devuelve su id.
  Future<int> agregarCargo({
    required int clienteId,
    required String concepto,
    required int monto,
    required DateTime fecha,
    int? equipoId,
    String? notas,
  }) {
    if (concepto.trim().isEmpty) {
      throw const OperacionNoPermitida('Escribe el concepto del cargo.');
    }
    if (monto <= 0) {
      throw const OperacionNoPermitida('El monto del cargo debe ser mayor a \$0.');
    }
    return _db.into(_db.cargos).insert(CargosCompanion.insert(
          clienteId: clienteId,
          fecha: fecha,
          concepto: concepto.trim(),
          monto: monto,
          equipoId: Value(equipoId),
          notas: Value(notas),
          creadoEn: DateTime.now(),
        ));
  }

  /// Cancela un cargo capturado por error (no se borra). No se permite si ya tiene
  /// pagos vigentes: primero hay que cancelar el pago.
  Future<void> cancelarCargo(int cargoId, {String? motivo}) async {
    final fila = await _db.customSelect(
      '''
      SELECT COUNT(*) AS n FROM cargo_aplicaciones ca
      JOIN pagos pg ON pg.id = ca.pago_id
      WHERE ca.cargo_id = ? AND pg.cancelado = 0
      ''',
      variables: [Variable.withInt(cargoId)],
      readsFrom: {_db.cargoAplicaciones, _db.pagos},
    ).getSingle();
    if (fila.read<int>('n') > 0) {
      throw const OperacionNoPermitida(
          'Ese cargo ya tiene pagos. Cancela el pago antes de cancelar el cargo.');
    }
    final cargo = await (_db.select(_db.cargos)..where((c) => c.id.equals(cargoId)))
        .getSingleOrNull();
    if (cargo == null || cargo.cancelado) return;
    final nota = 'CANCELADO${motivo == null || motivo.isEmpty ? '' : ': $motivo'}';
    await (_db.update(_db.cargos)..where((c) => c.id.equals(cargoId))).write(CargosCompanion(
      cancelado: const Value(true),
      notas: Value(cargo.notas == null ? nota : '${cargo.notas}\n$nota'),
    ));
  }

  // ----- Adeudos -----

  /// Clientes que deben algo a la fecha [hoy], del que más debe al que menos.
  Stream<List<AdeudoCliente>> vigilarAdeudos(DateTime hoy) {
    return _db.customSelect(
      '''
      SELECT c.id AS cliente_id, c.nombre, c.telefono, c.zona, c.estado,
        p.id, p.mes, p.fecha_vencimiento, p.monto, p.es_cortesia,
        COALESCE((
          SELECT SUM(pa.monto)
          FROM pago_aplicaciones pa
          JOIN pagos pg ON pg.id = pa.pago_id
          WHERE pa.periodo_id = p.id AND pg.cancelado = 0
        ), 0) AS pagado
      FROM periodos p
      JOIN clientes c ON c.id = p.cliente_id
      ''',
      readsFrom: {
        _db.periodos,
        _db.pagoAplicaciones,
        _db.pagos,
        _db.clientes,
        // No se leen en esta consulta, pero si cambian hay que recalcular.
        _db.cargos,
        _db.cargoAplicaciones,
      },
    ).watch().asyncMap((filas) async {
      final cargos = await _db.customSelect(
        '''
        SELECT c.cliente_id, cl.nombre, cl.telefono, cl.zona, cl.estado,
          c.id, c.concepto, c.fecha, c.monto,
          COALESCE((
            SELECT SUM(ca.monto)
            FROM cargo_aplicaciones ca
            JOIN pagos pg ON pg.id = ca.pago_id
            WHERE ca.cargo_id = c.id AND pg.cancelado = 0
          ), 0) AS pagado
        FROM cargos c
        JOIN clientes cl ON cl.id = c.cliente_id
        WHERE c.cancelado = 0
        ''',
        readsFrom: {_db.cargos, _db.cargoAplicaciones, _db.pagos, _db.clientes},
      ).get();

      final datos = <int,
          ({QueryRow fila, List<PeriodoSaldo> periodos, List<CargoSaldo> cargos})>{};
      for (final f in cargos) {
        final id = f.read<int>('cliente_id');
        final entrada = datos.putIfAbsent(
            id, () => (fila: f, periodos: <PeriodoSaldo>[], cargos: <CargoSaldo>[]));
        entrada.cargos.add(_cargoDeFila(f));
      }
      for (final f in filas) {
        final id = f.read<int>('cliente_id');
        final entrada = datos.putIfAbsent(
            id, () => (fila: f, periodos: <PeriodoSaldo>[], cargos: <CargoSaldo>[]));
        entrada.periodos.add(PeriodoSaldo(
          id: f.read<int>('id'),
          mes: Mes.parse(f.read<String>('mes')),
          vencimiento: f.read<DateTime>('fecha_vencimiento'),
          monto: f.read<int>('monto'),
          pagado: f.read<int>('pagado'),
          esCortesia: f.read<bool>('es_cortesia'),
        ));
      }
      final resultado = <AdeudoCliente>[];
      for (final MapEntry(key: id, value: d) in datos.entries) {
        final adeudo = calcularAdeudo(d.periodos, hoy, cargos: d.cargos);
        if (!adeudo.tieneAdeudo) continue;
        resultado.add(AdeudoCliente(
          clienteId: id,
          nombre: d.fila.read<String>('nombre'),
          telefono: d.fila.readNullable<String>('telefono'),
          zona: d.fila.readNullable<String>('zona'),
          estado: EstadoCliente.values.byName(d.fila.read<String>('estado')),
          adeudo: adeudo,
        ));
      }
      resultado.sort((a, b) => b.adeudo.total.compareTo(a.adeudo.total));
      return resultado;
    });
  }
}
