/// Usuarios, PIN y permisos (lógica pura, sin base de datos ni pantallas).
library;

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../data/db/enums.dart';

// ---------------------------------------------------------------------------
// PIN
// ---------------------------------------------------------------------------

/// Vueltas de SHA-256 al guardar un PIN: hace lento probar todos los PIN
/// posibles si alguien copia el archivo de la base de datos.
const _vueltas = 20000;

/// Guarda el PIN como "v1$sal$huella" (nunca el PIN en claro).
/// [sal] solo se pasa en las pruebas; normalmente es aleatoria.
String protegerPin(String pin, {String? sal}) {
  final s = sal ?? base64Url.encode(List.generate(16, (_) => Random.secure().nextInt(256)));
  return 'v1\$$s\$${_huella(pin, s)}';
}

/// True si [pin] corresponde a lo guardado con [protegerPin].
bool verificarPin(String pin, String guardado) {
  final partes = guardado.split(r'$');
  if (partes.length != 3 || partes[0] != 'v1') return false;
  return _igualesSinFiltrarTiempo(_huella(pin, partes[1]), partes[2]);
}

String _huella(String pin, String sal) {
  List<int> bytes = utf8.encode('$sal:$pin');
  for (var i = 0; i < _vueltas; i++) {
    bytes = sha256.convert(bytes).bytes;
  }
  return base64Url.encode(bytes);
}

