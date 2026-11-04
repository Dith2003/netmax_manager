import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netmax_manager/core/mes.dart';
import 'package:netmax_manager/data/db/database.dart';
import 'package:netmax_manager/data/repositories/clientes_repository.dart';

void main() {
  late AppDatabase db;
  late ClientesRepository repo;
  late int planId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = ClientesRepository(db, ahora: () => DateTime(2026, 11, 3, 12));
    planId = (await repo.vigilarPlanes().first).first.id;
  });

  tearDown(() => db.close());

  DatosCliente datos(String nombre,
          {String? zona, TipoContratacion tipo = TipoContratacion.equipoPropio}) =>
      DatosCliente(
        nombre: nombre,
        zona: zona,
        planId: planId,
        precioMensual: 25000,
        diaCorte: 5,
        tipoContratacion: tipo,
        fechaAlta: DateTime(2026, 11, 3),
        primerMesCobro: Mes(2026, 11),
      );

  test('la base de datos nueva trae el plan de 10 Mbps a \$250', () async {
    final planes = await repo.vigilarPlanes().first;
    expect(planes.single.nombre, '10 Mbps');
    expect(planes.single.precioBase, 25000);
  });

  test('crear cliente lo deja activo y anota el alta en el historial', () async {
    final id = await repo.crearCliente(datos('Ana López'));
    final c = await repo.obtenerCliente(id);
    expect(c!.estado, EstadoCliente.activo);
    expect(c.precioMensual, 25000);

    final historial = await repo.vigilarHistorial(id).first;
    expect(historial.single.estadoNuevo, EstadoCliente.activo);
    expect(historial.single.estadoAnterior, isNull);
  });

  test('actualizar cambia los datos sin tocar el estado', () async {
    final id = await repo.crearCliente(datos('Ana López'));
    await repo.cambiarEstado(id, EstadoCliente.suspendido);
    await repo.actualizarCliente(
      id,
      DatosCliente(
        nombre: 'Ana María López',
        planId: planId,
        precioMensual: 30000,
        diaCorte: 10,
        tipoContratacion: TipoContratacion.equipoPrestado,
        fechaAlta: DateTime(2026, 11, 3),
        primerMesCobro: Mes(2026, 11),
      ),
    );
    final c = await repo.obtenerCliente(id);
    expect(c!.nombre, 'Ana María López');
    expect(c.precioMensual, 30000);
    expect(c.diaCorte, 10);
    expect(c.estado, EstadoCliente.suspendido);
  });

  test('cambiar estado registra el movimiento con motivo', () async {
    final id = await repo.crearCliente(datos('Luis'));
    await repo.cambiarEstado(id, EstadoCliente.suspendido, motivo: 'Falta de pago');
    await repo.cambiarEstado(id, EstadoCliente.suspendido); // sin cambio: no se registra

    final historial = await repo.vigilarHistorial(id).first;
    expect(historial.length, 2);
    final ultimo = historial.firstWhere((h) => h.estadoNuevo == EstadoCliente.suspendido);
    expect(ultimo.estadoAnterior, EstadoCliente.activo);
    expect(ultimo.motivo, 'Falta de pago');
  });

  test('la lista filtra por estado, busca sin acentos y ordena por nombre', () async {
    await repo.crearCliente(datos('Zoila Pérez', zona: 'El Ranchito'));
    final idAngel = await repo.crearCliente(datos('Ángel Núñez', zona: 'Centro'));
    await repo.crearCliente(datos('beto Ruiz', zona: 'Centro'));
    await repo.cambiarEstado(idAngel, EstadoCliente.cancelado);

    final todos = await repo.vigilarClientes(const FiltroClientes()).first;
    expect(todos.map((c) => c.nombre), ['Ángel Núñez', 'beto Ruiz', 'Zoila Pérez']);

    final activos =
        await repo.vigilarClientes(const FiltroClientes(estado: EstadoCliente.activo)).first;
    expect(activos.map((c) => c.nombre), ['beto Ruiz', 'Zoila Pérez']);

    final centro = await repo.vigilarClientes(const FiltroClientes(busqueda: 'centro')).first;
    expect(centro.length, 2);

    final angel = await repo.vigilarClientes(const FiltroClientes(busqueda: 'angel')).first;
    expect(angel.single.nombre, 'Ángel Núñez');
  });

  test('instalaciones: agregar y marcar como pagada', () async {
    final id = await repo.crearCliente(datos('Ana'));
    final instId = await repo.agregarInstalacion(
      id,
      DatosInstalacion(fecha: DateTime(2026, 11, 3), costo: 150000, tecnico: 'Juan'),
    );
    var lista = await repo.vigilarInstalaciones(id).first;
    expect(lista.single.pagado, isFalse);
    expect(lista.single.costo, 150000);

    await repo.marcarInstalacionPagada(instId, true);
    lista = await repo.vigilarInstalaciones(id).first;
    expect(lista.single.pagado, isTrue);
  });

  test('equipos: los retirados quedan al final y conservan el historial', () async {
    final id = await repo.crearCliente(datos('Ana', tipo: TipoContratacion.equipoPrestado));
    final antena = await repo.agregarEquipo(
      id,
      DatosEquipo(
          tipo: 'Antena', propiedad: PropiedadEquipo.netmax, fechaEntrega: DateTime(2026, 1, 1)),
    );
    await repo.agregarEquipo(
      id,
      DatosEquipo(
          tipo: 'Router', propiedad: PropiedadEquipo.netmax, fechaEntrega: DateTime(2025, 6, 1)),
    );
    await repo.registrarRetiro(antena, DateTime(2026, 11, 3));

    final equipos = await repo.vigilarEquipos(id).first;
    expect(equipos.map((e) => e.tipo), ['Router', 'Antena']);
    expect(equipos.last.fechaRetiro, DateTime(2026, 11, 3));
  });
}
