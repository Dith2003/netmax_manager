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
  var bytes = utf8.encode('$sal:$pin');
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
// Permisos
// ---------------------------------------------------------------------------

/// Qué puede hacer cada rol. El propietario puede todo; el administrador
/// registra clientes y pagos, pero no cambia la configuración, no restaura
/// respaldos, no cancela pagos ni administra usuarios.
class Permisos {
  const Permisos._({
    required this.configurar,
    required this.restaurarRespaldos,
    required this.cancelarPagos,
    required this.administrarUsuarios,
  });

  final bool configurar;
  final bool restaurarRespaldos;
  final bool cancelarPagos;
  final bool administrarUsuarios;

  static const todos = Permisos._(
    configurar: true,
    restaurarRespaldos: true,
    cancelarPagos: true,
    administrarUsuarios: true,
  );

  static const limitados = Permisos._(
    configurar: false,
    restaurarRespaldos: false,
    cancelarPagos: false,
    administrarUsuarios: false,
  );
}

/// Permisos de un rol. Sin rol (sin sesión, solo en pruebas de pantallas) = todos.
Permisos permisosDe(RolUsuario? rol) =>
    rol == RolUsuario.admin ? Permisos.limitados : Permisos.todos;
