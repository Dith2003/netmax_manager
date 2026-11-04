import 'package:drift/drift.dart';

import '../../domain/planes.dart';
import '../db/database.dart';
import 'vencimientos_repository.dart' show OperacionNoPermitida;

/// Un plan con cuántos clientes (no cancelados) lo tienen.
typedef PlanConUso = ({Plan plan, int clientes});

/// Catálogo de planes de internet (Configuración).
///
/// Los planes no se borran: se desactivan. Un plan desactivado ya no aparece al
/// registrar clientes nuevos, pero los clientes que lo tienen lo conservan.
/// Cambiar el precio de un plan no cambia el precio de los clientes existentes:
/// es solo el precio sugerido para los nuevos.
class PlanesRepository {
  PlanesRepository(this._db);

  final AppDatabase _db;

  /// Todos los planes (activos primero, luego por precio) con su número de clientes.
  Stream<List<PlanConUso>> vigilarPlanesConUso() {
    final clientes = _db.clientes.id.count();
    final consulta = _db.select(_db.planes).join([
      leftOuterJoin(
        _db.clientes,
        _db.clientes.planId.equalsExp(_db.planes.id) &
            _db.clientes.estado.equalsValue(EstadoCliente.cancelado).not(),
        useColumns: false,
      ),
    ])
      ..addColumns([clientes])
      ..groupBy([_db.planes.id])
      ..orderBy([
        OrderingTerm.desc(_db.planes.activo),
        OrderingTerm.asc(_db.planes.precioBase),
        OrderingTerm.asc(_db.planes.velocidadMbps),
      ]);
    return consulta.watch().map((filas) => [
          for (final f in filas)
            (plan: f.readTable(_db.planes), clientes: f.read(clientes) ?? 0),
        ]);
  }

  /// Todos los planes, activos o no (para mostrar el plan de cualquier cliente).
  Stream<List<Plan>> vigilarTodos() {
    return (_db.select(_db.planes)
          ..orderBy([
            (p) => OrderingTerm.desc(p.activo),
            (p) => OrderingTerm.asc(p.precioBase),
          ]))
        .watch();
  }

  Future<int> crear(DatosPlan d) {
    return _db.into(_db.planes).insert(PlanesCompanion.insert(
          nombre: d.nombre.trim(),
          velocidadMbps: d.velocidadMbps,
          precioBase: d.precioBase,
        ));
  }

  Future<void> actualizar(int id, DatosPlan d) async {
    await (_db.update(_db.planes)..where((p) => p.id.equals(id))).write(PlanesCompanion(
      nombre: Value(d.nombre.trim()),
      velocidadMbps: Value(d.velocidadMbps),
      precioBase: Value(d.precioBase),
    ));
  }

  /// Activa o desactiva un plan. No permite dejar el catálogo sin planes activos.
  Future<void> cambiarActivo(int id, bool activo) => _db.transaction(() async {
        if (!activo) {
          final activos = await (_db.select(_db.planes)..where((p) => p.activo.equals(true)))
              .get();
          final esteActivo = activos.any((p) => p.id == id);
          if (esteActivo && !sePuedeDesactivarPlan(activos: activos.length)) {
            throw const OperacionNoPermitida(
                'Debe quedar al menos un plan activo para registrar clientes.');
          }
        }
        await (_db.update(_db.planes)..where((p) => p.id.equals(id)))
            .write(PlanesCompanion(activo: Value(activo)));
      });
}
