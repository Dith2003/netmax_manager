import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netmax_manager/core/mes.dart';
import 'package:netmax_manager/data/db/database.dart';
import 'package:netmax_manager/data/repositories/clientes_repository.dart';
import 'package:netmax_manager/data/repositories/pagos_repository.dart';
import 'package:netmax_manager/data/repositories/reportes_repository.dart';
import 'package:netmax_manager/data/repositories/vencimientos_repository.dart';
import 'package:netmax_manager/domain/reportes.dart';
import 'package:netmax_manager/providers/providers.dart';
import 'package:netmax_manager/reportes/pdf_reportes.dart';
import 'package:netmax_manager/screens/clientes/modales.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('comprobante de pago', () {
    late AppDatabase db;
    final hoy = DateTime(2026, 11, 3, 12);
    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('datos: conceptos, pagado hasta y saldo pendiente', () async {
      final clientes = ClientesRepository(db, ahora: () => hoy);
      final pagos = PagosRepository(db, ahora: () => hoy);
      final planId = (await clientes.vigilarPlanes().first).first.id;
      final id = await clientes.crearCliente(DatosCliente(
        nombre: 'Ana López',
        zona: 'Centro',
        planId: planId,
        precioMensual: 25000,
        diaCorte: 5,
        tipoContratacion: TipoContratacion.equipoPropio,
        fechaAlta: DateTime(2026, 9, 1),
        primerMesCobro: Mes(2026, 9),
      ));
      await VencimientosRepository(db).agregarCargo(
          clienteId: id, concepto: 'Reconexión', monto: 10000, fecha: DateTime(2026, 9, 10));
      // sep (5-sep) -> reconexión (10-sep); oct y nov quedan pendientes.
      final pagoId = await pagos.registrarPago(
          id, DatosPago(monto: 35000, fecha: hoy, metodo: MetodoPago.efectivo, folio: 'A-1'));

      final datos = (await ReportesRepository(db).comprobante(pagoId, hoy))!;
      expect(datos.numero, pagoId.toString().padLeft(6, '0'));
      expect(datos.cliente, 'Ana López');
      expect(datos.folio, 'A-1');
      expect(datos.conceptos.map((c) => c.concepto),
          ['Mensualidad septiembre 2026', 'Reconexión']);
      expect(datos.pagadoHasta, Mes(2026, 9));
      expect(datos.saldoPendiente, 25000); // octubre vencido; noviembre vence el 5

      final bytes = await pdfComprobante(
          estilo: await cargarEstiloPdf(), datos: datos, generado: hoy);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');

      expect(await ReportesRepository(db).comprobante(9999, hoy), isNull);
    });

    test('comprobante de un pago cancelado también se genera', () async {
      final datos = DatosComprobante(
        pagoId: 7,
        fecha: hoy,
        monto: 25000,
        metodo: MetodoPago.efectivo,
        cancelado: true,
        cliente: 'Beto',
        conceptos: const [(concepto: 'Mensualidad noviembre 2026', monto: 25000)],
        saldoPendiente: 25000,
      );
      final bytes = await pdfComprobante(
          estilo: await cargarEstiloPdf(), datos: datos, generado: hoy);
      expect(bytes.length, greaterThan(1000));
    });
  });

  testWidgets('el alta de cliente se abre en un modal y se cierra con la X', (tester) async {
    tester.view.physicalSize = const Size(1366, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        planesProvider.overrideWith((ref) => Stream.value(const [
              Plan(id: 1, nombre: '10 Mbps', velocidadMbps: 10, precioBase: 25000, activo: true),
            ])),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => abrirFormularioCliente(context),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Nuevo cliente'), findsOneWidget);

    await tester.tap(find.byTooltip('Cerrar sin guardar'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
  });
}
