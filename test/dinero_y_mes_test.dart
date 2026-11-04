import 'package:flutter_test/flutter_test.dart';
import 'package:netmax_manager/core/dinero.dart';
import 'package:netmax_manager/core/mes.dart';

void main() {
  group('formatoDinero', () {
    test('formatea centavos con separador de miles', () {
      expect(formatoDinero(25000), r'$250.00');
      expect(formatoDinero(125050), r'$1,250.50');
      expect(formatoDinero(100000000), r'$1,000,000.00');
      expect(formatoDinero(5), r'$0.05');
      expect(formatoDinero(-30000), r'-$300.00');
    });
  });

  group('textoACentavos', () {
    test('acepta distintos formatos', () {
      expect(textoACentavos('250'), 25000);
      expect(textoACentavos('250.5'), 25050);
      expect(textoACentavos(r'$1,250.00'), 125000);
      expect(textoACentavos(' 300 '), 30000);
    });

    test('rechaza textos no válidos', () {
      expect(() => textoACentavos(''), throwsFormatException);
      expect(() => textoACentavos('abc'), throwsFormatException);
      expect(() => textoACentavos('10.123'), throwsFormatException);
      expect(() => textoACentavos('-50'), throwsFormatException);
    });
  });

  group('Mes', () {
    test('diciembre pasa a enero del año siguiente', () {
      expect(Mes(2026, 12).siguiente(), Mes(2027, 1));
    });

    test('lee y escribe el formato YYYY-MM', () {
      expect(Mes.parse('2026-03'), Mes(2026, 3));
      expect(Mes(2026, 3).toString(), '2026-03');
      expect(() => Mes.parse('2026-3'), throwsFormatException);
      expect(() => Mes(2026, 13), throwsArgumentError);
    });

    test('calcula la fecha de vencimiento con el día de corte', () {
      expect(Mes(2026, 2).fechaVencimiento(28), DateTime(2026, 2, 28));
      expect(() => Mes(2026, 2).fechaVencimiento(31), throwsArgumentError);
    });

    test('nombre en español', () {
      expect(Mes(2026, 11).nombre, 'noviembre 2026');
    });
  });

  test('monto corto para gráficas', () {
    expect(formatoDineroCorto(85000), r'$850');
    expect(formatoDineroCorto(485000), r'$4.9 mil');
    expect(formatoDineroCorto(1000000), r'$10 mil');
    expect(formatoDineroCorto(250000000), r'$2.5 M');
  });
}
