import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netmax_manager/core/mes.dart';
import 'package:netmax_manager/data/db/enums.dart';
import 'package:netmax_manager/domain/reportes.dart';
import 'package:netmax_manager/providers/zoom.dart';
import 'package:netmax_manager/widgets/panel_lateral.dart';

DatosComprobante comprobante({
  List<({Mes mes, int monto})> meses = const [],
  List<({String concepto, int monto})> cargos = const [],
  List<({String concepto, int monto})> conceptos = const [],
}) =>
    DatosComprobante(
      pagoId: 1,
      fecha: DateTime(2026, 11, 3),
      monto: 0,
      metodo: MetodoPago.efectivo,
      cancelado: false,
      cliente: 'Ana',
      conceptos: conceptos,
      mesesCubiertos: meses,
      cargosCubiertos: cargos,
      saldoPendiente: 0,
    );

void main() {
  group('zoom', () {
    test('acercar y alejar recorren los niveles sin pasarse', () {
      expect(siguienteZoom(1.0, 1), 1.1);
      expect(siguienteZoom(1.1, 1), 1.25);
      expect(siguienteZoom(1.5, 1), 1.5);
      expect(siguienteZoom(1.0, -1), 0.9);
      expect(siguienteZoom(0.8, -1), 0.8);
      // Un valor intermedio va al nivel siguiente o anterior.
      expect(siguienteZoom(1.05, 1), 1.1);
      expect(siguienteZoom(1.05, -1), 1.0);
    });

    test('texto del porcentaje', () {
      expect(textoZoom(1.0), '100 %');
      expect(textoZoom(1.25), '125 %');
    });
  });

  group('conceptos del comprobante tipo cheque', () {
    test('agrupa meses seguidos y deja los sueltos aparte', () {
      final c = conceptosCompactos(comprobante(meses: [
        (mes: Mes(2026, 12), monto: 25000),
        (mes: Mes(2026, 10), monto: 25000),
        (mes: Mes(2026, 11), monto: 25000),
        (mes: Mes(2027, 3), monto: 10000),
      ], cargos: const [
        (concepto: 'Reconexión', monto: 10000),
      ]));
      expect(c.map((x) => x.concepto), [
        'Mensualidades oct 2026 – dic 2026 (3)',
        'Mensualidad marzo 2027',
        'Reconexión',
      ]);
      expect(c.first.monto, 75000);
    });

    test('si son muchas líneas, las últimas se suman en "Otros"', () {
      final c = conceptosCompactos(comprobante(cargos: const [
        (concepto: 'A', monto: 100),
        (concepto: 'B', monto: 200),
        (concepto: 'C', monto: 300),
        (concepto: 'D', monto: 400),
        (concepto: 'E', monto: 500),
      ]));
      expect(c.length, 4);
      expect(c.last.concepto, 'Otros 2 conceptos');
      expect(c.last.monto, 900);
    });

    test('sin detalle usa los conceptos tal cual', () {
      final c = conceptosCompactos(
          comprobante(conceptos: const [(concepto: 'Mensualidad noviembre 2026', monto: 25000)]));
      expect(c.single.concepto, 'Mensualidad noviembre 2026');
    });
  });

  testWidgets('panel lateral: muestra secciones, marca la elegida y cambia el zoom',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var elegido = -1;

    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: Row(children: [
            PanelLateral(
              destinos: const [
                DestinoPanel(
                    ruta: '/a', etiqueta: 'Inicio', icono: Icons.home, iconoSeleccionado: Icons.home),
                DestinoPanel(
                    ruta: '/b',
                    etiqueta: 'Clientes',
                    icono: Icons.people,
                    iconoSeleccionado: Icons.people),
              ],
              seleccionado: 0,
              extendido: true,
              onSeleccionar: (i) => elegido = i,
            ),
          ]),
        ),
      ),
    ));

    expect(find.text('Inicio'), findsOneWidget);
    await tester.tap(find.text('Clientes'));
    expect(elegido, 1);

    expect(find.text('100 %'), findsOneWidget);
    await tester.tap(find.byTooltip('Acercar (Ctrl +)'));
    await tester.pump();
    expect(find.text('110 %'), findsOneWidget);
  });
}
