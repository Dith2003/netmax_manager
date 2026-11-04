import 'package:drift/drift.dart';

import '../../domain/usuarios.dart';
import '../db/database.dart';
import 'vencimientos_repository.dart' show OperacionNoPermitida;

/// Datos del formulario de usuario.
class DatosUsuario {
  const DatosUsuario({
    required this.nombre,
    required this.usuario,
    required this.rol,
    this.pin,
  });

  final String nombre;
  final String usuario;
  final RolUsuario rol;

  /// Obligatorio al crear; al editar, null = no cambia.
  final String? pin;
}

/// Usuarios que pueden entrar a la app (se guardan en el propio equipo).
/// No se borran: se desactivan. Siempre debe quedar un propietario activo.
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

  /// Crea un usuario. El primero siempre es propietario.
  Future<int> crear(DatosUsuario d) => _db.transaction(() async {
        final pin = d.pin;
        if (pin == null || validarPin(pin) != null) {
          throw const OperacionNoPermitida('El PIN debe tener de 4 a 6 números.');
        }
        if (await _porUsuario(d.usuario) != null) {
          throw OperacionNoPermitida('Ya existe el usuario "${normalizarUsuario(d.usuario)}".');
        }
        final hayOtros = await (_db.select(_db.usuarios)..limit(1)).getSingleOrNull() != null;
        return _db.into(_db.usuarios).insert(UsuariosCompanion.insert(
              nombre: d.nombre.trim(),
              usuario: normalizarUsuario(d.usuario),
              pinHash: protegerPin(pin),
              rol: hayOtros ? d.rol : RolUsuario.propietario,
              creadoEn: Value(DateTime.now()),
            ));
      });

  /// Verifica usuario y PIN. Devuelve el usuario si es correcto y está activo.
  Future<Usuario?> autenticar(String usuario, String pin) async {
    final u = await _porUsuario(usuario);
    if (u == null || !u.activo) return null;
    return verificarPin(pin.trim(), u.pinHash) ? u : null;
  }

  /// Cambia nombre, rol y, si viene, el PIN.
  Future<void> actualizar(int id, DatosUsuario d) => _db.transaction(() async {
        final actual = await (_db.select(_db.usuarios)..where((u) => u.id.equals(id))).getSingle();
        if (actual.rol == RolUsuario.propietario && d.rol != RolUsuario.propietario) {
          await _verificarQueQuedeOtroPropietario(id);
        }
        final pin = d.pin;
        if (pin != null && validarPin(pin) != null) {
          throw const OperacionNoPermitida('El PIN debe tener de 4 a 6 números.');
        }
        await (_db.update(_db.usuarios)..where((u) => u.id.equals(id))).write(UsuariosCompanion(
          nombre: Value(d.nombre.trim()),
          rol: Value(d.rol),
          pinHash: pin == null ? const Value.absent() : Value(protegerPin(pin)),
        ));
      });

  /// Activa o desactiva un usuario (un desactivado ya no puede entrar).
  Future<void> cambiarActivo(int id, bool activo) => _db.transaction(() async {
        if (!activo) {
          final u = await (_db.select(_db.usuarios)..where((u) => u.id.equals(id))).getSingle();
          if (u.rol == RolUsuario.propietario) await _verificarQueQuedeOtroPropietario(id);
        }
        await (_db.update(_db.usuarios)..where((u) => u.id.equals(id)))
            .write(UsuariosCompanion(activo: Value(activo)));
      });

  Future<void> _verificarQueQuedeOtroPropietario(int id) async {
    final otros = await (_db.select(_db.usuarios)
          ..where((u) =>
              u.rol.equalsValue(RolUsuario.propietario) &
              u.activo.equals(true) &
              u.id.equals(id).not()))
        .get();
    if (otros.isEmpty) {
      throw const OperacionNoPermitida(
          'Debe quedar al menos un propietario activo para administrar la app.');
    }
  }
}
