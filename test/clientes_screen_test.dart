import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netmax_manager/data/db/database.dart';
import 'package:netmax_manager/data/repositories/clientes_repository.dart';
import 'package:netmax_manager/main.dart';
import 'package:netmax_manager/providers/providers.dart';

void main() {
  testWidgets('la lista muestra los clientes activos y busca', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = ClientesRepository(db);

    await tester.runAsync(() async {
      final planId = (await repo.vigilarPlanes().first).first.id;
      for (final nombre in ['Ana López', 'Beto Ruiz']) {
        await repo.crearCliente(DatosCliente(
          nombre: nombre,
          planId: planId,
          precioMensual: 25000,
          diaCorte: 5,
          tipoContratacion: TipoContratacion.equipoPropio,
          fechaAlta: DateTime(2026, 11, 3),
        ));
      }
    });

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const NetMaxApp(),
    ));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();

    expect(find.text('Ana López'), findsOneWidget);
    expect(find.text('Beto Ruiz'), findsOneWidget);
    expect(find.text('2 clientes'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'beto');
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();

    expect(find.text('Ana López'), findsNothing);
    expect(find.text('Beto Ruiz'), findsOneWidget);

    // Desmontar la app antes de cerrar la base de datos.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(db.close);
  });
}
