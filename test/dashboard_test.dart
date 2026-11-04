import 'package:flutter_test/flutter_test.dart';
import 'package:netmax_manager/core/mes.dart';
import 'package:netmax_manager/data/db/enums.dart';
import 'package:netmax_manager/domain/dashboard.dart';

PagoResumen pago(DateTime fecha, int monto, {String cliente = 'Ana'}) =>
    (clienteId: 1, cliente: cliente, fecha: fecha, monto: monto);

MesResumen mes(
  String cliente,
  Mes m,
  int dia, {
  int monto = 25000,
  int pagado = 0,
  bool cortesia = false,
  EstadoCliente estado = EstadoCliente.activo,
}) =>
    (
      clienteId: 1,
      cliente: cliente,
      estado: estado,
      mes: m,
      vencimiento: m.fechaVencimiento(dia),
      monto: monto,
      pagado: pagado,
      esCortesia: cortesia,
    );

void main() {
  final nov = Mes(2026, 11);

  test('cobrado en el mes solo suma pagos con fecha de ese mes', () {
    final r = cobradoEnMes([
      pago(DateTime(2026, 10, 31), 25000),
      pago(DateTime(2026, 11, 1), 25000),
      pago(DateTime(2026, 11, 30, 18), 50000),
    ], nov);
    expect(r.total, 75000);
    expect(r.pagos, 2);
  });

  test('avance del mes: esperado sin cortesías y lo pagado sin pasarse del monto', () {
    final r = avanceDelMes([
      mes('Ana', nov, 5, pagado: 25000),
      mes('Beto', nov, 10, monto: 30000, pagado: 10000),
      mes('Caro', nov, 15, cortesia: true),
      mes('Dani', Mes(2026, 12), 5, pagado: 25000), // otro mes
    ], nov);
    expect(r.esperado, 55000);
    expect(r.cubierto, 35000);
  });

  test('próximos vencimientos: 7 días, con saldo, solo activos, por fecha', () {
    final hoy = DateTime(2026, 11, 3, 15);
    final lista = proximosAVencer([
      mes('Ana', nov, 10),
      mes('Beto', nov, 3), // vence hoy: sí
      mes('Caro', nov, 2), // ya venció: no (está en adeudos)
      mes('Dani', nov, 11), // 8 días: no
      mes('Eva', nov, 5, pagado: 25000), // pagado: no
      mes('Fer', nov, 5, cortesia: true), // cortesía: no
      mes('Gil', nov, 5, estado: EstadoCliente.suspendido), // suspendido: no
    ], hoy);
    expect(lista.map((m) => m.cliente), ['Beto', 'Ana']);
  });

  test('pagos recientes: los más nuevos primero', () {
    final lista = recientes([
      pago(DateTime(2026, 10, 1), 1, cliente: 'A'),
      pago(DateTime(2026, 11, 2), 2, cliente: 'B'),
      pago(DateTime(2026, 9, 1), 3, cliente: 'C'),
    ], n: 2);
    expect(lista.map((p) => p.cliente), ['B', 'A']);
  });

  test('avance del mes es 0 si no hay mensualidades', () {
    final r = ResumenDashboard(
      mes: nov,
      cobradoMes: 0,
      pagosMes: 0,
      esperadoMes: 0,
      cubiertoMes: 0,
      porCobrar: 0,
      clientesConAdeudo: 0,
      clientesPorEstado: const {},
      proximosVencimientos: const [],
      pagosRecientes: const [],
    );
    expect(r.avanceMes, 0);
    expect(r.activos, 0);
  });
}
