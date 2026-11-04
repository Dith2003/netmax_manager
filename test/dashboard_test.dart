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

  group('evolución', () {
    test('últimos meses termina en el mes indicado', () {
      final m = ultimosMeses(Mes(2026, 2), 4);
      expect(m.map((x) => x.toString()), ['2025-11', '2025-12', '2026-01', '2026-02']);
    });

    test('cobranza por mes con meses sin pagos en cero', () {
      final serie = serieCobranza([
        pago(DateTime(2026, 9, 3), 25000),
        pago(DateTime(2026, 9, 20), 30000),
        pago(DateTime(2026, 11, 1), 25000),
        pago(DateTime(2025, 1, 1), 99999), // fuera del periodo
      ], nov, meses: 3);
      expect(serie.map((c) => c.total), [55000, 0, 25000]);
      expect(serie.map((c) => c.pagos), [2, 0, 1]);
    });

    test('actividad: altas por fecha de alta y cambios del historial', () {
      final serie = serieActividad(
        altas: [DateTime(2026, 10, 3), DateTime(2026, 11, 1), DateTime(2026, 11, 2)],
        cambios: [
          (fecha: DateTime(2026, 11, 1), anterior: null, nuevo: EstadoCliente.activo), // alta
          (fecha: DateTime(2026, 10, 5), anterior: EstadoCliente.activo, nuevo: EstadoCliente.suspendido),
          (fecha: DateTime(2026, 11, 5), anterior: EstadoCliente.suspendido, nuevo: EstadoCliente.activo),
          (fecha: DateTime(2026, 11, 9), anterior: EstadoCliente.activo, nuevo: EstadoCliente.cancelado),
        ],
        hasta: nov,
        meses: 2,
      );
      expect(serie.first.mes, Mes(2026, 10));
      expect(serie.first.altas, 1);
      expect(serie.first.suspensiones, 1);
      expect(serie.last.altas, 2);
      expect(serie.last.reactivaciones, 1);
      expect(serie.last.cancelaciones, 1);
    });
  });
}
