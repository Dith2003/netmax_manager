import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netmax_manager/core/mes.dart';
import 'package:netmax_manager/data/db/database.dart';
import 'package:netmax_manager/data/repositories/clientes_repository.dart';
import 'package:netmax_manager/data/repositories/dashboard_repository.dart';
import 'package:netmax_manager/data/repositories/pagos_repository.dart';
import 'package:netmax_manager/data/repositories/vencimientos_repository.dart';

void main() {
  late AppDatabase db;
  late ClientesRepository clientes;
  late PagosRepository pagos;
  late DashboardRepository dashboard;
  final hoy = DateTime(2026, 11, 3, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clientes = ClientesRepository(db, ahora: () => hoy);
    pagos = PagosRepository(db, ahora: () => hoy);
    dashboard = DashboardRepository(db);
  });

  tearDown(() => db.close());

  Future<int> cliente(String nombre, {int diaCorte = 5, Mes? primerMes}) async {
    final planId = (await clientes.vigilarPlanes().first).first.id;
    return clientes.crearCliente(DatosCliente(
      nombre: nombre,
      planId: planId,
      precioMensual: 25000,
      diaCorte: diaCorte,
      tipoContratacion: TipoContratacion.equipoPropio,
      fechaAlta: DateTime(2026, 10, 1),
      primerMesCobro: primerMes ?? Mes(2026, 10),
    ));
  }

  test('resumen con clientes, pagos, adeudos y próximos vencimientos', () async {
    // Ana: oct y nov (vence 5-nov). Paga 2 meses hoy.
    final ana = await cliente('Ana');
    await pagos.registrarPago(ana, DatosPago(monto: 50000, fecha: DateTime(2026, 11, 2)));

    // Beto: oct y nov (vence 8-nov). No paga: debe oct; nov es próximo vencimiento.
    await cliente('Beto', diaCorte: 8);

    // Caro: suspendida, con un cargo extra.
    final caro = await cliente('Caro', primerMes: Mes(2026, 11));
    await clientes.cambiarEstado(caro, EstadoCliente.suspendido);
    await VencimientosRepository(db).agregarCargo(
        clienteId: caro, concepto: 'Antena', monto: 80000, fecha: DateTime(2026, 11, 1));

    final r = await dashboard.calcularResumen(hoy);

    expect(r.mes, Mes(2026, 11));
    expect(r.cobradoMes, 50000);
    expect(r.pagosMes, 1);
    // Mensualidades de nov: Ana (pagada), Beto y Caro (sin pagar).
    expect(r.esperadoMes, 75000);
    expect(r.cubiertoMes, 25000);
    // Vencido: oct de Beto + cargo de Caro (nov de Caro vence el 5: aún no).
    expect(r.porCobrar, 25000 + 80000);
    expect(r.clientesConAdeudo, 2);
    expect(r.activos, 2);
    expect(r.suspendidos, 1);
    // Próximos 7 días: Beto (8-nov). Caro está suspendida.
    expect(r.proximosVencimientos.map((m) => m.cliente), ['Beto']);
    expect(r.pagosRecientes.single.cliente, 'Ana');
  });

  test('el resumen se recalcula al registrar un pago', () async {
    final ana = await cliente('Ana');
    final stream = dashboard.vigilarResumen(hoy);
    final valores = <int>[];
    final sub = stream.listen((r) => valores.add(r.cobradoMes));

    await Future<void>.delayed(const Duration(milliseconds: 50));
    await pagos.registrarPago(ana, DatosPago(monto: 25000, fecha: DateTime(2026, 11, 3)));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await sub.cancel();

    expect(valores.first, 0);
    expect(valores.last, 25000);
  });
}
