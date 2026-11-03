import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netmax_manager/core/mes.dart';
import 'package:netmax_manager/data/db/database.dart';
import 'package:netmax_manager/data/repositories/clientes_repository.dart';
import 'package:netmax_manager/data/repositories/pagos_repository.dart';
import 'package:netmax_manager/domain/cobranza.dart';

void main() {
  late AppDatabase db;
  late ClientesRepository clientes;
  late PagosRepository pagos;
  late int clienteId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    clientes = ClientesRepository(db);
    pagos = PagosRepository(db);
    final planId = (await clientes.vigilarPlanes().first).first.id;
    clienteId = await clientes.crearCliente(DatosCliente(
      nombre: 'Ana López',
      planId: planId,
      precioMensual: 25000,
      diaCorte: 5,
      tipoContratacion: TipoContratacion.equipoPropio,
      fechaAlta: DateTime(2026, 9, 1),
    ));
  });

  tearDown(() => db.close());

  DatosPago pago(int monto, {DateTime? fecha}) =>
      DatosPago(monto: monto, fecha: fecha ?? DateTime(2026, 11, 3));

  test('primer pago de 3 meses crea sep, oct y nov desde la fecha de alta', () async {
    await pagos.registrarPago(clienteId, pago(75000));

    final periodos = await pagos.obtenerPeriodos(clienteId);
    expect(periodos.map((p) => p.mes.toString()), ['2026-09', '2026-10', '2026-11']);
    expect(periodos.every((p) => p.liquidado), isTrue);
    expect(periodos.first.vencimiento, DateTime(2026, 9, 5));
    expect(pagadoHasta(periodos), Mes(2026, 11));
  });

  test('un abono parcial deja saldo y el siguiente pago lo completa primero', () async {
    await pagos.registrarPago(clienteId, pago(10000));
    var periodos = await pagos.obtenerPeriodos(clienteId);
    expect(periodos.single.saldo, 15000);

    await pagos.registrarPago(clienteId, pago(40000));
    periodos = await pagos.obtenerPeriodos(clienteId);
    expect(periodos.map((p) => p.saldo), [0, 0]);
    expect(periodos.map((p) => p.mes.toString()), ['2026-09', '2026-10']);
  });

  test('el historial de pagos indica qué meses cubrió cada pago', () async {
    await pagos.registrarPago(clienteId, pago(25000, fecha: DateTime(2026, 9, 2)));
    await pagos.registrarPago(clienteId, pago(50000, fecha: DateTime(2026, 10, 4)));

    final lista = await pagos.vigilarPagos(clienteId).first;
    expect(lista.length, 2);
    // El más reciente primero.
    expect(lista.first.pago.monto, 50000);
    expect(lista.first.meses.map((m) => m.mes.toString()), ['2026-10', '2026-11']);
    expect(lista.last.meses.single.mes, Mes(2026, 9));
  });

  test('cancelar un pago lo conserva y regresa el saldo de los meses', () async {
    final id = await pagos.registrarPago(clienteId, pago(50000));
    await pagos.cancelarPago(id, motivo: 'Capturado dos veces');

    final periodos = await pagos.obtenerPeriodos(clienteId);
    expect(periodos.map((p) => p.saldo), [25000, 25000]);

    final lista = await pagos.vigilarPagos(clienteId).first;
    expect(lista.single.pago.cancelado, isTrue);
    expect(lista.single.pago.notas, contains('Capturado dos veces'));

    // Un pago nuevo vuelve a cubrir septiembre primero.
    await pagos.registrarPago(clienteId, pago(25000));
    final despues = await pagos.obtenerPeriodos(clienteId);
    expect(despues.map((p) => p.saldo), [0, 25000]);
  });

  test('si cambia el precio, los meses ya creados conservan su monto', () async {
    await pagos.registrarPago(clienteId, pago(10000)); // crea sep a $250 con abono
    final c = (await clientes.obtenerCliente(clienteId))!;
    await clientes.actualizarCliente(
      clienteId,
      DatosCliente(
        nombre: c.nombre,
        planId: c.planId,
        precioMensual: 30000,
        diaCorte: c.diaCorte,
        tipoContratacion: c.tipoContratacion,
        fechaAlta: c.fechaAlta,
      ),
    );
    await pagos.registrarPago(clienteId, pago(45000)); // 150 de sep + 300 de oct

    final periodos = await pagos.obtenerPeriodos(clienteId);
    expect(periodos.map((p) => p.monto), [25000, 30000]);
    expect(periodos.every((p) => p.liquidado), isTrue);
  });

  test('no permite pagos a clientes cancelados', () async {
    await clientes.cambiarEstado(clienteId, EstadoCliente.cancelado);
    expect(
      () => pagos.registrarPago(clienteId, pago(25000)),
      throwsA(isA<PagoNoPermitido>()),
    );
  });

  test('no permite adelantar más de 24 meses en un solo pago', () async {
    expect(
      () => pagos.registrarPago(clienteId, pago(25000 * 25)),
      throwsA(isA<PagoNoPermitido>()),
    );
    expect(await pagos.obtenerPeriodos(clienteId), isEmpty);
  });
}
