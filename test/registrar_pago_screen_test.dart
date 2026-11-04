import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netmax_manager/core/mes.dart';
import 'package:netmax_manager/data/db/database.dart';
import 'package:netmax_manager/domain/cobranza.dart';
import 'package:netmax_manager/providers/providers.dart';
import 'package:netmax_manager/screens/pagos/registrar_pago_screen.dart';

/// Pantalla de pago con datos simulados: un cliente que debe octubre 2026.
void main() {
  final cliente = Cliente(
    id: 1,
    nombre: 'Ana López',
    planId: 1,
    precioMensual: 25000,
    diaCorte: 5,
    tipoContratacion: TipoContratacion.equipoPropio,
    fechaAlta: DateTime(2026, 10, 1),
    estado: EstadoCliente.activo,
    creadoEn: DateTime(2026, 10, 1),
  );
  final periodos = [
    PeriodoSaldo(
      id: 10,
      mes: Mes(2026, 10),
      vencimiento: DateTime(2026, 10, 5),
      monto: 25000,
    ),
  ];

  var cargos = <CargoSaldo>[];
  setUp(() => cargos = []);

  Future<void> abrirPantalla(WidgetTester tester) async {
    // Pantalla alta para que toda la lista quede visible.
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        clienteProvider.overrideWith((ref, id) => Stream.value(cliente)),
        periodosProvider.overrideWith((ref, id) => Stream.value(periodos)),
        cargosProvider.overrideWith((ref, id) => Stream.value(cargos)),
        siguienteFolioProvider.overrideWith((ref) async => 129),
      ],
      child: const MaterialApp(home: RegistrarPagoScreen(clienteId: 1)),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('sugiere lo que debe y muestra el reparto', (tester) async {
    await abrirPantalla(tester);

    expect(find.text('Ana López'), findsOneWidget);
    // El monto sugerido es el adeudo ($250).
    expect(find.widgetWithText(TextFormField, '250'), findsOneWidget);
    expect(find.text('oct 2026'), findsOneWidget);
    expect(find.text('Mes completo'), findsOneWidget);
  });

  testWidgets('un pago de \$600 cubre octubre, adelanta noviembre y abona diciembre',
      (tester) async {
    await abrirPantalla(tester);

    await tester.enterText(find.byType(TextFormField).first, '600');
    await tester.pumpAndSettle();

    expect(find.text('oct 2026'), findsOneWidget);
    expect(find.text('nov 2026'), findsOneWidget);
    expect(find.text('dic 2026'), findsOneWidget);
    expect(find.text('Adelantado · Mes completo'), findsOneWidget);
    expect(find.text(r'Adelantado · Abono, faltan $150.00'), findsOneWidget);
  });

  testWidgets('con un monto no válido no deja registrar', (tester) async {
    await abrirPantalla(tester);

    await tester.enterText(find.byType(TextFormField).first, 'abc');
    await tester.pumpAndSettle();

    expect(find.text('Escribe un monto válido para ver el reparto.'), findsOneWidget);
    final boton = tester.widget<FilledButton>(find
        .ancestor(
          of: find.text('Registrar pago'),
          matching: find.byWidgetPredicate((w) => w is FilledButton),
        )
        .first);
    expect(boton.onPressed, isNull);
  });

  testWidgets('un cargo extra anterior se cubre antes que el mes', (tester) async {
    cargos = [
      CargoSaldo(id: 7, concepto: 'Antena no devuelta', fecha: DateTime(2026, 9, 20), monto: 80000),
    ];
    await abrirPantalla(tester);

    // Sugiere lo que debe: $800 del cargo + $250 de octubre.
    expect(find.widgetWithText(TextFormField, '1050'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, '900');
    await tester.pumpAndSettle();

    expect(find.text('Antena no devuelta'), findsOneWidget);
    expect(find.text('Cargo extra · liquidado'), findsOneWidget);
    expect(find.text(r'Abono, faltan $150.00'), findsOneWidget);
  });

  testWidgets('el folio lo asigna el sistema y la referencia solo aparece con transferencia',
      (tester) async {
    await abrirPantalla(tester);

    expect(find.text('Folio del comprobante'), findsOneWidget);
    expect(find.text('N° 000129'), findsOneWidget);
    // El folio no es un campo de texto: no se puede escribir.
    expect(find.widgetWithText(TextField, 'N° 000129'), findsNothing);
    expect(find.text('Referencia bancaria (opcional)'), findsNothing);

    await tester.tap(find.text('Efectivo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transferencia').last);
    await tester.pumpAndSettle();
    expect(find.text('Referencia bancaria (opcional)'), findsOneWidget);
  });
}
