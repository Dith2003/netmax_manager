/// Capturas de pantalla con la tipografía y los colores reales, para revisar
/// el diseño sin abrir la app. Solo se ejecuta con CAPTURAS=1:
///
///   CAPTURAS=1 flutter test test/capturas_test.dart --update-goldens
///
/// Las imágenes quedan en test/capturas/ y los PDF de ejemplo en build/capturas/.
/// (Esa carpeta está en .gitignore: no son pruebas de comparación.)
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:netmax_manager/core/marca.dart';
import 'package:netmax_manager/core/mes.dart';
import 'package:netmax_manager/data/db/database.dart';
import 'package:netmax_manager/data/repositories/pagos_repository.dart';
import 'package:netmax_manager/data/repositories/reportes_repository.dart';
import 'package:netmax_manager/data/repositories/vencimientos_repository.dart';
import 'package:netmax_manager/domain/cobranza.dart';
import 'package:netmax_manager/domain/dashboard.dart';
import 'package:netmax_manager/domain/reportes.dart';
import 'package:netmax_manager/main.dart';
import 'package:netmax_manager/providers/providers.dart';
import 'package:netmax_manager/reportes/pdf_reportes.dart';

final _activo = Platform.environment['CAPTURAS'] == '1';
final _hoy = DateTime.now();
final _mes = Mes.deFecha(_hoy);

Future<void> _cargarFuentes() async {
  final outfit = FontLoader('Outfit');
  for (final peso in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    outfit.addFont(rootBundle.load('assets/fonts/Outfit-$peso.ttf'));
  }
  await outfit.load();

  // Íconos de Material desde el SDK de Flutter.
  final raiz = Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.path;
  final archivo = File('$raiz/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (archivo.existsSync()) {
    final iconos = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.sublistView(archivo.readAsBytesSync())));
    await iconos.load();
  }
}

// ---------------------------------------------------------------------------
// Datos de ejemplo
// ---------------------------------------------------------------------------

Cliente _cliente(int id, String nombre, String zona, String tel,
        {EstadoCliente estado = EstadoCliente.activo,
        int precio = 25000,
        TipoContratacion tipo = TipoContratacion.equipoPropio}) =>
    Cliente(
      id: id,
      nombre: nombre,
      telefono: tel,
      direccion: 'Calle Hidalgo $id',
      zona: zona,
      referencia: 'Frente a la tienda',
      planId: 1,
      precioMensual: precio,
      diaCorte: 5,
      tipoContratacion: tipo,
      fechaAlta: DateTime(2025, 3, 15),
      primerMesCobro: '2025-04',
      estado: estado,
      creadoEn: DateTime(2025, 3, 15),
    );

final _clientes = [
  _cliente(1, 'Ana López Martínez', 'Centro', '7711234567',
      tipo: TipoContratacion.equipoPrestado),
  _cliente(2, 'Beto Ruiz Hernández', 'El Ranchito', '7719876543', precio: 30000),
  _cliente(3, 'Carmen Ortiz', 'La Loma', '7715551234'),
  _cliente(4, 'Daniel Pérez', 'Centro', '7714443322', estado: EstadoCliente.suspendido),
  _cliente(5, 'Elena Gómez', 'Santa Cruz', '7713332211'),
  _cliente(6, 'Fernando Trejo', 'El Ranchito', '7712221100', precio: 30000),
];

PeriodoSaldo _periodo(int id, Mes m, {int pagado = 0, bool cortesia = false}) => PeriodoSaldo(
      id: id,
      mes: m,
      vencimiento: m.fechaVencimiento(5),
      monto: 25000,
      pagado: pagado,
      esCortesia: cortesia,
    );

List<PeriodoSaldo> _periodosAna() {
  var m = _mes;
  for (var i = 0; i < 5; i++) {
    m = m.anterior();
  }
  final lista = <PeriodoSaldo>[];
  for (var i = 0; i < 6; i++, m = m.siguiente()) {
    lista.add(_periodo(i + 1, m,
        pagado: i < 3 ? 25000 : (i == 3 ? 10000 : 0), cortesia: i == 0));
  }
  return lista;
}

