import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netmax_manager/data/db/database.dart';
import 'package:netmax_manager/data/repositories/clientes_repository.dart';
import 'package:netmax_manager/providers/providers.dart';
import 'package:netmax_manager/providers/zoom.dart';
import 'package:netmax_manager/screens/clientes/acciones_cliente.dart';
import 'package:netmax_manager/screens/clientes/clientes_screen.dart';
import 'package:netmax_manager/widgets/zoom_interfaz.dart';

Cliente _cliente(int id, String nombre, EstadoCliente estado) => Cliente(
      id: id,
      nombre: nombre,
      zona: 'Centro',
      planId: 1,
      precioMensual: 25000,
      diaCorte: 5,
      tipoContratacion: TipoContratacion.equipoPropio,
      fechaAlta: DateTime(2026, 11, 3),
      estado: estado,
      creadoEn: DateTime(2026, 11, 3),
    );

/// Repositorio simulado: solo anota los cambios de estado.
class _RepoFalso extends Fake implements ClientesRepository {
  final cambios = <(int, EstadoCliente, String?)>[];

  @override
  Future<void> cambiarEstado(int clienteId, EstadoCliente nuevo, {String? motivo}) async {
    cambios.add((clienteId, nuevo, motivo));
  }
}

void main() {
  test('acciones disponibles según el estado del cliente', () {
    expect(accionesDisponibles(EstadoCliente.activo),
        [AccionCliente.editar, AccionCliente.suspender, AccionCliente.cancelar]);
    expect(accionesDisponibles(EstadoCliente.suspendido),
        [AccionCliente.editar, AccionCliente.reactivar, AccionCliente.cancelar]);
    expect(accionesDisponibles(EstadoCliente.cancelado),
        [AccionCliente.editar, AccionCliente.reactivar]);
  });

  testWidgets('la tabla de clientes tiene los botones de gestión en cada renglón',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = _RepoFalso();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        clientesProvider.overrideWith((ref, filtro) => Stream.value([
              _cliente(1, 'Ana López', EstadoCliente.activo),
              _cliente(2, 'Beto Ruiz', EstadoCliente.suspendido),
            ])),
        clientesRepositoryProvider.overrideWith((ref) => repo),
      ],
      child: const MaterialApp(home: ClientesScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('ACCIONES'), findsOneWidget);
    expect(find.text('Editar'), findsNWidgets(2));
    expect(find.text('Suspender'), findsOneWidget); // solo Ana (activa)
    expect(find.text('Reactivar'), findsOneWidget); // solo Beto (suspendido)
    expect(find.text('Cancelar servicio'), findsNWidgets(2));

    await tester.tap(find.text('Suspender'));
    await tester.pumpAndSettle();
    expect(find.text('Suspender Ana López'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'No pagó');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(repo.cambios, [(1, EstadoCliente.suspendido, 'No pagó')]);
    expect(find.text('Ana López: suspendido'), findsOneWidget);
  });

  testWidgets('en el celular los botones se ven como íconos debajo de cada cliente',
      (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        clientesProvider.overrideWith((ref, filtro) =>
            Stream.value([_cliente(1, 'Ana López', EstadoCliente.activo)])),
      ],
      child: const MaterialApp(home: ClientesScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Editar'), findsOneWidget);
    expect(find.byTooltip('Suspender'), findsOneWidget);
    expect(find.byTooltip('Cancelar servicio'), findsOneWidget);
  });

  for (final zoom in [0.8, 1.0, 1.5]) {
    testWidgets('con zoom de ${(zoom * 100).round()} % responde el botón de la esquina',
        (tester) async {
      tester.view.physicalSize = const Size(1000, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var tocado = 0;

      await tester.pumpWidget(ProviderScope(
        overrides: [zoomInicialProvider.overrideWithValue(zoom)],
        child: MaterialApp(
          builder: (context, child) => ZoomInterfaz(child: child!),
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomRight,
              child: TextButton(onPressed: () => tocado++, child: const Text('esquina')),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // El botón queda dentro de la ventana y el clic le llega.
      final centro = tester.getCenter(find.text('esquina'));
      expect(centro.dx, lessThan(1000));
      expect(centro.dy, lessThan(700));
      await tester.tap(find.text('esquina'));
      expect(tocado, 1);
    });
  }
}
