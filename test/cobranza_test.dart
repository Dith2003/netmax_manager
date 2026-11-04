import 'package:flutter_test/flutter_test.dart';
import 'package:netmax_manager/core/mes.dart';
import 'package:netmax_manager/domain/cobranza.dart';

/// Atajo para crear un periodo de prueba con día de corte 5.
PeriodoSaldo periodo(int id, String mes,
    {int monto = 25000, int pagado = 0, bool cortesia = false}) {
  final m = Mes.parse(mes);
  return PeriodoSaldo(
    id: id,
    mes: m,
    vencimiento: m.fechaVencimiento(5),
    monto: monto,
    pagado: pagado,
    esCortesia: cortesia,
  );
}

void main() {
  group('aplicarPago', () {
    test('un pago de un mes cubre el mes pendiente más antiguo', () {
      final r = aplicarPago(
        monto: 25000,
        periodos: [periodo(2, '2026-10'), periodo(1, '2026-09')],
        precioMensual: 25000,
        diaCorte: 5,
        primerMes: Mes(2026, 9),
      );
      expect(r.aplicaciones.length, 1);
      expect(r.aplicaciones.first.periodoId, 1); // septiembre, el más antiguo
      expect(r.aplicaciones.first.monto, 25000);
      expect(r.periodosNuevos, isEmpty);
      expect(r.sobrante, 0);
    });

    test('pago adelantado de 3 meses sin periodos crea 3 meses nuevos', () {
      final r = aplicarPago(
        monto: 75000,
        periodos: [],
        precioMensual: 25000,
        diaCorte: 10,
        primerMes: Mes(2026, 11),
      );
      expect(r.periodosNuevos.map((p) => p.mes.toString()),
          ['2026-11', '2026-12', '2027-01']);
      expect(r.periodosNuevos.first.vencimiento, DateTime(2026, 11, 10));
      expect(r.aplicaciones.every((a) => a.monto == 25000), isTrue);
      expect(r.sobrante, 0);
    });

    test('pago parcial deja saldo en el mes', () {
      final r = aplicarPago(
        monto: 10000,
        periodos: [periodo(1, '2026-10')],
        precioMensual: 25000,
        diaCorte: 5,
        primerMes: Mes(2026, 10),
      );
      expect(r.aplicaciones.single.monto, 10000);
      expect(r.periodosNuevos, isEmpty);
    });

    test('completa un mes que ya tenía abono', () {
      final r = aplicarPago(
        monto: 15000,
        periodos: [periodo(1, '2026-10', pagado: 10000)],
        precioMensual: 25000,
        diaCorte: 5,
        primerMes: Mes(2026, 10),
      );
      expect(r.aplicaciones.single.monto, 15000);
      expect(r.periodosNuevos, isEmpty);
    });

    test('se salta meses de cortesía y meses ya pagados', () {
      final r = aplicarPago(
        monto: 25000,
        periodos: [
          periodo(1, '2026-08', pagado: 25000),
          periodo(2, '2026-09', cortesia: true),
          periodo(3, '2026-10'),
        ],
        precioMensual: 25000,
        diaCorte: 5,
        primerMes: Mes(2026, 8),
      );
      expect(r.aplicaciones.single.periodoId, 3);
    });

    test('si paga más de lo que debe, adelanta meses con el precio actual', () {
      // Debe octubre ($250, precio viejo). Ahora paga $700 y su precio es $300.
      final r = aplicarPago(
        monto: 70000,
        periodos: [periodo(1, '2026-10')],
        precioMensual: 30000,
        diaCorte: 5,
        primerMes: Mes(2026, 10),
      );
      expect(r.aplicaciones.map((a) => a.monto), [25000, 30000, 15000]);
      expect(r.periodosNuevos.map((p) => p.mes.toString()), ['2026-11', '2026-12']);
      expect(r.periodosNuevos.every((p) => p.monto == 30000), isTrue);
      expect(r.sobrante, 0);
    });

    test('respeta el límite de meses nuevos y reporta el sobrante', () {
      final r = aplicarPago(
        monto: 100000,
        periodos: [],
        precioMensual: 25000,
        diaCorte: 5,
        primerMes: Mes(2026, 11),
        maxPeriodosNuevos: 2,
      );
      expect(r.periodosNuevos.length, 2);
      expect(r.sobrante, 50000);
    });

    test('la suma aplicada más el sobrante es igual al pago', () {
      final r = aplicarPago(
        monto: 123456,
        periodos: [periodo(1, '2026-09', pagado: 1000), periodo(2, '2026-10')],
        precioMensual: 25000,
        diaCorte: 5,
        primerMes: Mes(2026, 9),
      );
      final total = r.aplicaciones.fold<int>(0, (s, a) => s + a.monto);
      expect(total + r.sobrante, 123456);
    });

    test('rechaza montos en cero o negativos', () {
      expect(
        () => aplicarPago(
            monto: 0,
            periodos: [],
            precioMensual: 25000,
            diaCorte: 5,
            primerMes: Mes(2026, 11)),
        throwsArgumentError,
      );
    });
  });

  group('calcularAdeudo', () {
    test('solo cuenta meses ya vencidos y no pagados', () {
      final periodos = [
        periodo(1, '2026-08', pagado: 25000), // pagado
        periodo(2, '2026-09'), // vencido 5-sep
        periodo(3, '2026-10', pagado: 10000), // vencido 5-oct, debe 150
        periodo(4, '2026-11'), // vence 5-nov, aún no
      ];
      final a = calcularAdeudo(periodos, DateTime(2026, 11, 2));
      expect(a.total, 40000);
      expect(a.meses, 2);
      expect(a.vencidoDesde, DateTime(2026, 9, 5));
    });

    test('el día del vencimiento todavía no es adeudo', () {
      final a = calcularAdeudo([periodo(1, '2026-11')], DateTime(2026, 11, 5, 18));
      expect(a.tieneAdeudo, isFalse);
      final b = calcularAdeudo([periodo(1, '2026-11')], DateTime(2026, 11, 6));
      expect(b.tieneAdeudo, isTrue);
    });

    test('la cortesía no genera adeudo', () {
      final a = calcularAdeudo(
          [periodo(1, '2026-09', cortesia: true)], DateTime(2026, 11, 2));
      expect(a.tieneAdeudo, isFalse);
    });
  });

  group('pagadoHasta', () {
    test('devuelve el último mes pagado de forma continua', () {
      final periodos = [
        periodo(1, '2026-08', pagado: 25000),
        periodo(2, '2026-09', cortesia: true),
        periodo(3, '2026-10', pagado: 25000),
        periodo(4, '2026-11'),
        periodo(5, '2026-12', pagado: 25000),
      ];
      expect(pagadoHasta(periodos), Mes(2026, 10));
    });

    test('null si el primer mes no está pagado', () {
      expect(pagadoHasta([periodo(1, '2026-10')]), isNull);
    });
  });

  group('detalle del reparto', () {
    test('indica si cada mes queda completo y si es adelantado', () {
      final r = aplicarPago(
        monto: 30000,
        periodos: [periodo(1, '2026-10', pagado: 10000)],
        precioMensual: 25000,
        diaCorte: 5,
        primerMes: Mes(2026, 10),
      );
      final oct = r.aplicaciones[0];
      final nov = r.aplicaciones[1];
      expect(oct.completo, isTrue);
      expect(oct.esNuevo, isFalse);
      expect(oct.saldoAntes, 15000);
      expect(nov.esNuevo, isTrue);
      expect(nov.completo, isFalse);
      expect(nov.monto, 15000);
      expect(nov.saldoAntes, 25000);
    });
  });

  group('describirMeses', () {
    test('un mes, rango consecutivo y meses salteados', () {
      expect(describirMeses([]), '');
      expect(describirMeses([Mes(2026, 10)]), 'oct 2026');
      expect(describirMeses([Mes(2026, 12), Mes(2026, 11), Mes(2027, 1)]),
          'nov 2026 – ene 2027');
      expect(describirMeses([Mes(2026, 8), Mes(2026, 10)]), 'ago 2026, oct 2026');
    });
  });
}
