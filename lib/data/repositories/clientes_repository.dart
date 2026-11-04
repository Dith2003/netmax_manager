import 'package:drift/drift.dart';

import '../../core/mes.dart';
import '../../domain/clientes.dart';
import '../db/database.dart';
import 'vencimientos_repository.dart';

/// Criterios de la lista de clientes.
class FiltroClientes {
  const FiltroClientes({this.busqueda = '', this.estado});

  final String busqueda;

  /// null = todos los estados.
  final EstadoCliente? estado;

  @override
  bool operator ==(Object other) =>
      other is FiltroClientes && other.busqueda == busqueda && other.estado == estado;

  @override
  int get hashCode => Object.hash(busqueda, estado);
}

/// Datos que captura el formulario de cliente.
class DatosCliente {
  const DatosCliente({
    required this.nombre,
    this.telefono,
    this.direccion,
    this.zona,
    this.referencia,
    required this.planId,
    required this.precioMensual,
    required this.diaCorte,
    required this.tipoContratacion,
    this.tipoContratacionDetalle,
    required this.fechaAlta,
    required this.primerMesCobro,
    this.notas,
  });

  final String nombre;
  final String? telefono;
  final String? direccion;
  final String? zona;
  final String? referencia;
  final int planId;
  final int precioMensual;
  final int diaCorte;
  final TipoContratacion tipoContratacion;

  /// Descripción libre cuando [tipoContratacion] es `otro` (si no, se ignora).
  final String? tipoContratacionDetalle;
  final DateTime fechaAlta;

  /// Detalle que se guarda: solo para `otro`.
  String? get detalleGuardado =>
      tipoContratacion == TipoContratacion.otro ? tipoContratacionDetalle?.trim() : null;

  /// Primer mes que se le cobra (mes del alta, el siguiente u otro).
  final Mes primerMesCobro;
  final String? notas;
}

class DatosInstalacion {
  const DatosInstalacion({
    required this.fecha,
    this.costo = 0,
    this.pagado = false,
    this.tecnico,
    this.notas,
  });

  final DateTime fecha;
  final int costo;
  final bool pagado;
  final String? tecnico;
  final String? notas;
}

class DatosEquipo {
  const DatosEquipo({
    required this.tipo,
    this.marcaModelo,
    this.numeroSerie,
    required this.propiedad,
    this.costo,
    this.fechaEntrega,
    this.notas,
  });

  final String tipo;
  final String? marcaModelo;
  final String? numeroSerie;
  final PropiedadEquipo propiedad;
  final int? costo;
  final DateTime? fechaEntrega;
  final String? notas;
}

/// Acceso a datos de clientes, sus instalaciones, equipos e historial.
class ClientesRepository {
  /// [ahora] permite fijar la fecha en las pruebas.
  ClientesRepository(this._db, {DateTime Function()? ahora})
      : _ahora = ahora ?? DateTime.now,
        _vencimientos = VencimientosRepository(_db);

  final AppDatabase _db;
  final DateTime Function() _ahora;
  final VencimientosRepository _vencimientos;

  // ----- Planes -----

  Stream<List<Plan>> vigilarPlanes() {
    return (_db.select(_db.planes)
          ..where((p) => p.activo.equals(true))
          ..orderBy([(p) => OrderingTerm.asc(p.precioBase)]))
        .watch();
  }

  // ----- Contratación -----

  /// Descripciones de contratación personalizadas ya usadas (para sugerirlas),
  /// de la más usada a la menos usada.
  Stream<List<({String detalle, int clientes})>> vigilarContratacionesPersonalizadas() {
    return (_db.select(_db.clientes)
          ..where((c) =>
              c.tipoContratacion.equalsValue(TipoContratacion.otro) &
              c.tipoContratacionDetalle.isNotNull()))
        .watch()
        .map((lista) => agruparDetalles([for (final c in lista) c.tipoContratacionDetalle]));
  }

  // ----- Clientes -----

  /// Lista de clientes filtrada y ordenada por nombre.
  /// La búsqueda se hace en Dart para ignorar acentos (son pocos clientes).
  Stream<List<Cliente>> vigilarClientes(FiltroClientes filtro) {
    final consulta = _db.select(_db.clientes);
    final estado = filtro.estado;
    if (estado != null) {
      consulta.where((c) => c.estado.equalsValue(estado));
    }
    return consulta.watch().map((clientes) {
      final lista = clientes
          .where((c) => coincideBusqueda(
              filtro.busqueda, [c.nombre, c.telefono, c.zona, c.direccion]))
          .toList()
        ..sort((a, b) => normalizar(a.nombre).compareTo(normalizar(b.nombre)));
      return lista;
    });
  }

  Stream<Cliente?> vigilarCliente(int id) {
    return (_db.select(_db.clientes)..where((c) => c.id.equals(id)))
        .watchSingleOrNull();
  }

