/// Sesión del usuario: quién está usando la app y qué puede hacer.
///
/// La sesión vive en memoria: se pide usuario y PIN cada vez que se abre la app
/// (o tras "Cerrar sesión"). Al restaurar un respaldo la app se reconstruye y
/// vuelve a pedir el acceso.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart';
import '../data/repositories/usuarios_repository.dart';
import '../domain/usuarios.dart';
import 'providers.dart';

final usuariosRepositoryProvider = Provider<UsuariosRepository>(
  (ref) => UsuariosRepository(ref.watch(databaseProvider)),
);

/// Todos los usuarios (activos e inactivos).
final usuariosProvider = StreamProvider<List<Usuario>>(
  (ref) => ref.watch(usuariosRepositoryProvider).vigilarUsuarios(),
);

/// Usuario con el que arranca la sesión (null = pedir acceso). Se cambia en pruebas.
final sesionInicialProvider = Provider<Usuario?>((ref) => null);

class SesionNotifier extends Notifier<Usuario?> {
  @override
  Usuario? build() => ref.read(sesionInicialProvider);

  void iniciar(Usuario usuario) => state = usuario;

  void cerrar() => state = null;
}

/// Usuario que está usando la app (null = falta iniciar sesión).
final sesionProvider = NotifierProvider<SesionNotifier, Usuario?>(SesionNotifier.new);

/// Lo que puede hacer el usuario actual.
final permisosProvider = Provider<Permisos>(
  (ref) => permisosDe(ref.watch(sesionProvider)?.rol),
);

/// Nombre de cada usuario por id (para mostrar quién registró un pago o un cambio).
final nombresUsuariosProvider = Provider<Map<int, String>>(
  (ref) =>
      ref.watch(usuariosProvider).whenOrNull(data: (l) => {for (final u in l) u.id: u.nombre}) ??
      const {},
);
