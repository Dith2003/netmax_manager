import 'package:drift/drift.dart';

import '../../domain/usuarios.dart';
import '../db/database.dart';
import 'vencimientos_repository.dart' show OperacionNoPermitida;

/// Datos del formulario de usuario.
class DatosUsuario {
  const DatosUsuario({
    required this.nombre,
    required this.usuario,
    required this.permisos,
    this.pin,
  });

  final String nombre;
  final String usuario;

  /// Lo que puede hacer (se parte de un [PerfilBase] y se ajusta).
  final Set<Permiso> permisos;

  /// Obligatorio al crear; al editar, null = no cambia.
  final String? pin;
}

/// Permisos efectivos de un usuario.
Set<Permiso> permisosDeUsuario(Usuario u) => leerPermisos(u.permisos, u.rol);

/// Usuarios que pueden entrar a la app (se guardan en el propio equipo).
/// No se borran: se desactivan. Siempre debe quedar un usuario activo que pueda
/// administrar usuarios (si no, nadie podría cambiar un PIN olvidado).
class UsuariosRepository {
  UsuariosRepository(this._db);

  final AppDatabase _db;

  /// Todos los usuarios: activos primero, luego por nombre.
  Stream<List<Usuario>> vigilarUsuarios() {
    return (_db.select(_db.usuarios)
          ..orderBy([
            (u) => OrderingTerm.desc(u.activo),
            (u) => OrderingTerm.asc(u.nombre),
          ]))
        .watch();
  }

  Future<Usuario?> _porUsuario(String usuario) {
    return (_db.select(_db.usuarios)
          ..where((u) => u.usuario.equals(normalizarUsuario(usuario))))
        .getSingleOrNull();
  }

  /// Crea un usuario. El primero siempre tiene todos los permisos.
  Future<int> crear(DatosUsuario d) => _db.transaction(() async {
        final pin = d.pin;
        if (pin == null || validarPin(pin) != null) {
          throw const OperacionNoPermitida('El PIN debe tener de 4 a 6 números.');
        }
        if (await _porUsuario(d.usuario) != null) {
          throw OperacionNoPermitida('Ya existe el usuario "${normalizarUsuario(d.usuario)}".');
        }
        final hayOtros = await (_db.select(_db.usuarios)..limit(1)).getSingleOrNull() != null;
        final permisos = hayOtros ? d.permisos : PerfilBase.propietario.permisos;
        return _db.into(_db.usuarios).insert(UsuariosCompanion.insert(
              nombre: d.nombre.trim(),
              usuario: normalizarUsuario(d.usuario),
              pinHash: protegerPin(pin),
              rol: rolParaPermisos(permisos),
              permisos: Value(guardarPermisos(permisos)),
              creadoEn: Value(DateTime.now()),
            ));
      });

  /// Verifica usuario y PIN. Devuelve el usuario si es correcto y está activo.
  Future<Usuario?> autenticar(String usuario, String pin) async {
    final u = await _porUsuario(usuario);
    if (u == null || !u.activo) return null;
    return verificarPin(pin.trim(), u.pinHash) ? u : null;
  }

  /// Cambia nombre, permisos y, si viene, el PIN.
  Future<void> actualizar(int id, DatosUsuario d) => _db.transaction(() async {
        if (!d.permisos.contains(Permiso.administrarUsuarios)) {
          await _verificarQueQuedeOtroAdministrador(id);
        }
        final pin = d.pin;
        if (pin != null && validarPin(pin) != null) {
          throw const OperacionNoPermitida('El PIN debe tener de 4 a 6 números.');
        }
        await (_db.update(_db.usuarios)..where((u) => u.id.equals(id))).write(UsuariosCompanion(
          nombre: Value(d.nombre.trim()),
          rol: Value(rolParaPermisos(d.permisos)),
          permisos: Value(guardarPermisos(d.permisos)),
          pinHash: pin == null ? const Value.absent() : Value(protegerPin(pin)),
        ));
      });

  /// Activa o desactiva un usuario (un desactivado ya no puede entrar).
  Future<void> cambiarActivo(int id, bool activo) => _db.transaction(() async {
        if (!activo) await _verificarQueQuedeOtroAdministrador(id);
        await (_db.update(_db.usuarios)..where((u) => u.id.equals(id)))
            .write(UsuariosCompanion(activo: Value(activo)));
      });

  /// Falla si [id] es el único usuario activo que puede administrar usuarios.
  Future<void> _verificarQueQuedeOtroAdministrador(int id) async {
    final activos =
        await (_db.select(_db.usuarios)..where((u) => u.activo.equals(true))).get();
    final quedan = activos.where(
        (u) => u.id != id && permisosDeUsuario(u).contains(Permiso.administrarUsuarios));
    if (quedan.isEmpty) {
      throw const OperacionNoPermitida(
          'Debe quedar al menos un usuario activo que pueda administrar usuarios.');
    }
  }
}
