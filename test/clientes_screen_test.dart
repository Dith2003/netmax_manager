import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netmax_manager/data/db/database.dart';
import 'package:netmax_manager/domain/clientes.dart';
import 'package:netmax_manager/main.dart';
import 'package:netmax_manager/providers/providers.dart';

/// Prueba de la pantalla de lista con datos simulados (sin base de datos real;
/// el repositorio ya se prueba en clientes_repository_test.dart).
Cliente _cliente(int id, String nombre, {String? zona}) => Cliente(
      id: id,
      nombre: nombre,
      zona: zona,
      planId: 1,
      precioMensual: 25000,
      diaCorte: 5,
      tipoContratacion: TipoContratacion.equipoPropio,
      fechaAlta: DateTime(2026, 11, 3),
      estado: EstadoCliente.activo,
      creadoEn: DateTime(2026, 11, 3),
    );

void main() {
  final clientes = [
    _cliente(1, 'Ana López', zona: 'Centro'),
    _cliente(2, 'Beto Ruiz', zona: 'El Ranchito'),
  ];

  testWidgets('la lista muestra los clientes y filtra al buscar', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        clientesProvider.overrideWith(
          (ref, filtro) => Stream.value(clientes
              .where((c) => coincideBusqueda(filtro.busqueda, [c.nombre, c.zona]))
              .toList()),
        ),
      ],
      child: const NetMaxApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Clientes'), findsOneWidget);
    expect(find.text('2 clientes'), findsOneWidget);
    expect(find.text('Ana López'), findsOneWidget);
    expect(find.text(r'$250.00'), findsNWidgets(2));

    await tester.enterText(find.byType(TextField), 'ranchito');
    await tester.pumpAndSettle();

    expect(find.text('Ana López'), findsNothing);
    expect(find.text('Beto Ruiz'), findsOneWidget);
    expect(find.text('1 cliente'), findsOneWidget);
  });

  testWidgets('sin clientes muestra la invitación a registrar el primero', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        clientesProvider.overrideWith((ref, filtro) => Stream.value(<Cliente>[])),
      ],
      child: const NetMaxApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Aún no hay clientes'), findsOneWidget);
    expect(find.text('Nuevo cliente'), findsOneWidget);
  });
}
