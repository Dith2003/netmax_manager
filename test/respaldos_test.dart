import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netmax_manager/core/mes.dart';
import 'package:netmax_manager/data/db/database.dart';
import 'package:netmax_manager/data/repositories/clientes_repository.dart';
import 'package:netmax_manager/data/repositories/pagos_repository.dart';
import 'package:netmax_manager/data/respaldos/respaldo_service.dart';
import 'package:netmax_manager/providers/providers.dart';
import 'package:netmax_manager/screens/respaldos/respaldos_screen.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  late Directory carpeta;
  String ruta(String nombre) => '${carpeta.path}${Platform.pathSeparator}$nombre';

  setUp(() => carpeta = Directory.systemTemp.createTempSync('netmax_respaldos_'));
  tearDown(() {
    if (carpeta.existsSync()) carpeta.deleteSync(recursive: true);
  });

  /// Base de datos en archivo con un cliente y un pago.
  Future<AppDatabase> baseConDatos(String archivo) async {
    final db = AppDatabase(NativeDatabase(File(archivo)));
    final hoy = DateTime(2026, 11, 3, 12);
    final clientes = ClientesRepository(db, ahora: () => hoy);
    final planId = (await clientes.vigilarPlanes().first).first.id;
    final id = await clientes.crearCliente(DatosCliente(
      nombre: 'Ana López',
      planId: planId,
      precioMensual: 25000,
      diaCorte: 5,
      tipoContratacion: TipoContratacion.equipoPropio,
      fechaAlta: DateTime(2026, 10, 1),
      primerMesCobro: Mes(2026, 10),
    ));
    await PagosRepository(db, ahora: () => hoy)
        .registrarPago(id, DatosPago(monto: 50000, fecha: DateTime(2026, 11, 2)));
    return db;
  }

  test('nombre sugerido con fecha y hora', () {
    expect(RespaldoService.nombreSugerido(DateTime(2026, 11, 3, 8, 5)),
        'netmax_respaldo_2026-11-03_0805.db');
  });

  test('recordatorio: nunca o más de 7 días', () {
    final hoy = DateTime(2026, 11, 10, 9);
    expect(necesitaRespaldo(null, hoy), isTrue);
    expect(necesitaRespaldo(DateTime(2026, 11, 3, 23), hoy), isFalse); // 7 días
    expect(necesitaRespaldo(DateTime(2026, 11, 2), hoy), isTrue); // 8 días
    expect(diasDesdeRespaldo(DateTime(2026, 11, 10, 1), hoy), 0);
  });

  test('crear respaldo, validarlo y registrar la fecha', () async {
    final db = await baseConDatos(ruta('app.sqlite'));
    final servicio = RespaldoService(db);
    expect(await servicio.vigilarUltimoRespaldo().first, isNull);

    await servicio.crearRespaldo(ruta('respaldo.db'));
    expect(await servicio.vigilarUltimoRespaldo().first, isNotNull);

    final info = RespaldoService.validar(ruta('respaldo.db'), versionApp: db.schemaVersion);
    expect(info.version, db.schemaVersion);
    expect(info.clientes, 1);
    expect(info.pagos, 1);
    expect(info.ultimoPago, DateTime(2026, 11, 2));

    // Crear otra vez en la misma ruta la reemplaza.
    await servicio.crearRespaldo(ruta('respaldo.db'));
    expect(File(ruta('respaldo.db')).existsSync(), isTrue);
    await db.close();
  });

  test('rechaza archivos que no son respaldos de NetMAX', () {
    File(ruta('texto.db')).writeAsStringSync('hola, esto no es una base de datos' * 100);
    expect(() => RespaldoService.validar(ruta('texto.db'), versionApp: 3),
        throwsA(isA<RespaldoNoValido>()));

    final otra = sqlite.sqlite3.open(ruta('otra.db'));
    otra.execute('CREATE TABLE cosas (id INTEGER)');
    otra.execute('PRAGMA user_version = 1');
    otra.close();
    expect(() => RespaldoService.validar(ruta('otra.db'), versionApp: 3),
        throwsA(isA<RespaldoNoValido>()));

    expect(() => RespaldoService.validar(ruta('no_existe.db'), versionApp: 3),
        throwsA(isA<RespaldoNoValido>()));
  });

  test('rechaza respaldos de una versión más nueva de la app', () async {
    final db = await baseConDatos(ruta('app.sqlite'));
    await RespaldoService(db).crearRespaldo(ruta('respaldo.db'));
    await db.close();

    final bd = sqlite.sqlite3.open(ruta('respaldo.db'));
    bd.execute('PRAGMA user_version = 99');
    bd.close();
    expect(
      () => RespaldoService.validar(ruta('respaldo.db'), versionApp: 3),
      throwsA(isA<RespaldoNoValido>().having((e) => e.mensaje, 'mensaje', contains('más nueva'))),
    );
  });

  test('restaurar: reemplaza el archivo y se recuperan los datos', () async {
    // Respaldo con datos.
    final origen = await baseConDatos(ruta('origen.sqlite'));
    await RespaldoService(origen).crearRespaldo(ruta('respaldo.db'));
    await origen.close();

    // App "nueva" sin clientes, con archivos auxiliares de SQLite sobrantes.
    final destino = ruta('app.sqlite');
    final vacia = AppDatabase(NativeDatabase(File(destino)));
    expect(await vacia.select(vacia.clientes).get(), isEmpty);
    await vacia.close();
    File('$destino-wal').writeAsStringSync('basura');

    await RespaldoService.reemplazarArchivo(respaldo: ruta('respaldo.db'), destino: destino);
    expect(File('$destino-wal').existsSync(), isFalse);

    final restaurada = AppDatabase(NativeDatabase(File(destino)));
    final clientes = await restaurada.select(restaurada.clientes).get();
    expect(clientes.single.nombre, 'Ana López');
    expect((await restaurada.select(restaurada.pagos).get()).single.monto, 50000);
    await restaurada.close();
  });

  testWidgets('la pantalla avisa si nunca se ha hecho un respaldo', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [ultimoRespaldoProvider.overrideWith((ref) => Stream.value(null))],
      child: const MaterialApp(home: RespaldosScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Nunca has hecho un respaldo'), findsOneWidget);
    expect(find.text('Crear respaldo'), findsOneWidget);
    expect(find.text('Restaurar desde un respaldo'), findsOneWidget);
  });
}
