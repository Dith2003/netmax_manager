import 'dart:io';

import 'package:sqlite3/sqlite3.dart' as sqlite;

import '../db/database.dart';

/// Resumen de un archivo de respaldo, para mostrarlo antes de restaurar.
class InfoRespaldo {
  const InfoRespaldo({
    required this.version,
    required this.clientes,
    required this.pagos,
    this.ultimoPago,
  });

  /// Versión del esquema de la base de datos del respaldo.
  final int version;
  final int clientes;
  final int pagos;

  /// Fecha del pago más reciente (sirve para saber qué tan actual es el respaldo).
  final DateTime? ultimoPago;
}

/// El archivo elegido no es un respaldo válido de NET_MAX.
class RespaldoNoValido implements Exception {
  const RespaldoNoValido(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Crear, validar y restaurar respaldos de la base de datos.
///
/// Un respaldo es una copia completa del archivo SQLite (`.db`). Se crea con
/// `VACUUM INTO`, que hace una copia consistente aunque la app esté abierta.
class RespaldoService {
  RespaldoService(this._db);

  final AppDatabase _db;

  static const claveUltimoRespaldo = 'ultimo_respaldo';

  /// "netmax_respaldo_2026-11-03_2015.db"
  static String nombreSugerido(DateTime fecha) {
    String dos(int n) => n.toString().padLeft(2, '0');
    return 'netmax_respaldo_${fecha.year}-${dos(fecha.month)}-${dos(fecha.day)}'
        '_${dos(fecha.hour)}${dos(fecha.minute)}.db';
  }

  /// Copia la base de datos completa a [rutaDestino] (si existe, se reemplaza).
  /// Si [registrar] es true, guarda la fecha como "último respaldo".
  Future<File> crearRespaldo(String rutaDestino, {bool registrar = true}) async {
    final destino = File(rutaDestino);
    if (await destino.exists()) await destino.delete();
    await _db.customStatement('VACUUM INTO ?', [rutaDestino]);
    if (registrar) {
      await _db.into(_db.configuraciones).insertOnConflictUpdate(ConfiguracionesCompanion.insert(
            clave: claveUltimoRespaldo,
            valor: DateTime.now().toIso8601String(),
          ));
    }
    return destino;
  }

  /// Fecha del último respaldo hecho desde esta app (null si nunca).
  Stream<DateTime?> vigilarUltimoRespaldo() {
    return (_db.select(_db.configuraciones)
          ..where((c) => c.clave.equals(claveUltimoRespaldo)))
        .watchSingleOrNull()
        .map((c) => c == null ? null : DateTime.tryParse(c.valor));
  }

  /// Revisa que [ruta] sea un respaldo de NET_MAX que esta versión de la app
  /// pueda abrir. Lanza [RespaldoNoValido] con el motivo si no lo es.
  static InfoRespaldo validar(String ruta, {required int versionApp}) {
    if (!File(ruta).existsSync()) {
      throw const RespaldoNoValido('No se encontró el archivo.');
    }
    final sqlite.Database bd;
    try {
      bd = sqlite.sqlite3.open(ruta, mode: sqlite.OpenMode.readOnly);
    } on Object {
      throw const RespaldoNoValido('El archivo no es una base de datos.');
    }
    try {
      final String integridad;
      try {
        integridad = bd.select('PRAGMA integrity_check').first.values.first.toString();
      } on Object {
        throw const RespaldoNoValido('El archivo no es una base de datos de NET_MAX.');
      }
      if (integridad != 'ok') {
        throw const RespaldoNoValido('El archivo está dañado.');
      }

      final tablas = bd
          .select("SELECT name FROM sqlite_master WHERE type = 'table'")
          .map((f) => f['name'] as String)
          .toSet();
      if (!tablas.containsAll(['clientes', 'pagos', 'periodos'])) {
        throw const RespaldoNoValido('El archivo no es un respaldo de NET_MAX.');
      }

      final version = bd.select('PRAGMA user_version').first.values.first as int;
      if (version < 1) {
        throw const RespaldoNoValido('El archivo no es un respaldo de NET_MAX.');
      }
      if (version > versionApp) {
        throw const RespaldoNoValido(
            'El respaldo es de una versión más nueva de la app. Actualiza la app primero.');
      }

      int contar(String tabla) =>
          bd.select('SELECT COUNT(*) AS n FROM $tabla').first['n'] as int;
      final ultimo = bd
          .select('SELECT MAX(fecha_pago) AS f FROM pagos WHERE cancelado = 0')
          .first['f'] as String?;

      return InfoRespaldo(
        version: version,
        clientes: contar('clientes'),
        pagos: contar('pagos'),
        ultimoPago: ultimo == null ? null : DateTime.tryParse(ultimo)?.toLocal(),
      );
    } finally {
      bd.close();
    }
  }

  /// Copia el respaldo sobre el archivo de la base de datos de la app.
  /// La base de datos debe estar CERRADA. Borra los archivos auxiliares de SQLite
  /// (-wal, -shm, -journal) que pudieran quedar del archivo anterior.
  static Future<void> reemplazarArchivo({
    required String respaldo,
    required String destino,
  }) async {
    for (final sufijo in ['-wal', '-shm', '-journal']) {
      final aux = File('$destino$sufijo');
      if (await aux.exists()) await aux.delete();
    }
    await File(respaldo).copy(destino);
  }
}

/// Días completos desde el último respaldo (null si nunca se ha hecho).
int? diasDesdeRespaldo(DateTime? ultimo, DateTime hoy) {
  if (ultimo == null) return null;
  final a = DateTime(ultimo.year, ultimo.month, ultimo.day);
  final b = DateTime(hoy.year, hoy.month, hoy.day);
  return b.difference(a).inDays;
}

/// Se recomienda respaldar si nunca se ha hecho o si pasaron más de [dias] días.
bool necesitaRespaldo(DateTime? ultimo, DateTime hoy, {int dias = 7}) {
  final d = diasDesdeRespaldo(ultimo, hoy);
  return d == null || d > dias;
}
