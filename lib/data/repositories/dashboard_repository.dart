import 'package:drift/drift.dart';

import '../../core/mes.dart';
import '../../domain/dashboard.dart';
import '../db/database.dart';
import 'vencimientos_repository.dart';

/// Datos para la pantalla de inicio. Se recalcula cuando cambia cualquier
/// tabla de clientes, meses, pagos o cargos.
class DashboardRepository {
  DashboardRepository(this._db) : _vencimientos = VencimientosRepository(_db);

  final AppDatabase _db;
  final VencimientosRepository _vencimientos;

  Stream<ResumenDashboard> vigilarResumen(DateTime hoy) {
    // Consulta "testigo": no lee datos, solo avisa cuando cambian estas tablas.
    return _db
        .customSelect('SELECT 1', readsFrom: {
          _db.clientes,
          _db.periodos,
          _db.pagos,
          _db.pagoAplicaciones,
          _db.cargos,
          _db.cargoAplicaciones,
        })
        .watch()
        .asyncMap((_) => calcularResumen(hoy));
  }

  Future<ResumenDashboard> calcularResumen(DateTime hoy) async {
    final mes = Mes.deFecha(hoy);

    // Clientes por estado.
    final porEstado = <EstadoCliente, int>{};
    final filasEstado = await _db
        .customSelect('SELECT estado, COUNT(*) AS n FROM clientes GROUP BY estado',
            readsFrom: {_db.clientes})
        .get();
    for (final f in filasEstado) {
      porEstado[EstadoCliente.values.byName(f.read<String>('estado'))] = f.read<int>('n');
    }

    // Pagos vigentes (con el nombre del cliente).
    final filasPagos = await (_db.select(_db.pagos).join([
      innerJoin(_db.clientes, _db.clientes.id.equalsExp(_db.pagos.clienteId)),
    ])
          ..where(_db.pagos.cancelado.equals(false)))
        .get();
    final pagos = [
      for (final f in filasPagos)
        (
          clienteId: f.readTable(_db.clientes).id,
          cliente: f.readTable(_db.clientes).nombre,
          fecha: f.readTable(_db.pagos).fechaPago,
          monto: f.readTable(_db.pagos).monto,
        ),
    ];
    final cobrado = cobradoEnMes(pagos, mes);

    // Meses del mes actual y del siguiente, con lo pagado de cada uno.
    final siguiente = mes.siguiente();
    final filasMeses = await _db.customSelect(
      '''
      SELECT c.id AS cliente_id, c.nombre, c.estado,
        p.mes, p.fecha_vencimiento, p.monto, p.es_cortesia,
        COALESCE((
          SELECT SUM(pa.monto)
          FROM pago_aplicaciones pa
          JOIN pagos pg ON pg.id = pa.pago_id
          WHERE pa.periodo_id = p.id AND pg.cancelado = 0
        ), 0) AS pagado
      FROM periodos p
      JOIN clientes c ON c.id = p.cliente_id
      WHERE p.mes IN (?, ?)
      ''',
      variables: [Variable.withString(mes.toString()), Variable.withString(siguiente.toString())],
      readsFrom: {_db.periodos, _db.pagoAplicaciones, _db.pagos, _db.clientes},
    ).get();
    final meses = [
      for (final f in filasMeses)
        (
          clienteId: f.read<int>('cliente_id'),
          cliente: f.read<String>('nombre'),
          estado: EstadoCliente.values.byName(f.read<String>('estado')),
          mes: Mes.parse(f.read<String>('mes')),
          vencimiento: f.read<DateTime>('fecha_vencimiento'),
          monto: f.read<int>('monto'),
          pagado: f.read<int>('pagado'),
          esCortesia: f.read<bool>('es_cortesia'),
        ),
    ];
    final avance = avanceDelMes(meses, mes);

    // Adeudos (meses vencidos + cargos).
    final adeudos = await _vencimientos.vigilarAdeudos(hoy).first;

    return ResumenDashboard(
      mes: mes,
      cobradoMes: cobrado.total,
      pagosMes: cobrado.pagos,
      esperadoMes: avance.esperado,
      cubiertoMes: avance.cubierto,
      porCobrar: adeudos.fold<int>(0, (s, a) => s + a.adeudo.total),
      clientesConAdeudo: adeudos.length,
      clientesPorEstado: porEstado,
      proximosVencimientos: proximosAVencer(meses, hoy),
      pagosRecientes: recientes(pagos),
    );
  }
}
