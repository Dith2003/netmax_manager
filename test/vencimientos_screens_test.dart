import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netmax_manager/core/mes.dart';
import 'package:netmax_manager/data/db/database.dart';
import 'package:netmax_manager/data/repositories/vencimientos_repository.dart';
import 'package:netmax_manager/domain/cobranza.dart';
import 'package:netmax_manager/providers/providers.dart';
import 'package:netmax_manager/screens/adeudos/adeudos_screen.dart';
import 'package:netmax_manager/screens/clientes/estado_cuenta_screen.dart';

/// Pantallas de estado de cuenta y adeudos con datos simulados.
void main() {

  Future<void> pantallaAlta(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('estado de cuenta: muestra cada mes con su situación', (tester) async {
    await pantallaAlta(tester);
    final cliente = Cliente(
      id: 1,
      nombre: 'Ana López',
      planId: 1,
      precioMensual: 25000,
      diaCorte: 5,
      tipoContratacion: TipoContratacion.equipoPropio,
      fechaAlta: DateTime(2026, 8, 1),
      primerMesCobro: '2026-08',
      estado: EstadoCliente.activo,
      creadoEn: DateTime(2026, 8, 1),
    );
    PeriodoSaldo p(int id, int mes, {int pagado = 0, bool cortesia = false}) => PeriodoSaldo(
          id: id,
          mes: Mes(2026, mes),
          vencimiento: DateTime(2026, mes, 5),
          monto: 25000,
          pagado: pagado,
          esCortesia: cortesia,
        );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        clienteProvider.overrideWith((ref, id) => Stream.value(cliente)),
        periodosProvider.overrideWith((ref, id) => Stream.value([
              p(1, 8, cortesia: true),
              p(2, 9, pagado: 25000),
              p(3, 10, pagado: 10000),
            ])),
        cargosProvider.overrideWith((ref, id) => Stream.value([
              CargoSaldo(
                  id: 1, concepto: 'Router no devuelto', fecha: DateTime(2026, 10, 20), monto: 60000),
            ])),
      ],
      child: const MaterialApp(home: EstadoCuentaScreen(clienteId: 1)),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Estado de cuenta · Ana López'), findsOneWidget);
    expect(find.text(r'Debe $750.00'), findsOneWidget);
    expect(find.text('Cargos extra'), findsOneWidget);
    expect(find.text('Router no devuelto'), findsOneWidget);
    expect(find.text('agosto 2026'), findsOneWidget);
    expect(find.textContaining('Cortesía'), findsOneWidget);
    expect(find.textContaining('Pagado'), findsOneWidget);
    expect(find.text(r'falta $150.00'), findsOneWidget);
    expect(find.text('Agregar'), findsOneWidget);
  });

  testWidgets('adeudos: total por cobrar y clientes del que más debe al que menos',
      (tester) async {
    final adeudos = [
      AdeudoCliente(
        clienteId: 2,
        nombre: 'Beto Ruiz',
        zona: 'Centro',
        estado: EstadoCliente.suspendido,
        adeudo: EstadoAdeudo(total: 75000, meses: 3, vencidoDesde: DateTime(2026, 8, 5)),
      ),
      AdeudoCliente(
        clienteId: 1,
        nombre: 'Ana López',
        estado: EstadoCliente.activo,
        adeudo: EstadoAdeudo(total: 25000, meses: 1, vencidoDesde: DateTime(2026, 10, 5)),
      ),
    ];

    await tester.pumpWidget(ProviderScope(
      overrides: [adeudosProvider.overrideWith((ref) => Stream.value(adeudos))],
      child: const MaterialApp(home: AdeudosScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text(r'Total por cobrar: $1,000.00'), findsOneWidget);
    expect(find.text('2 clientes con adeudo'), findsOneWidget);
    expect(find.text('Beto Ruiz'), findsOneWidget);
    expect(find.text('Suspendido'), findsOneWidget);
    expect(find.text(r'$750.00'), findsOneWidget);
  });
}
