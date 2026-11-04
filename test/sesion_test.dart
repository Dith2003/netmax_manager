import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netmax_manager/data/db/database.dart';
import 'package:netmax_manager/data/repositories/usuarios_repository.dart';
import 'package:netmax_manager/data/repositories/vencimientos_repository.dart';
import 'package:netmax_manager/domain/usuarios.dart';
import 'package:netmax_manager/providers/sesion.dart';
import 'package:netmax_manager/screens/sesion/acceso_screen.dart';

Usuario _usuario(int id, String nombre, RolUsuario rol) => Usuario(
      id: id,
      nombre: nombre,
      usuario: nombre.toLowerCase(),
      pinHash: '',
      rol: rol,
      activo: true,
      creadoEn: DateTime(2026, 11, 4),
    );

/// Repositorio simulado: el PIN correcto es 2580.
class _RepoFalso extends Fake implements UsuariosRepository {
  _RepoFalso(this.usuarios);

  final List<Usuario> usuarios;

  @override
  Future<Usuario?> autenticar(String usuario, String pin) async =>
      pin == '2580' ? usuarios.firstWhere((u) => u.usuario == usuario) : null;
}

void main() {
  group('PIN y permisos', () {
    test('el PIN se guarda protegido y se verifica', () {
      final guardado = protegerPin('2580', sal: 'sal-fija');
      expect(guardado, startsWith(r'v1$sal-fija$'));
      expect(guardado, isNot(contains('2580')));
      expect(verificarPin('2580', guardado), isTrue);
      expect(verificarPin('2581', guardado), isFalse);
      expect(verificarPin('2580', 'otra cosa'), isFalse);
      // Con sal aleatoria, el mismo PIN se guarda distinto.
      expect(protegerPin('2580'), isNot(protegerPin('2580')));
    });

    test('validaciones de PIN y usuario', () {
      expect(validarPin('123'), isNotNull);
      expect(validarPin('1234567'), isNotNull);
      expect(validarPin('12a4'), isNotNull);
      expect(validarPin('1111'), isNotNull);
      expect(validarPin('2580'), isNull);
      expect(validarNombreUsuario('Edith'), isNull); // se guarda como "edith"
      expect(validarNombreUsuario('ed'), isNotNull);
      expect(validarNombreUsuario('josé'), isNotNull);
      expect(normalizarUsuario('  Edith '), 'edith');
    });

    test('tras 5 PIN incorrectos se espera 30 segundos', () {
      final ahora = DateTime(2026, 11, 4, 10);
      expect(bloqueadoHasta(fallidos: 4, ultimoFallo: ahora), isNull);
      expect(bloqueadoHasta(fallidos: 5, ultimoFallo: ahora), ahora.add(espera));
    });

    test('el administrador tiene permisos limitados', () {
      final admin = permisosDe(RolUsuario.admin);
      expect(admin.configurar, isFalse);
      expect(admin.restaurarRespaldos, isFalse);
      expect(admin.cancelarPagos, isFalse);
      expect(admin.administrarUsuarios, isFalse);
      final propietario = permisosDe(RolUsuario.propietario);
      expect(propietario.configurar && propietario.cancelarPagos, isTrue);
    });
  });

  group('UsuariosRepository', () {
    late AppDatabase db;
    late UsuariosRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = UsuariosRepository(db);
    });
    tearDown(() => db.close());

    test('el primer usuario es propietario y entra con su PIN', () async {
      await repo.crear(const DatosUsuario(
          nombre: 'Edith', usuario: ' Edith ', rol: RolUsuario.admin, pin: '2580'));
      final edith = await repo.autenticar('edith', '2580');
      expect(edith!.rol, RolUsuario.propietario, reason: 'el primero siempre es propietario');
      expect(edith.pinHash, isNot(contains('2580')));
      expect(await repo.autenticar('edith', '0000'), isNull);
      expect(await repo.autenticar('nadie', '2580'), isNull);
    });

    test('no repite usuarios y siempre deja un propietario activo', () async {
      final edith = await repo.crear(const DatosUsuario(
          nombre: 'Edith', usuario: 'edith', rol: RolUsuario.propietario, pin: '2580'));
      final luis = await repo.crear(const DatosUsuario(
          nombre: 'Luis', usuario: 'luis', rol: RolUsuario.admin, pin: '1357'));

      expect(
          () => repo.crear(const DatosUsuario(
              nombre: 'Otra', usuario: 'EDITH', rol: RolUsuario.admin, pin: '9876')),
          throwsA(isA<OperacionNoPermitida>()));
      expect(() => repo.cambiarActivo(edith, false), throwsA(isA<OperacionNoPermitida>()));
      expect(
          () => repo.actualizar(
              edith, const DatosUsuario(nombre: 'Edith', usuario: 'edith', rol: RolUsuario.admin)),
          throwsA(isA<OperacionNoPermitida>()));

      // Un administrador desactivado ya no puede entrar.
      await repo.cambiarActivo(luis, false);
      expect(await repo.autenticar('luis', '1357'), isNull);

      // Cambiar el PIN.
      await repo.actualizar(edith,
          const DatosUsuario(nombre: 'Edith M.', usuario: 'edith', rol: RolUsuario.propietario, pin: '4826'));
      expect(await repo.autenticar('edith', '2580'), isNull);
      expect((await repo.autenticar('edith', '4826'))!.nombre, 'Edith M.');
    });
  });

  group('pantalla de acceso', () {
    Future<void> abrir(WidgetTester tester, List<Usuario> usuarios) async {
      tester.view.physicalSize = const Size(900, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
        overrides: [
          usuariosProvider.overrideWith((ref) => Stream.value(usuarios)),
          usuariosRepositoryProvider.overrideWith((ref) => _RepoFalso(usuarios)),
        ],
        child: MaterialApp(
          builder: (context, child) => PuertaSesion(child: child!),
          home: const Scaffold(body: Text('Dentro de la app')),
        ),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('sin usuarios pide crear al propietario', (tester) async {
      await abrir(tester, const []);
      expect(find.text('Bienvenida a NET_MAX'), findsOneWidget);
      expect(find.text('Crear y entrar'), findsOneWidget);
      expect(find.text('Dentro de la app'), findsNothing);
    });

    testWidgets('con PIN incorrecto avisa y con el correcto entra', (tester) async {
      await abrir(tester, [
        _usuario(1, 'Edith', RolUsuario.propietario),
        _usuario(2, 'Luis', RolUsuario.admin),
      ]);
      expect(find.text('Iniciar sesión'), findsOneWidget);
      expect(find.text('Dentro de la app'), findsNothing);

      await tester.tap(find.text('Luis'));
      await tester.pumpAndSettle();
      expect(find.text('PIN de Luis'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '1111');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();
      expect(find.text('PIN incorrecto'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '2580');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();
      expect(find.text('Dentro de la app'), findsOneWidget);
    });
  });
}