final _resumen = ResumenDashboard(
  mes: _mes,
  cobradoMes: 487500,
  pagosMes: 17,
  esperadoMes: 1150000,
  cubiertoMes: 787500,
  porCobrar: 215000,
  clientesConAdeudo: 6,
  clientesPorEstado: const {
    EstadoCliente.activo: 44,
    EstadoCliente.suspendido: 3,
    EstadoCliente.cancelado: 2,
  },
  proximosVencimientos: [
    for (final (i, c) in _clientes.take(3).indexed)
      (
        clienteId: c.id,
        cliente: c.nombre,
        estado: EstadoCliente.activo,
        mes: _mes,
        vencimiento: _hoy.add(Duration(days: i + 1)),
        monto: c.precioMensual,
        pagado: i == 1 ? 10000 : 0,
        esCortesia: false,
      ),
  ],
  pagosRecientes: [
    for (final (i, c) in _clientes.skip(2).take(4).indexed)
      (clienteId: c.id, cliente: c.nombre, fecha: _hoy.subtract(Duration(days: i)), monto: 25000 * (i + 1)),
  ],
  cobranza: [
    for (final (i, m) in ultimosMeses(_mes, 12).indexed)
      (
        mes: m,
        total: i == 11 ? 487500 : 820000 + (i * 37) % 9 * 25000 + i * 15000,
        pagos: i == 11 ? 17 : 31 + i % 5,
      ),
  ],
  actividad: [
    for (final (i, m) in ultimosMeses(_mes, 12).indexed)
      ActividadMes(
        mes: m,
        altas: [3, 2, 4, 1, 5, 2, 3, 6, 2, 4, 3, 2][i],
        suspensiones: [1, 0, 2, 1, 0, 1, 2, 0, 1, 3, 1, 1][i],
        cancelaciones: [0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0][i],
      ),
  ],
);

final _adeudos = [
  AdeudoCliente(
    clienteId: 4,
    nombre: 'Daniel Pérez',
    zona: 'Centro',
    telefono: '7714443322',
    estado: EstadoCliente.suspendido,
    adeudo: EstadoAdeudo(total: 155000, meses: 3, cargos: 1, vencidoDesde: DateTime(2026, 8, 5)),
  ),
  AdeudoCliente(
    clienteId: 1,
    nombre: 'Ana López Martínez',
    zona: 'Centro',
    estado: EstadoCliente.activo,
    adeudo: EstadoAdeudo(total: 40000, meses: 2, vencidoDesde: DateTime(2026, 9, 5)),
  ),
  AdeudoCliente(
    clienteId: 3,
    nombre: 'Carmen Ortiz',
    zona: 'La Loma',
    estado: EstadoCliente.activo,
    adeudo: EstadoAdeudo(total: 25000, meses: 1, vencidoDesde: DateTime(2026, 10, 5)),
  ),
];

