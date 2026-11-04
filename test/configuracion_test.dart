import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netmax_manager/core/etiquetas.dart';
import 'package:netmax_manager/core/mes.dart';
import 'package:netmax_manager/data/db/database.dart';
import 'package:netmax_manager/data/repositories/clientes_repository.dart';
import 'package:netmax_manager/data/repositories/planes_repository.dart';
import 'package:netmax_manager/data/repositories/vencimientos_repository.dart';
import 'package:netmax_manager/domain/clientes.dart';
import 'package:netmax_manager/domain/planes.dart';
import 'package:netmax_manager/providers/providers.dart';
import 'package:netmax_manager/providers/sesion.dart';
import 'package:netmax_manager/screens/clientes/cliente_form_screen.dart';
import 'package:netmax_manager/screens/configuracion/configuracion_screen.dart';

const _plan10 = Plan(id: 1, nombre: '10 Mbps', velocidadMbps: 10, precioBase: 25000, activo: true);
const _plan20 =
    Plan(id: 2, nombre: '20 Mbps', velocidadMbps: 20, precioBase: 40000, activo: false);

void main() {
  group('reglas de planes y contratación', () {
    test('validaciones del plan', () {
      expect(validarNombrePlan(''), isNotNull);
      expect(validarNombrePlan('10 Mbps'), isNull);
      expect(validarVelocidad('abc'), isNotNull);
      expect(validarVelocidad('0'), isNotNull);
      expect(validarVelocidad('20'), isNull);
      expect(nombreSugeridoPlan(20), '20 Mbps');
      expect(sePuedeDesactivarPlan(activos: 1), isFalse);
      expect(sePuedeDesactivarPlan(activos: 2), isTrue);
    });

    test('la contratación "otro" muestra su descripción', () {
      expect(textoContratacion(TipoContratacion.otro, 'Equipo a pagos'), 'Equipo a pagos');
      expect(textoContratacion(TipoContratacion.otro, '  '), 'Otro (personalizado)');
      expect(textoContratacion(TipoContratacion.equipoPropio, 'ignorado'),
          'Equipo propio (solo conexión)');
      expect(validarDetalleContratacion(''), isNotNull);
      expect(validarDetalleContratacion('Equipo a pagos'), isNull);
    });

    test('agrupa las contrataciones personalizadas sin importar acentos ni mayúsculas', () {
      final g = agruparDetalles(['Equipo a pagos', 'equipo a pagos ', 'Negocio', null, '']);
      expect(g.first, (detalle: 'Equipo a pagos', clientes: 2));
      expect(g.last, (detalle: 'Negocio', clientes: 1));
    });
  });

  group('PlanesRepository', () {
    late AppDatabase db;
    late PlanesRepository planes;
    late ClientesRepository clientes;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      planes = PlanesRepository(db);
      clientes = ClientesRepository(db, ahora: () => DateTime(2026, 11, 3, 12));
    });
    tearDown(() => db.close());

    DatosCliente cliente(String nombre, int planId,
            {TipoContratacion tipo = TipoContratacion.equipoPropio, String? detalle}) =>
        DatosCliente(
          nombre: nombre,
          planId: planId,
          precioMensual: 25000,
          diaCorte: 5,
          tipoContratacion: tipo,
          tipoContratacionDetalle: detalle,
          fechaAlta: DateTime(2026, 11, 3),
          primerMesCobro: Mes(2026, 11),
        );

    test('crea, edita y cuenta los clientes de cada plan (sin cancelados)', () async {
      final base = (await planes.vigilarTodos().first).single;
      final id20 = await planes.crear(
          const DatosPlan(nombre: '20 Mbps', velocidadMbps: 20, precioBase: 40000));

      final ana = await clientes.crearCliente(cliente('Ana López', base.id));
      await clientes.crearCliente(cliente('Beto Ruiz', base.id));
      final caro = await clientes.crearCliente(cliente('Caro Díaz', base.id));
      await clientes.cambiarEstado(caro, EstadoCliente.cancelado);

      final uso = await planes.vigilarPlanesConUso().first;
      expect(uso.map((u) => (u.plan.nombre, u.clientes)), [('10 Mbps', 2), ('20 Mbps', 0)]);

      // Cambiar el precio del plan no cambia el de los clientes que ya lo tienen.
      await planes.actualizar(
          base.id, const DatosPlan(nombre: '10 Mbps', velocidadMbps: 10, precioBase: 28000));
      expect((await clientes.obtenerCliente(ana))!.precioMensual, 25000);
      expect((await planes.vigilarTodos().first).firstWhere((p) => p.id == base.id).precioBase,
          28000);

      await planes.cambiarActivo(id20, false);
      final todos = await planes.vigilarTodos().first;
      expect(todos.last.activo, isFalse, reason: 'los desactivados van al final');
    });

    test('no deja el catálogo sin planes activos', () async {
      final base = (await planes.vigilarTodos().first).single;
      expect(() => planes.cambiarActivo(base.id, false),
          throwsA(isA<OperacionNoPermitida>()));
    });

    test('guarda la contratación personalizada solo si el tipo es "otro"', () async {
      final base = (await planes.vigilarTodos().first).single;
      final a = await clientes.crearCliente(
          cliente('Ana López', base.id, tipo: TipoContratacion.otro, detalle: ' Equipo a pagos '));
      final b = await clientes.crearCliente(cliente('Beto Ruiz', base.id, detalle: 'no aplica'));
      await clientes.crearCliente(
          cliente('Caro Díaz', base.id, tipo: TipoContratacion.otro, detalle: 'equipo a pagos'));

      expect((await clientes.obtenerCliente(a))!.tipoContratacionDetalle, 'Equipo a pagos');
      expect((await clientes.obtenerCliente(b))!.tipoContratacionDetalle, isNull);
      final usadas = await clientes.vigilarContratacionesPersonalizadas().first;
      expect(usadas.single, (detalle: 'Equipo a pagos', clientes: 2));
    });
  });

  testWidgets('Configuración muestra los planes y los tipos de contratación', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        planesConUsoProvider.overrideWith((ref) => Stream.value([
              (plan: _plan10, clientes: 12),
              (plan: _plan20, clientes: 0),
            ])),
        contratacionesPersonalizadasProvider.overrideWith(
            (ref) => Stream.value(const [(detalle: 'Equipo a pagos', clientes: 2)])),
        usuariosProvider.overrideWith((ref) => Stream.value(<Usuario>[])),
      ],
      child: const MaterialApp(home: ConfiguracionScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Planes de internet'), findsOneWidget);
    expect(find.textContaining('12 clientes'), findsOneWidget);
    expect(find.textContaining('sin clientes · desactivado'), findsOneWidget);
    expect(find.text('Tipos de contratación'), findsOneWidget);
    expect(find.text('Otro (personalizado)'), findsOneWidget);
    expect(find.textContaining('Equipo a pagos'), findsOneWidget);

    // "Nuevo plan" abre el formulario y sugiere el nombre con la velocidad.
    await tester.tap(find.text('Nuevo plan'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Velocidad *'), '30');
    await tester.pump();
    expect(find.widgetWithText(TextFormField, '30 Mbps'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
  });

  testWidgets('el formulario de cliente pide describir la contratación "otro"', (tester) async {
    tester.view.physicalSize = const Size(1200, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        todosLosPlanesProvider.overrideWith((ref) => Stream.value(const [_plan10, _plan20])),
        contratacionesPersonalizadasProvider.overrideWith(
            (ref) => Stream.value(const [(detalle: 'Equipo a pagos', clientes: 2)])),
      ],
      child: const MaterialApp(home: ClienteFormScreen()),
    ));
    await tester.pumpAndSettle();

    // El plan desactivado no se ofrece a clientes nuevos; sí "Crear plan nuevo…".
    await tester.tap(find.text(r'10 Mbps · $250.00'));
    await tester.pumpAndSettle();
    expect(find.textContaining('20 Mbps'), findsNothing);
    expect(find.text('Crear plan nuevo…'), findsWidgets);
    await tester.tap(find.text(r'10 Mbps · $250.00').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('¿En qué consiste'), findsNothing);
    await tester.tap(find.text('Equipo propio (solo conexión)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Otro (personalizado)').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('¿En qué consiste'), findsOneWidget);

    // Sin descripción no se puede guardar.
    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre completo *'), 'Ana López');
    await tester.tap(find.text('Registrar cliente'));
    await tester.pumpAndSettle();
    expect(find.text('Describe el tipo de contratación'), findsOneWidget);
  });

  testWidgets('un administrador no puede cambiar la configuración', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        sesionInicialProvider.overrideWithValue(Usuario(
          id: 2,
          nombre: 'Luis',
          usuario: 'luis',
          pinHash: '',
          rol: RolUsuario.admin,
          activo: true,
          creadoEn: DateTime(2026, 11, 4),
        )),
      ],
      child: const MaterialApp(home: ConfiguracionScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Solo el propietario puede cambiar la configuración.'), findsOneWidget);
    expect(find.text('Nuevo plan'), findsNothing);
  });
}
