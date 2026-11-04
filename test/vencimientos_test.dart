import 'package:flutter_test/flutter_test.dart';
import 'package:netmax_manager/core/mes.dart';
import 'package:netmax_manager/data/db/enums.dart';
import 'package:netmax_manager/domain/vencimientos.dart';

CambioEstado cambio(DateTime fecha, EstadoCliente estado) => (fecha: fecha, estado: estado);

void main() {
  group('primer mes de cobro', () {
    test('se sugiere el mes siguiente al alta', () {
      expect(primerMesSugerido(DateTime(2026, 9, 15)), Mes(2026, 10));
      expect(primerMesSugerido(DateTime(2026, 12, 3)), Mes(2027, 1));
    });

    test('si no está guardado se usa el mes de alta', () {
      expect(primerMesDeCobro(primerMesCobro: null, fechaAlta: DateTime(2026, 9, 15)),
          Mes(2026, 9));
      expect(primerMesDeCobro(primerMesCobro: '2026-10', fechaAlta: DateTime(2026, 9, 15)),
          Mes(2026, 10));
    });

    test('opciones: desde el mes del alta hasta 3 meses después de hoy', () {
      final opciones = opcionesPrimerMes(DateTime(2026, 9, 15), DateTime(2026, 11, 3));
      expect(opciones.first, Mes(2026, 9));
      expect(opciones.last, Mes(2027, 2));
      expect(opciones.length, 6);
    });
  });

  group('estadoEnFecha', () {
    test('con dos cambios a la misma hora cuenta el último registrado', () {
      final mismaHora = DateTime(2026, 11, 3, 12);
      final historial = [
        cambio(mismaHora, EstadoCliente.activo),
        cambio(mismaHora, EstadoCliente.suspendido),
      ];
      expect(estadoEnFecha(historial, DateTime(2026, 12, 5)), EstadoCliente.suspendido);
    });

    test('sin historial previo se considera activo', () {
      expect(estadoEnFecha([], DateTime(2026, 1, 1)), EstadoCliente.activo);
      expect(
        estadoEnFecha([cambio(DateTime(2026, 11, 3, 10), EstadoCliente.activo)],
            DateTime(2025, 1, 5)),
        EstadoCliente.activo,
      );
    });

    test('toma el último cambio hasta el final de ese día', () {
      final historial = [
        cambio(DateTime(2026, 9, 1, 9), EstadoCliente.activo),
        cambio(DateTime(2026, 10, 5, 18), EstadoCliente.suspendido),
        cambio(DateTime(2026, 12, 1, 10), EstadoCliente.activo),
      ];
      expect(estadoEnFecha(historial, DateTime(2026, 10, 4)), EstadoCliente.activo);
      // Se suspendió el mismo día (en la tarde): ese día ya cuenta como suspendido.
      expect(estadoEnFecha(historial, DateTime(2026, 10, 5)), EstadoCliente.suspendido);
      expect(estadoEnFecha(historial, DateTime(2026, 11, 5)), EstadoCliente.suspendido);
      expect(estadoEnFecha(historial, DateTime(2026, 12, 5)), EstadoCliente.activo);
    });
  });

  group('mesesPorGenerar', () {
    test('genera desde el primer mes hasta el mes actual', () {
      final meses = mesesPorGenerar(
        primerMes: Mes(2026, 9),
        existentes: {},
        diaCorte: 5,
        historial: [],
        hoy: DateTime(2026, 11, 3),
      );
      expect(meses, [Mes(2026, 9), Mes(2026, 10), Mes(2026, 11)]);
    });

    test('no repite meses que ya existen', () {
      final meses = mesesPorGenerar(
        primerMes: Mes(2026, 9),
        existentes: {Mes(2026, 9), Mes(2026, 11), Mes(2026, 12)},
        diaCorte: 5,
        historial: [],
        hoy: DateTime(2026, 11, 3),
      );
      expect(meses, [Mes(2026, 10)]);
    });

    test('no genera meses mientras está suspendido', () {
      final meses = mesesPorGenerar(
        primerMes: Mes(2026, 9),
        existentes: {},
        diaCorte: 5,
        historial: [
          cambio(DateTime(2026, 9, 1), EstadoCliente.activo),
          cambio(DateTime(2026, 10, 2), EstadoCliente.suspendido),
          cambio(DateTime(2026, 12, 10), EstadoCliente.activo),
        ],
        hoy: DateTime(2027, 1, 20),
      );
      // oct y nov vencen suspendido; dic vence el 5 (aún suspendido); ene sí.
      expect(meses, [Mes(2026, 9), Mes(2027, 1)]);
    });

    test('si se suspende después del vencimiento, ese mes sí se cobra', () {
      final meses = mesesPorGenerar(
        primerMes: Mes(2026, 10),
        existentes: {},
        diaCorte: 5,
        historial: [cambio(DateTime(2026, 10, 20), EstadoCliente.suspendido)],
        hoy: DateTime(2026, 12, 20),
      );
      expect(meses, [Mes(2026, 10)]);
    });

    test('cliente cancelado: no se generan meses después de la cancelación', () {
      final meses = mesesPorGenerar(
        primerMes: Mes(2026, 9),
        existentes: {},
        diaCorte: 5,
        historial: [cambio(DateTime(2026, 9, 20), EstadoCliente.cancelado)],
        hoy: DateTime(2027, 3, 1),
      );
      expect(meses, [Mes(2026, 9)]);
    });

    test('primer mes en el futuro: todavía no genera nada', () {
      final meses = mesesPorGenerar(
        primerMes: Mes(2026, 12),
        existentes: {},
        diaCorte: 5,
        historial: [],
        hoy: DateTime(2026, 11, 3),
      );
      expect(meses, isEmpty);
    });
  });

  test('situación del mes', () {
    final hoy = DateTime(2026, 11, 10);
    SituacionMes s({bool cortesia = false, int saldo = 25000, int pagado = 0, int dia = 5}) =>
        situacionMes(
          esCortesia: cortesia,
          saldo: saldo,
          pagado: pagado,
          vencimiento: DateTime(2026, 11, dia),
          hoy: hoy,
        );
    expect(s(cortesia: true), SituacionMes.cortesia);
    expect(s(saldo: 0, pagado: 25000), SituacionMes.pagado);
    expect(s(), SituacionMes.vencido);
    expect(s(dia: 15), SituacionMes.pendiente);
    expect(s(dia: 15, saldo: 10000, pagado: 15000), SituacionMes.abonado);
  });

  test('Mes.anterior', () {
    expect(Mes(2026, 1).anterior(), Mes(2025, 12));
    expect(Mes(2026, 5).anterior(), Mes(2026, 4));
  });
}