List<Override> _datosSimulados() => [
      // Base vacía: las pantallas leen los repositorios pero los datos vienen simulados.
      databaseProvider.overrideWithValue(AppDatabase(NativeDatabase.memory())),
      resumenProvider.overrideWith((ref) => Stream.value(_resumen)),
      ultimoRespaldoProvider.overrideWith((ref) => Stream.value(null)),
      clientesProvider.overrideWith((ref, filtro) => Stream.value(_clientes
          .where((c) => filtro.estado == null || c.estado == filtro.estado)
          .toList())),
      clienteProvider.overrideWith(
          (ref, id) => Stream.value(_clientes.firstWhere((c) => c.id == id))),
      planesProvider.overrideWith((ref) => Stream.value(const [
            Plan(id: 1, nombre: '10 Mbps', velocidadMbps: 10, precioBase: 25000, activo: true),
          ])),
      periodosProvider.overrideWith((ref, id) => Stream.value(_periodosAna())),
      cargosProvider.overrideWith((ref, id) => Stream.value([
            CargoSaldo(
                id: 1, concepto: 'Reconexión', fecha: DateTime(2026, 10, 20), monto: 10000),
          ])),
      pagosProvider.overrideWith((ref, id) => Stream.value([
            PagoConDetalle(
              pago: Pago(
                id: 2,
                clienteId: id,
                fechaPago: _hoy.subtract(const Duration(days: 20)),
                monto: 35000,
                metodo: MetodoPago.transferencia,
                folio: 'A-102',
                cancelado: false,
                creadoEn: _hoy,
              ),
              meses: [(mes: _mes.anterior(), monto: 25000)],
              cargos: const [(concepto: 'Reconexión', monto: 10000)],
            ),
            PagoConDetalle(
              pago: Pago(
                id: 1,
                clienteId: id,
                fechaPago: _hoy.subtract(const Duration(days: 60)),
                monto: 50000,
                metodo: MetodoPago.efectivo,
                cancelado: false,
                creadoEn: _hoy,
              ),
              meses: [
                (mes: _mes.anterior().anterior().anterior(), monto: 25000),
                (mes: _mes.anterior().anterior(), monto: 25000),
              ],
            ),
          ])),
      instalacionesProvider.overrideWith((ref, id) => Stream.value([
            Instalacion(
                id: 1,
                clienteId: id,
                fecha: DateTime(2025, 3, 15),
                costo: 150000,
                pagado: true,
                tecnico: 'Evelio'),
          ])),
      equiposProvider.overrideWith((ref, id) => Stream.value([
            Equipo(
                id: 1,
                clienteId: id,
                tipo: 'Antena',
                marcaModelo: 'Ubiquiti LiteBeam',
                propiedad: PropiedadEquipo.netmax,
                fechaEntrega: DateTime(2025, 3, 15)),
          ])),
      historialProvider.overrideWith((ref, id) => Stream.value([
            HistorialEstado(
                id: 1,
                clienteId: id,
                estadoNuevo: EstadoCliente.activo,
                motivo: 'Alta de cliente',
                fecha: DateTime(2025, 3, 15)),
          ])),
      adeudosProvider.overrideWith((ref) => Stream.value(_adeudos)),
      reportesRepositoryProvider.overrideWith((ref) => _ReportesSimulados()),
      vencimientosRepositoryProvider.overrideWith((ref) => throw UnimplementedError()),
    ];

// ---------------------------------------------------------------------------
// Capturas
// ---------------------------------------------------------------------------

Future<void> _capturar(
  WidgetTester tester,
  String nombre,
  String ruta, {
  Size tamano = const Size(412, 915),
  Finder? tocar,
}) async {
  // En las pruebas las sombras se dibujan como un borde negro; aquí se quieren reales.
  debugDisableShadows = false;
  tester.view.physicalSize = tamano * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(ProviderScope(
    overrides: _datosSimulados(),
    child: const NetMaxApp(),
  ));
  await tester.pumpAndSettle();
  if (ruta != '/inicio') {
    final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
    // Las secciones principales se abren como pestaña; el resto, encima.
    const secciones = ['/clientes', '/adeudos', '/reportes'];
    if (secciones.contains(ruta)) {
      router.go(ruta);
    } else {
      router.push(ruta);
    }
    await tester.pumpAndSettle();
  }
  if (tocar != null) {
    await tester.tap(tocar.first);
    await tester.pumpAndSettle();
  }
  // Las imágenes del logo se decodifican fuera del reloj simulado.
  await tester.runAsync(() async {
    final contexto = tester.element(find.byType(Scaffold).first);
    for (final img in [ImagenesMarca.logo, ImagenesMarca.logoClaro]) {
      await precacheImage(AssetImage(img), contexto);
    }
  });
  await tester.pumpAndSettle();
  await expectLater(find.byType(NetMaxApp), matchesGoldenFile('capturas/$nombre.png'));
  debugDisableShadows = true; // se restablece antes de que termine la prueba
}