  Future<Cliente?> obtenerCliente(int id) {
    return (_db.select(_db.clientes)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  /// Da de alta un cliente (estado activo), lo anota en el historial y genera
  /// los meses que ya le correspondan.
  Future<int> crearCliente(DatosCliente d) {
    return _db.transaction(() async {
      final id = await _db.into(_db.clientes).insert(ClientesCompanion.insert(
            nombre: d.nombre,
            telefono: Value(d.telefono),
            direccion: Value(d.direccion),
            zona: Value(d.zona),
            referencia: Value(d.referencia),
            planId: d.planId,
            precioMensual: d.precioMensual,
            diaCorte: d.diaCorte,
            tipoContratacion: d.tipoContratacion,
            tipoContratacionDetalle: Value(d.detalleGuardado),
            fechaAlta: d.fechaAlta,
            primerMesCobro: Value(d.primerMesCobro.toString()),
            notas: Value(d.notas),
          ));
      await _db.into(_db.historialEstados).insert(HistorialEstadosCompanion.insert(
            clienteId: id,
            estadoNuevo: EstadoCliente.activo,
            motivo: const Value('Alta de cliente'),
            fecha: Value(_ahora()),
          ));
      await _vencimientos.generarParaCliente(id, _ahora());
      return id;
    });
  }

  /// Actualiza los datos del cliente. No toca el estado ni el monto de los meses ya
  /// generados (si cambia el precio, solo aplica a los meses que se generen después).
  /// Si el primer mes de cobro se mueve, ajusta los meses sin pagos.
  Future<void> actualizarCliente(int id, DatosCliente d) => _db.transaction(() async {
    await (_db.update(_db.clientes)..where((c) => c.id.equals(id))).write(
      ClientesCompanion(
        nombre: Value(d.nombre),
        telefono: Value(d.telefono),
        direccion: Value(d.direccion),
        zona: Value(d.zona),
        referencia: Value(d.referencia),
        planId: Value(d.planId),
        precioMensual: Value(d.precioMensual),
        diaCorte: Value(d.diaCorte),
        tipoContratacion: Value(d.tipoContratacion),
        tipoContratacionDetalle: Value(d.detalleGuardado),
        fechaAlta: Value(d.fechaAlta),
        primerMesCobro: Value(d.primerMesCobro.toString()),
        notas: Value(d.notas),
      ),
    );
    await _vencimientos.ajustarAlPrimerMes(id);
    await _vencimientos.generarParaCliente(id, _ahora());
  });

  /// Cambia el estado (activo/suspendido/cancelado) y lo registra en el historial.
  /// Los clientes nunca se borran.
  Future<void> cambiarEstado(int clienteId, EstadoCliente nuevo, {String? motivo}) {
    return _db.transaction(() async {
      final cliente = await obtenerCliente(clienteId);
      if (cliente == null) {
        throw StateError('No existe el cliente $clienteId');
      }
      if (cliente.estado == nuevo) return;
      await (_db.update(_db.clientes)..where((c) => c.id.equals(clienteId)))
          .write(ClientesCompanion(estado: Value(nuevo)));
      await _db.into(_db.historialEstados).insert(HistorialEstadosCompanion.insert(
            clienteId: clienteId,
            estadoAnterior: Value(cliente.estado),
            estadoNuevo: nuevo,
            motivo: Value(motivo),
            fecha: Value(_ahora()),
          ));
      // Al reactivar se generan los meses desde ese momento (no los de la suspensión).
      await _vencimientos.generarParaCliente(clienteId, _ahora());
    });
  }

  Stream<List<HistorialEstado>> vigilarHistorial(int clienteId) {
    return (_db.select(_db.historialEstados)
          ..where((h) => h.clienteId.equals(clienteId))
          ..orderBy([
            (h) => OrderingTerm.desc(h.fecha),
            (h) => OrderingTerm.desc(h.id),
          ]))
        .watch();
  }

  // ----- Instalaciones -----

  Stream<List<Instalacion>> vigilarInstalaciones(int clienteId) {
    return (_db.select(_db.instalaciones)
          ..where((i) => i.clienteId.equals(clienteId))
          ..orderBy([(i) => OrderingTerm.desc(i.fecha)]))
        .watch();
  }

  Future<int> agregarInstalacion(int clienteId, DatosInstalacion d) {
    return _db.into(_db.instalaciones).insert(InstalacionesCompanion.insert(
          clienteId: clienteId,
          fecha: d.fecha,
          costo: Value(d.costo),
          pagado: Value(d.pagado),
          tecnico: Value(d.tecnico),
          notas: Value(d.notas),
        ));
  }

  Future<void> marcarInstalacionPagada(int instalacionId, bool pagado) async {
    await (_db.update(_db.instalaciones)..where((i) => i.id.equals(instalacionId)))
        .write(InstalacionesCompanion(pagado: Value(pagado)));
  }

  // ----- Equipos -----

  /// Equipos del cliente: primero los que tiene instalados, luego los retirados.
  Stream<List<Equipo>> vigilarEquipos(int clienteId) {
    return (_db.select(_db.equipos)
          ..where((e) => e.clienteId.equals(clienteId))
          ..orderBy([
            (e) => OrderingTerm.asc(e.fechaRetiro.isNotNull()),
            (e) => OrderingTerm.desc(e.fechaEntrega),
          ]))
        .watch();
  }

  Future<int> agregarEquipo(int clienteId, DatosEquipo d) {
    return _db.into(_db.equipos).insert(EquiposCompanion.insert(
          clienteId: Value(clienteId),
          tipo: d.tipo,
          marcaModelo: Value(d.marcaModelo),
          numeroSerie: Value(d.numeroSerie),
          propiedad: d.propiedad,
          costo: Value(d.costo),
          fechaEntrega: Value(d.fechaEntrega),
          notas: Value(d.notas),
        ));
  }

  /// Marca un equipo como retirado (p. ej. equipo prestado que se recuperó).
  /// El equipo sigue ligado al cliente para conservar el historial.
  Future<void> registrarRetiro(int equipoId, DateTime fecha) async {
    await (_db.update(_db.equipos)..where((e) => e.id.equals(equipoId)))
        .write(EquiposCompanion(fechaRetiro: Value(fecha)));
  }
}
