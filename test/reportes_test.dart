import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netmax_manager/core/mes.dart';
import 'package:netmax_manager/data/db/database.dart';
import 'package:netmax_manager/data/repositories/clientes_repository.dart';
import 'package:netmax_manager/data/repositories/pagos_repository.dart';
import 'package:netmax_manager/data/repositories/reportes_repository.dart';
import 'package:netmax_manager/data/repositories/vencimientos_repository.dart';
import 'package:netmax_manager/domain/cobranza.dart';
import 'package:netmax_manager/domain/reportes.dart';
import 'package:netmax_manager/reportes/pdf_reportes.dart';
import 'package:netmax_manager/screens/reportes/reportes_screen.dart';

FilaPago pago(DateTime fecha, int monto, MetodoPago metodo) =>
    FilaPago(fecha: fecha, cliente: 'Ana', monto: monto, metodo: metodo);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ingresos por mes', () {
    test('agrupa por mes y método, con renglón para meses sin pagos', () {
      final meses = ingresosPorMes([
        pago(DateTime(2026, 9, 3), 25000, MetodoPago.efectivo),
        pago(DateTime(2026, 9, 30, 20), 30000, MetodoPago.transferencia),
        pago(DateTime(2026, 11, 1), 25000, MetodoPago.efectivo),
        pago(DateTime(2026, 12, 1), 99999, MetodoPago.efectivo), // fuera del rango
      ], Mes(2026, 9), Mes(2026, 11));

      expect(meses.map((m) => m.mes.toString()), ['2026-09', '2026-10', '2026-11']);
      expect(meses[0].total, 55000);
      expect(meses[0].pagos, 2);
      expect(meses[0].porMetodo[MetodoPago.transferencia], 30000);
      expect(meses[1].total, 0);

      final total = totalIngresos(meses);
      expect(total.total, 80000);
      expect(total.pagos, 3);
      expect(total.porMetodo[MetodoPago.efectivo], 50000);
    });
  });

  group('repositorio de reportes', () {
    late AppDatabase db;
    late ReportesRepository reportes;
    late ClientesRepository clientes;
    late PagosRepository pagos;
    final hoy = DateTime(2026, 11, 3, 12);

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      reportes = ReportesRepository(db);
      clientes = ClientesRepository(db, ahora: () => hoy);
      pagos = PagosRepository(db, ahora: () => hoy);
    });
    tearDown(() => db.close());

    Future<int> cliente(String nombre, {Mes? primerMes}) async {
      final planId = (await clientes.vigilarPlanes().first).first.id;
      return clientes.crearCliente(DatosCliente(
        nombre: nombre,
        zona: 'Centro',
        planId: planId,
        precioMensual: 25000,
        diaCorte: 5,
        tipoContratacion: TipoContratacion.equipoPropio,
        fechaAlta: DateTime(2026, 9, 1),
        primerMesCobro: primerMes ?? Mes(2026, 9),
      ));
    }

    test('pagos de un periodo con lo que cubrió cada uno, sin cancelados', () async {
      final ana = await cliente('Ana');
      await VencimientosRepository(db).agregarCargo(
          clienteId: ana, concepto: 'Reconexión', monto: 10000, fecha: DateTime(2026, 9, 10));
      // sep (5-sep) -> reconexión (10-sep) -> oct
      await pagos.registrarPago(ana,
          DatosPago(monto: 60000, fecha: DateTime(2026, 10, 2), metodo: MetodoPago.transferencia));
      final cancelado = await pagos.registrarPago(ana,
          DatosPago(monto: 25000, fecha: DateTime(2026, 10, 3)));
      await pagos.cancelarPago(cancelado);
      await pagos.registrarPago(ana, DatosPago(monto: 25000, fecha: DateTime(2026, 11, 1)));

      final octubre = await reportes.pagosEntre(DateTime(2026, 10, 1), DateTime(2026, 10, 31));
      expect(octubre.single.monto, 60000);
      expect(octubre.single.metodo, MetodoPago.transferencia);
      expect(octubre.single.cubre, 'sep 2026 – oct 2026, Reconexión');

      final ingresos = await reportes.ingresos(Mes(2026, 9), Mes(2026, 11));
      expect(ingresos.map((m) => m.total), [0, 60000, 25000]);
    });

    test('lista de clientes con pagado hasta y adeudo, ordenada sin acentos', () async {
      final beto = await cliente('Beto');
      await cliente('Ángel');
      await pagos.registrarPago(beto, DatosPago(monto: 50000, fecha: hoy));

      final lista = await reportes.clientes(hoy);
      expect(lista.map((c) => c.nombre), ['Ángel', 'Beto']);
      // Ángel: sep, oct vencidos (nov vence el 5).
      expect(lista[0].adeudo, 50000);
      expect(lista[0].pagadoHasta, isNull);
      // Beto pagó sep y oct.
      expect(lista[1].pagadoHasta, Mes(2026, 10));
      expect(lista[1].adeudo, 0);

      final adeudos = await reportes.adeudos(hoy);
      expect(adeudos.single.nombre, 'Ángel');
    });
  });

  group('PDF', () {
    late Future<EstiloPdf> estilo;
    setUpAll(() => estilo = cargarEstiloPdf());

    bool esPdf(List<int> bytes) =>
        bytes.length > 1000 && String.fromCharCodes(bytes.take(5)) == '%PDF-';

    test('se generan los cuatro reportes, también vacíos', () async {
      final t = await estilo;
      final generado = DateTime(2026, 11, 3);
      final meses = ingresosPorMes(
          [pago(DateTime(2026, 10, 2), 25000, MetodoPago.efectivo)], Mes(2026, 1), Mes(2026, 11));

      expect(esPdf(await pdfIngresos(
          estilo: t, meses: meses, periodo: 'Enero a noviembre 2026', generado: generado)), isTrue);
      expect(esPdf(await pdfPagos(estilo: t, pagos: [], periodo: 'Noviembre 2026', generado: generado)),
          isTrue);
      expect(
        esPdf(await pdfPagos(
          estilo: t,
          pagos: [
            for (var i = 0; i < 80; i++) // varias páginas
              FilaPago(
                fecha: DateTime(2026, 10, 1 + i % 28),
                cliente: 'Cliente con acentos áéíóú ñ $i',
                monto: 25000,
                metodo: MetodoPago.efectivo,
                cubre: 'oct 2026',
              ),
          ],
          periodo: 'Octubre 2026',
          generado: generado,
        )),
        isTrue,
      );
      expect(
        esPdf(await pdfAdeudos(
          estilo: t,
          adeudos: [
            AdeudoCliente(
              clienteId: 1,
              nombre: 'Ana',
              estado: EstadoCliente.activo,
              adeudo: EstadoAdeudo(total: 25000, meses: 1, vencidoDesde: DateTime(2026, 10, 5)),
            ),
          ],
          generado: generado,
        )),
        isTrue,
      );
      expect(
        esPdf(await pdfClientes(
          estilo: t,
          clientes: [
            FilaCliente(
              nombre: 'Ana',
              precioMensual: 25000,
              diaCorte: 5,
              estado: EstadoCliente.activo,
              pagadoHasta: Mes(2026, 10),
              adeudo: 0,
            ),
          ],
          generado: generado,
        )),
        isTrue,
      );
    });
  });

  testWidgets('la pantalla de reportes lista los cuatro reportes', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ReportesScreen()));
    for (final t in TipoReporte.values) {
      expect(find.text(t.titulo), findsOneWidget);
    }
    expect(find.text('Comprobantes de pago'), findsOneWidget);
  });
}
