import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netmax_manager/core/mes.dart';
import 'package:netmax_manager/data/db/database.dart';
import 'package:netmax_manager/data/repositories/clientes_repository.dart';
import 'package:netmax_manager/data/repositories/pagos_repository.dart';
import 'package:netmax_manager/data/repositories/vencimientos_repository.dart';

void main() {
  late AppDatabase db;
  late ClientesRepository clientes;
  late PagosRepository pagos;
  late VencimientosRepository vencimientos;
  late DateTime ahora;
  late int planId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    ahora = DateTime(2026, 11, 3, 12);
    clientes = ClientesRepository(db, ahora: () => ahora);
    pagos = PagosRepository(db, ahora: () => ahora);
    vencimientos = VencimientosRepository(db);
    planId = (await clientes.vigilarPlanes().first).first.id;
  });

  tearDown(() => db.close());

  Future<int> nuevoCliente(String nombre, {required Mes primerMes, int diaCorte = 5}) {
    return clientes.crearCliente(DatosCliente(
      nombre: nombre,
      planId: planId,
      precioMensual: 25000,
      diaCorte: diaCorte,
      tipoContratacion: TipoContratacion.equipoPropio,
      fechaAlta: DateTime(2026, 9, 1),
      primerMesCobro: primerMes,
    ));
  }

  Future<List<String>> meses(int clienteId) async =>
      (await pagos.obtenerPeriodos(clienteId)).map((p) => p.mes.toString()).toList();

  test('al crear el cliente se generan sus meses hasta el mes actual', () async {
    final id = await nuevoCliente('Ana', primerMes: Mes(2026, 9));
    expect(await meses(id), ['2026-09', '2026-10', '2026-11']);
  });

  test('el primer mes de cobro puede ser el mes siguiente al alta', () async {
    final id = await nuevoCliente('Ana', primerMes: Mes(2026, 10));
    expect(await meses(id), ['2026-10', '2026-11']);
  });

  test('la lista de adeudos solo cuenta meses vencidos', () async {
    final ana = await nuevoCliente('Ana', primerMes: Mes(2026, 9));
    final beto = await nuevoCliente('Beto', primerMes: Mes(2026, 11));
    await pagos.registrarPago(ana, DatosPago(monto: 25000, fecha: ahora));

    final adeudos = await vencimientos.vigilarAdeudos(DateTime(2026, 11, 3)).first;
    // Ana: oct vencido ($250); nov vence el 5. Beto: nov aún no vence.
    expect(adeudos.single.clienteId, ana);
    expect(adeudos.single.adeudo.total, 25000);
    expect(adeudos.any((a) => a.clienteId == beto), isFalse);
  });

  test('suspendido: no se generan meses; al reactivar se cobra desde entonces', () async {
    final id = await nuevoCliente('Ana', primerMes: Mes(2026, 9));
    await clientes.cambiarEstado(id, EstadoCliente.suspendido, motivo: 'Falta de pago');

    // Pasan los meses: dic y ene no se generan.
    await vencimientos.generarParaCliente(id, DateTime(2027, 1, 20));
    expect(await meses(id), ['2026-09', '2026-10', '2026-11']);

    // Se reactiva el 10 de enero (ene vence el 5: no se cobra). Feb sí.
    ahora = DateTime(2027, 1, 10);
    await clientes.cambiarEstado(id, EstadoCliente.activo);
    await vencimientos.generarParaCliente(id, DateTime(2027, 2, 6));
    expect(await meses(id), ['2026-09', '2026-10', '2026-11', '2027-02']);

    // Sigue debiendo lo que tenía vencido antes de suspenderse.
    final adeudos = await vencimientos.vigilarAdeudos(DateTime(2027, 2, 6)).first;
    expect(adeudos.single.adeudo.meses, 4);
  });

  test('cobro manual: agregar un mes a un cliente suspendido', () async {
    final id = await nuevoCliente('Ana', primerMes: Mes(2026, 11));
    await clientes.cambiarEstado(id, EstadoCliente.suspendido);
    await vencimientos.agregarMes(id, Mes(2026, 12));
    expect(await meses(id), ['2026-11', '2026-12']);

    expect(() => vencimientos.agregarMes(id, Mes(2026, 12)),
        throwsA(isA<OperacionNoPermitida>()));
  });

  test('cortesía: el mes no genera adeudo; no se permite si ya tiene pagos', () async {
    final id = await nuevoCliente('Ana', primerMes: Mes(2026, 9));
    var periodos = await pagos.obtenerPeriodos(id);
    await vencimientos.marcarCortesia(periodos.first.id!, cortesia: true);

    final adeudos = await vencimientos.vigilarAdeudos(DateTime(2026, 11, 3)).first;
    expect(adeudos.single.adeudo.total, 25000); // solo octubre

    // El siguiente pago se salta la cortesía y cubre octubre.
    await pagos.registrarPago(id, DatosPago(monto: 25000, fecha: ahora));
    periodos = await pagos.obtenerPeriodos(id);
    expect(periodos[1].liquidado, isTrue);
    expect(
      () => vencimientos.marcarCortesia(periodos[1].id!, cortesia: true),
      throwsA(isA<OperacionNoPermitida>()),
    );

    // Quitar la cortesía vuelve a cobrar septiembre.
    await vencimientos.marcarCortesia(periodos.first.id!, cortesia: false);
    final despues = await vencimientos.vigilarAdeudos(DateTime(2026, 11, 3)).first;
    expect(despues.single.adeudo.total, 25000); // ahora es septiembre
  });

  test('quitar mes: solo si nunca tuvo pagos', () async {
    final id = await nuevoCliente('Ana', primerMes: Mes(2026, 10));
    await pagos.registrarPago(id, DatosPago(monto: 25000, fecha: ahora));
    final periodos = await pagos.obtenerPeriodos(id);

    expect(() => vencimientos.quitarMes(periodos.first.id!),
        throwsA(isA<OperacionNoPermitida>()));
    await vencimientos.quitarMes(periodos.last.id!);
    expect(await meses(id), ['2026-10']);
  });

  test('mover el primer mes de cobro quita los meses anteriores sin pagos', () async {
    final id = await nuevoCliente('Ana', primerMes: Mes(2026, 9));
    final c = (await clientes.obtenerCliente(id))!;
    await clientes.actualizarCliente(
      id,
      DatosCliente(
        nombre: c.nombre,
        planId: c.planId,
        precioMensual: c.precioMensual,
        diaCorte: c.diaCorte,
        tipoContratacion: c.tipoContratacion,
        fechaAlta: c.fechaAlta,
        primerMesCobro: Mes(2026, 11),
      ),
    );
    expect(await meses(id), ['2026-11']);
  });

  group('cargos extra', () {
    test('un cliente con solo un cargo aparece en adeudos', () async {
      final id = await nuevoCliente('Ana', primerMes: Mes(2026, 11));
      await vencimientos.agregarCargo(
          clienteId: id, concepto: 'Antena no devuelta', monto: 80000, fecha: DateTime(2026, 11, 1));

      final adeudos = await vencimientos.vigilarAdeudos(DateTime(2026, 11, 3)).first;
      expect(adeudos.single.adeudo.total, 80000);
      expect(adeudos.single.adeudo.cargos, 1);
      expect(adeudos.single.adeudo.meses, 0);
    });

    test('el pago cubre el cargo y queda en el historial del pago', () async {
      final id = await nuevoCliente('Ana', primerMes: Mes(2026, 10)); // oct y nov
      await vencimientos.agregarCargo(
          clienteId: id, concepto: 'Reconexión', monto: 10000, fecha: DateTime(2026, 10, 20));

      // oct (5-oct) 250 -> reconexión (20-oct) 100 -> nov (5-nov) 50
      await pagos.registrarPago(id, DatosPago(monto: 40000, fecha: ahora));

      final cargos = await vencimientos.consultaCargos(id).get();
      expect(cargos.single.liquidado, isTrue);
      final periodos = await pagos.obtenerPeriodos(id);
      expect(periodos.map((p) => p.pagado), [25000, 5000]);

      final historial = await pagos.vigilarPagos(id).first;
      expect(historial.single.cargos.single.concepto, 'Reconexión');
      expect(historial.single.meses.length, 2);
    });

    test('cancelar el pago regresa el saldo del cargo', () async {
      final id = await nuevoCliente('Ana', primerMes: Mes(2026, 12)); // sin meses aún
      final cargoId = await vencimientos.agregarCargo(
          clienteId: id, concepto: 'Antena', monto: 50000, fecha: DateTime(2026, 11, 1));
      final pagoId = await pagos.registrarPago(id, DatosPago(monto: 50000, fecha: ahora));

      // Con pago vigente no se puede cancelar el cargo.
      expect(() => vencimientos.cancelarCargo(cargoId), throwsA(isA<OperacionNoPermitida>()));

      await pagos.cancelarPago(pagoId);
      expect((await vencimientos.consultaCargos(id).get()).single.saldo, 50000);

      await vencimientos.cancelarCargo(cargoId, motivo: 'Sí devolvió la antena');
      expect(await vencimientos.consultaCargos(id).get(), isEmpty);
      final adeudos = await vencimientos.vigilarAdeudos(DateTime(2026, 11, 3)).first;
      expect(adeudos, isEmpty);
    });

    test('no permite cargos sin concepto o en cero', () async {
      final id = await nuevoCliente('Ana', primerMes: Mes(2026, 11));
      expect(
        () => vencimientos.agregarCargo(
            clienteId: id, concepto: '  ', monto: 1000, fecha: DateTime(2026, 11, 1)),
        throwsA(isA<OperacionNoPermitida>()),
      );
      expect(
        () => vencimientos.agregarCargo(
            clienteId: id, concepto: 'X', monto: 0, fecha: DateTime(2026, 11, 1)),
        throwsA(isA<OperacionNoPermitida>()),
      );
    });
  });
}