void main() {
  setUpAll(() async {
    if (_activo) await _cargarFuentes();
  });

  final pantallas = {
    '01_inicio': '/inicio',
    '02_clientes': '/clientes',
    '03_ficha_cliente': '/clientes/1',
    '04_estado_cuenta': '/clientes/1/estado-cuenta',
    '05_registrar_pago': '/clientes/1/pago',
    '06_nuevo_cliente': '/clientes/nuevo',
    '07_adeudos': '/adeudos',
    '08_reportes': '/reportes',
    '09_respaldos': '/respaldos',
  };
  for (final MapEntry(key: nombre, value: ruta) in pantallas.entries) {
    testWidgets('captura $nombre', (tester) => _capturar(tester, nombre, ruta),
        skip: !_activo);
  }
  const escritorio = Size(1366, 900);
  testWidgets('captura 10_inicio_escritorio',
      (tester) => _capturar(tester, '10_inicio_escritorio', '/inicio', tamano: const Size(1366, 1500)),
      skip: !_activo);
  testWidgets('captura 13_ficha_modal_escritorio',
      (tester) => _capturar(tester, '13_ficha_modal_escritorio', '/clientes',
          tamano: escritorio, tocar: find.text('Ana López Martínez')),
      skip: !_activo);
  testWidgets('captura 14_nuevo_cliente_modal_escritorio',
      (tester) => _capturar(tester, '14_nuevo_cliente_modal_escritorio', '/clientes',
          tamano: escritorio, tocar: find.text('Nuevo cliente')),
      skip: !_activo);
  testWidgets('captura 15_ficha_modal_celular',
      (tester) => _capturar(tester, '15_ficha_modal_celular', '/clientes',
          tocar: find.text('Beto Ruiz Hernández')),
      skip: !_activo);
  testWidgets('captura 16_elegir_cliente_pago',
      (tester) => _capturar(tester, '16_elegir_cliente_pago', '/inicio',
          tamano: escritorio, tocar: find.text('Registrar pago')),
      skip: !_activo);
  testWidgets('captura 17_comprobantes',
      (tester) => _capturar(tester, '17_comprobantes', '/reportes/comprobantes'),
      skip: !_activo);

  test('PDF de ejemplo', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final estilo = await cargarEstiloPdf();
    final carpeta = Directory('build/capturas')..createSync(recursive: true);
    final pagos = [
      for (final (i, c) in _clientes.indexed)
        FilaPago(
          fecha: _hoy.subtract(Duration(days: i * 3)),
          cliente: c.nombre,
          monto: c.precioMensual,
          metodo: MetodoPago.values[i % 3],
          folio: i.isEven ? 'A-${100 + i}' : null,
          cubre: _mes.nombreCorto,
        ),
    ];
    File('${carpeta.path}/11_pdf_pagos.pdf').writeAsBytesSync(await pdfPagos(
        estilo: estilo, pagos: pagos, periodo: _mes.nombre, generado: _hoy));
    File('${carpeta.path}/12_pdf_adeudos.pdf')
        .writeAsBytesSync(await pdfAdeudos(estilo: estilo, adeudos: _adeudos, generado: _hoy));
    final comprobante = DatosComprobante(
      pagoId: 128,
      folio: 'TRF-55821',
      fecha: _hoy,
      monto: 60000,
      metodo: MetodoPago.transferencia,
      cancelado: false,
      cliente: 'Ana López Martínez',
      telefono: '7711234567',
      direccion: 'Calle Hidalgo 1',
      zona: 'Centro',
      conceptos: [
        (concepto: 'Mensualidad ${_mes.anterior().nombre}', monto: 25000),
        (concepto: 'Reconexión', monto: 10000),
        (concepto: 'Mensualidad ${_mes.nombre}', monto: 25000),
      ],
      pagadoHasta: _mes,
      saldoPendiente: 0,
    );
    File('${carpeta.path}/13_pdf_comprobante.pdf').writeAsBytesSync(
        await pdfComprobante(estilo: estilo, datos: comprobante, generado: _hoy));
  }, skip: !_activo);
}

/// Pagos de ejemplo para la lista de comprobantes.
class _ReportesSimulados extends ReportesRepository {
  _ReportesSimulados() : super(AppDatabase(NativeDatabase.memory()));

  @override
  Future<List<FilaPago>> pagosEntre(DateTime desde, DateTime hasta) async => [
        for (final (i, c) in _clientes.indexed)
          FilaPago(
            id: 100 + i,
            fecha: _hoy.subtract(Duration(days: 6 - i)),
            cliente: c.nombre,
            monto: c.precioMensual,
            metodo: MetodoPago.values[i % 3],
            cubre: _mes.nombreCorto,
          ),
      ];
}
