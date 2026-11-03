import 'package:flutter_test/flutter_test.dart';
import 'package:netmax_manager/domain/clientes.dart';

void main() {
  group('búsqueda', () {
    test('ignora acentos y mayúsculas', () {
      expect(normalizar('Ángel NÚÑEZ'), 'angel nunez');
      expect(coincideBusqueda('angel', ['Ángel Núñez']), isTrue);
      expect(coincideBusqueda('NUÑEZ', ['Ángel Núñez']), isTrue);
    });

    test('busca en todos los campos y tolera nulos', () {
      expect(coincideBusqueda('771', ['Ana', null, '7711234567']), isTrue);
      expect(coincideBusqueda('centro', ['Ana', null, 'Centro']), isTrue);
      expect(coincideBusqueda('luis', ['Ana', null]), isFalse);
    });

    test('búsqueda vacía coincide con todo', () {
      expect(coincideBusqueda('  ', ['Ana']), isTrue);
    });
  });

  group('validaciones', () {
    test('nombre', () {
      expect(validarNombre(''), isNotNull);
      expect(validarNombre('Al'), isNotNull);
      expect(validarNombre('Ana López'), isNull);
    });

    test('teléfono opcional de 10 dígitos', () {
      expect(validarTelefono(''), isNull);
      expect(validarTelefono('771 123 4567'), isNull);
      expect(validarTelefono('(771) 123-4567'), isNull);
      expect(validarTelefono('12345'), isNotNull);
      expect(validarTelefono('77112345ab'), isNotNull);
      expect(limpiarTelefono('(771) 123-4567'), '7711234567');
      expect(limpiarTelefono('  '), isNull);
    });

    test('montos', () {
      expect(validarMontoObligatorio(''), isNotNull);
      expect(validarMontoObligatorio('0'), isNotNull);
      expect(validarMontoObligatorio('abc'), isNotNull);
      expect(validarMontoObligatorio('300'), isNull);
      expect(validarMontoOpcional(''), isNull);
      expect(validarMontoOpcional('1500.50'), isNull);
      expect(validarMontoOpcional('x'), isNotNull);
    });
  });

  test('día de corte sugerido nunca pasa de 28', () {
    expect(diaCorteSugerido(DateTime(2026, 11, 3)), 3);
    expect(diaCorteSugerido(DateTime(2026, 10, 31)), 28);
  });

  test('aviso de equipo prestado sin registrar', () {
    expect(
      faltaRegistrarEquipoPrestado(esEquipoPrestado: true, equiposNetmaxInstalados: 0),
      isTrue,
    );
    expect(
      faltaRegistrarEquipoPrestado(esEquipoPrestado: true, equiposNetmaxInstalados: 1),
      isFalse,
    );
    expect(
      faltaRegistrarEquipoPrestado(esEquipoPrestado: false, equiposNetmaxInstalados: 0),
      isFalse,
    );
  });
}