bool _igualesSinFiltrarTiempo(String a, String b) {
  if (a.length != b.length) return false;
  var diferencia = 0;
  for (var i = 0; i < a.length; i++) {
    diferencia |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return diferencia == 0;
}

// ---------------------------------------------------------------------------
// Validaciones de formulario
// ---------------------------------------------------------------------------

/// PIN de 4 a 6 números.
String? validarPin(String? valor) {
  final v = valor?.trim() ?? '';
  if (v.isEmpty) return 'Escribe el PIN';
  if (!RegExp(r'^\d{4,6}$').hasMatch(v)) return 'De 4 a 6 números';
  if (RegExp(r'^(\d)\1+$').hasMatch(v)) return 'No uses el mismo número repetido';
  return null;
}

/// Nombre de usuario: 3 a 20 letras minúsculas, números, punto o guion bajo.
String? validarNombreUsuario(String? valor) {
  final v = normalizarUsuario(valor ?? '');
  if (v.isEmpty) return 'Escribe el usuario';
  if (!RegExp(r'^[a-z0-9._]{3,20}$').hasMatch(v)) {
    return 'De 3 a 20 letras sin acentos, números, punto o guion bajo';
  }
  return null;
}

/// "  Edith " -> "edith". Los usuarios se comparan sin mayúsculas.
String normalizarUsuario(String usuario) => usuario.trim().toLowerCase();

// ---------------------------------------------------------------------------
// Intentos fallidos
// ---------------------------------------------------------------------------

/// Después de [intentosPermitidos] PIN incorrectos seguidos se espera [espera].
const intentosPermitidos = 5;
const espera = Duration(seconds: 30);

/// Hasta cuándo está bloqueado el acceso (null si no lo está).
DateTime? bloqueadoHasta({required int fallidos, required DateTime ultimoFallo}) =>
    fallidos >= intentosPermitidos ? ultimoFallo.add(espera) : null;

// ---------------------------------------------------------------------------
// Permisos (cada usuario tiene los suyos; los perfiles son solo plantillas)
// ---------------------------------------------------------------------------

/// Lo que puede hacer un usuario. Se guarda en `usuarios.permisos` por nombre.
enum Permiso {
  registrarPagos('Registrar pagos', 'Cobrar y generar comprobantes', 'Cobranza'),
  cancelarPagos('Cancelar pagos', 'Anular un pago capturado por error', 'Cobranza'),
  ajustarCuentas('Ajustar estados de cuenta',
      'Cortesías, agregar o quitar meses y cargos extra', 'Cobranza'),
  gestionarClientes('Registrar y editar clientes',
      'Altas, datos, instalaciones y equipos', 'Clientes'),
  cambiarEstadoClientes('Suspender, reactivar y cancelar clientes',
      'Cambiar el estado del servicio', 'Clientes'),
  verReportes('Ver reportes', 'Reportes en PDF y comprobantes del mes', 'Reportes y respaldos'),
  crearRespaldos('Crear respaldos', 'Guardar una copia de la información', 'Reportes y respaldos'),
  restaurarRespaldos('Restaurar respaldos',
      'Reemplazar toda la información por la de un respaldo', 'Reportes y respaldos'),
  configurar('Configurar planes y contratación', 'Sección Configuración', 'Administración'),
  administrarUsuarios('Administrar usuarios',
      'Crear usuarios, cambiar PIN y permisos', 'Administración');

  const Permiso(this.etiqueta, this.descripcion, this.grupo);

  final String etiqueta;
  final String descripcion;

  /// Para agrupar las casillas en el formulario.
  final String grupo;
}

/// Perfiles base (plantillas). Al crear un usuario se elige uno y después se
/// puede ajustar permiso por permiso.
enum PerfilBase {
  propietario('Propietario', 'Puede hacer todo'),
  administrador('Administrador',
      'Registra clientes y pagos; no cancela pagos, no restaura respaldos, no configura');

  const PerfilBase(this.nombre, this.descripcion);

  final String nombre;
  final String descripcion;

  Set<Permiso> get permisos => switch (this) {
        PerfilBase.propietario => Permiso.values.toSet(),
        PerfilBase.administrador => const {
            Permiso.registrarPagos,
            Permiso.ajustarCuentas,
            Permiso.gestionarClientes,
            Permiso.cambiarEstadoClientes,
            Permiso.verReportes,
            Permiso.crearRespaldos,
          },
      };

  /// Rol que se guarda en `usuarios.rol` (solo como referencia del perfil).
  RolUsuario get rol =>
      this == PerfilBase.propietario ? RolUsuario.propietario : RolUsuario.admin;
}

/// Texto que se guarda: "registrarPagos,verReportes".
String guardarPermisos(Set<Permiso> permisos) =>
    [for (final p in Permiso.values) if (permisos.contains(p)) p.name].join(',');

/// Lee los permisos guardados. Sin permisos guardados (usuarios anteriores a
/// esta versión) se usan los del perfil de su rol.
Set<Permiso> leerPermisos(String? texto, RolUsuario rol) {
  if (texto == null) {
    return (rol == RolUsuario.propietario ? PerfilBase.propietario : PerfilBase.administrador)
        .permisos;
  }
  final nombres = texto.split(',').map((t) => t.trim()).toSet();
  return {for (final p in Permiso.values) if (nombres.contains(p.name)) p};
}

/// "Propietario", "Administrador" o "Personalizado" según los permisos.
String nombrePerfil(Set<Permiso> permisos) {
  for (final perfil in PerfilBase.values) {
    if (perfil.permisos.length == permisos.length && perfil.permisos.containsAll(permisos)) {
      return perfil.nombre;
    }
  }
  return 'Personalizado';
}

/// Rol de referencia para guardar: propietario si puede administrar usuarios.
RolUsuario rolParaPermisos(Set<Permiso> permisos) =>
    permisos.contains(Permiso.administrarUsuarios) ? RolUsuario.propietario : RolUsuario.admin;

/// Permisos del usuario de la sesión.
class Permisos {
  const Permisos(this.conjunto);

  final Set<Permiso> conjunto;

  /// Todos los permisos (sin sesión: solo pasa en las pruebas de pantallas).
  static final todos = Permisos(Permiso.values.toSet());

  bool tiene(Permiso p) => conjunto.contains(p);

  bool get registrarPagos => tiene(Permiso.registrarPagos);
  bool get cancelarPagos => tiene(Permiso.cancelarPagos);
  bool get ajustarCuentas => tiene(Permiso.ajustarCuentas);
  bool get gestionarClientes => tiene(Permiso.gestionarClientes);
  bool get cambiarEstadoClientes => tiene(Permiso.cambiarEstadoClientes);
  bool get verReportes => tiene(Permiso.verReportes);
  bool get crearRespaldos => tiene(Permiso.crearRespaldos);
  bool get restaurarRespaldos => tiene(Permiso.restaurarRespaldos);
  bool get configurar => tiene(Permiso.configurar);
  bool get administrarUsuarios => tiene(Permiso.administrarUsuarios);

  /// Ve la sección Configuración (planes o usuarios).
  bool get verConfiguracion => configurar || administrarUsuarios;

  /// Ve la sección Respaldos.
  bool get verRespaldos => crearRespaldos || restaurarRespaldos;
}
