import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netmax_manager/data/db/database.dart';

/// Simula una base de datos creada con la versión 1 (Sprint 1–3) y comprueba
/// que al abrirla con la versión actual se migra sin perder datos.
void main() {
  test('v1 → v5: primer_mes_cobro, tablas de cargos y contratación personalizada', () async {
    final db = AppDatabase(NativeDatabase.memory(setup: (raw) {
      // Solo hace falta la tabla que cambia en la migración.
      raw.execute('''
        CREATE TABLE clientes (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          nombre TEXT NOT NULL,
          telefono TEXT NULL,
          direccion TEXT NULL,
          zona TEXT NULL,
          referencia TEXT NULL,
          plan_id INTEGER NOT NULL,
          precio_mensual INTEGER NOT NULL,
          dia_corte INTEGER NOT NULL,
          tipo_contratacion TEXT NOT NULL,
          fecha_alta TEXT NOT NULL,
          estado TEXT NOT NULL DEFAULT 'activo',
          notas TEXT NULL,
          creado_en TEXT NOT NULL
        )
      ''');
      raw.execute('''
        INSERT INTO clientes (nombre, plan_id, precio_mensual, dia_corte,
          tipo_contratacion, fecha_alta, creado_en)
        VALUES ('Ana', 1, 25000, 5, 'equipoPropio', '2025-03-15T00:00:00.000',
          '2025-03-15T00:00:00.000')
      ''');
      raw.execute('''
        CREATE TABLE usuarios (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          nombre TEXT NOT NULL,
          usuario TEXT NOT NULL UNIQUE,
          pin_hash TEXT NOT NULL,
          rol TEXT NOT NULL,
          activo INTEGER NOT NULL DEFAULT 1,
          creado_en TEXT NOT NULL
        )
      ''');
      raw.execute('''
        INSERT INTO usuarios (nombre, usuario, pin_hash, rol, creado_en)
        VALUES ('Luis', 'luis', 'x', 'admin', '2026-11-01T00:00:00.000')
      ''');
      raw.userVersion = 1;
    }));
    addTearDown(db.close);

    final clientes = await db.select(db.clientes).get();
    expect(clientes.single.nombre, 'Ana');
    expect(clientes.single.primerMesCobro, '2025-03');
    expect(clientes.single.fechaAlta.year, 2025);

    // v3: existen las tablas de cargos extra.
    final cargos = await db.select(db.cargos).get();
    expect(cargos, isEmpty);
    final aplicaciones = await db.select(db.cargoAplicaciones).get();
    expect(aplicaciones, isEmpty);

    // v4: columna de la contratación personalizada (vacía en los clientes existentes).
    expect(clientes.single.tipoContratacionDetalle, isNull);

    // v5: permisos individuales; los usuarios existentes quedan sin permisos guardados
    // (usan los de su perfil).
    final luis = await db.select(db.usuarios).getSingle();
    expect(luis.permisos, isNull);
    expect(luis.rol, RolUsuario.admin);

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 5);
  });
}
