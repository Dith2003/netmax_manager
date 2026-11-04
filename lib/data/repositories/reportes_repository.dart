import 'package:drift/drift.dart';

import '../../core/mes.dart';
import '../../domain/clientes.dart';
import '../../domain/cobranza.dart';
import '../../domain/reportes.dart';
import '../db/database.dart';
import 'vencimientos_repository.dart';

/// Consultas para los reportes. Son lecturas puntuales (no se vigilan).
class ReportesRepository {
  ReportesRepository(this._db) : _vencimientos = VencimientosRepository(_db);

  final AppDatabase _db;
  final VencimientosRepository _vencimientos;

  /// Pagos vigentes recibidos entre [desde] y [hasta] (ambos días incluidos),
  /// del más antiguo al más reciente, con lo que cubrió cada uno.
  Future<List<FilaPago>> pagosEntre(DateTime desde, DateTime hasta) async {
    final inicio = DateTime(desde.year, desde.month, desde.day);
    final fin = DateTime(hasta.year, hasta.month, hasta.day + 1);

    final filas = await (_db.select(_db.pagos).join([
      innerJoin(_db.clientes, _db.clientes.id.equalsExp(_db.pagos.clienteId)),
    ])
          ..where(_db.pagos.cancelado.equals(false)))
        .get();
    final pagos = [
      for (final f in filas)
        (pago: f.readTable(_db.pagos), cliente: f.readTable(_db.clientes).nombre),
    ]
        // Se filtra en Dart: las fechas se guardan como texto con zona horaria.
        .where((p) => !p.pago.fechaPago.isBefore(inicio) && p.pago.fechaPago.isBefore(fin))
        .toList()
      ..sort((a, b) {
        final f = a.pago.fechaPago.compareTo(b.pago.fechaPago);
        return f != 0 ? f : a.pago.id.compareTo(b.pago.id);
      });
    if (pagos.isEmpty) return [];

    final ids = pagos.map((p) => p.pago.id).toList();

    // Meses que cubrió cada pago.
    final meses = <int, List<Mes>>{};
    final filasMeses = await (_db.select(_db.pagoAplicaciones).join([
      innerJoin(_db.periodos, _db.periodos.id.equalsExp(_db.pagoAplicaciones.periodoId)),
    ])
          ..where(_db.pagoAplicaciones.pagoId.isIn(ids)))
        .get();
    for (final f in filasMeses) {
      meses
          .putIfAbsent(f.readTable(_db.pagoAplicaciones).pagoId, () => [])
          .add(Mes.parse(f.readTable(_db.periodos).mes));
    }

    // Cargos que cubrió cada pago.
    final cargos = <int, List<String>>{};
    final filasCargos = await (_db.select(_db.cargoAplicaciones).join([
      innerJoin(_db.cargos, _db.cargos.id.equalsExp(_db.cargoAplicaciones.cargoId)),
    ])
          ..where(_db.cargoAplicaciones.pagoId.isIn(ids)))
        .get();
    for (final f in filasCargos) {
      cargos
          .putIfAbsent(f.readTable(_db.cargoAplicaciones).pagoId, () => [])
          .add(f.readTable(_db.cargos).concepto);
    }

    return [
      for (final p in pagos)
        FilaPago(
          fecha: p.pago.fechaPago,
          cliente: p.cliente,
          monto: p.pago.monto,
          metodo: p.pago.metodo,
          folio: p.pago.folio,
          cubre: [
            if (meses[p.pago.id] != null) describirMeses(meses[p.pago.id]!),
            ...?cargos[p.pago.id],
          ].join(', '),
        ),
    ];
  }

  /// Ingresos por mes de [desde] a [hasta] (incluidos).
  Future<List<IngresoMes>> ingresos(Mes desde, Mes hasta) async {
    final pagos = await pagosEntre(
      DateTime(desde.anio, desde.mes, 1),
      DateTime(hasta.anio, hasta.mes + 1, 0), // último día de [hasta]
    );
    return ingresosPorMes(pagos, desde, hasta);
  }

  /// Clientes con adeudo a la fecha [hoy], del que más debe al que menos.
  Future<List<AdeudoCliente>> adeudos(DateTime hoy) => _vencimientos.vigilarAdeudos(hoy).first;

  /// Todos los clientes ordenados por nombre, con "pagado hasta" y adeudo a [hoy].
  Future<List<FilaCliente>> clientes(DateTime hoy) async {
    final lista = await _db.select(_db.clientes).get();

    final periodos = <int, List<PeriodoSaldo>>{};
    final filas = await _db.customSelect(
      '''
      SELECT p.id, p.cliente_id, p.mes, p.fecha_vencimiento, p.monto, p.es_cortesia,
        COALESCE((
          SELECT SUM(pa.monto)
          FROM pago_aplicaciones pa
          JOIN pagos pg ON pg.id = pa.pago_id
          WHERE pa.periodo_id = p.id AND pg.cancelado = 0
        ), 0) AS pagado
      FROM periodos p
      ''',
      readsFrom: {_db.periodos, _db.pagoAplicaciones, _db.pagos},
    ).get();
    for (final f in filas) {
      periodos.putIfAbsent(f.read<int>('cliente_id'), () => []).add(PeriodoSaldo(
            id: f.read<int>('id'),
            mes: Mes.parse(f.read<String>('mes')),
            vencimiento: f.read<DateTime>('fecha_vencimiento'),
            monto: f.read<int>('monto'),
            pagado: f.read<int>('pagado'),
            esCortesia: f.read<bool>('es_cortesia'),
          ));
    }

    final deudas = {for (final a in await adeudos(hoy)) a.clienteId: a.adeudo.total};

    return [
      for (final c in lista)
        FilaCliente(
          nombre: c.nombre,
          zona: c.zona,
          telefono: c.telefono,
          precioMensual: c.precioMensual,
          diaCorte: c.diaCorte,
          estado: c.estado,
          pagadoHasta: pagadoHasta(periodos[c.id] ?? const []),
          adeudo: deudas[c.id] ?? 0,
        ),
    ]..sort((a, b) => normalizar(a.nombre).compareTo(normalizar(b.nombre)));
  }
}
