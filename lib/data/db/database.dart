// Las reglas check() de drift se declaran haciendo referencia a la propia columna
// (p. ej. diaCorte.isBetweenValues), es el patrón documentado por drift.
// ignore_for_file: recursive_getters

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'enums.dart';

export 'enums.dart';

part 'database.g.dart';

// ---------------------------------------------------------------------------
// Tablas. Montos en CENTAVOS (int). Ver docs/schema.sql como referencia.
// ---------------------------------------------------------------------------

@DataClassName('Usuario')
class Usuarios extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text()();
  TextColumn get usuario => text().unique()();
  TextColumn get pinHash => text()();
  TextColumn get rol => textEnum<RolUsuario>()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  DateTimeColumn get creadoEn => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Plan')
class Planes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text()();
  IntColumn get velocidadMbps => integer()();
  IntColumn get precioBase => integer()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
}

@DataClassName('Cliente')
class Clientes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text()();
  TextColumn get telefono => text().nullable()();
  TextColumn get direccion => text().nullable()();
  TextColumn get zona => text().nullable()();
  TextColumn get referencia => text().nullable()();
  IntColumn get planId => integer().references(Planes, #id)();
  IntColumn get precioMensual => integer()();
  IntColumn get diaCorte => integer().check(diaCorte.isBetweenValues(1, 28))();
  TextColumn get tipoContratacion => textEnum<TipoContratacion>()();
  DateTimeColumn get fechaAlta => dateTime()();
  /// Primer mes que se cobra, 'YYYY-MM' (puede ser el mes del alta, el siguiente u otro).
  /// Nullable solo por la migración; siempre se llena. Ver domain/vencimientos.dart.
  TextColumn get primerMesCobro => text().nullable().withLength(min: 7, max: 7)();
  TextColumn get estado => textEnum<EstadoCliente>()
      .withDefault(Constant(EstadoCliente.activo.name))();
  TextColumn get notas => text().nullable()();
  DateTimeColumn get creadoEn => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Instalacion')
class Instalaciones extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clienteId => integer().references(Clientes, #id)();
  DateTimeColumn get fecha => dateTime()();
  IntColumn get costo => integer().withDefault(const Constant(0))();
  BoolColumn get pagado => boolean().withDefault(const Constant(false))();
  TextColumn get tecnico => text().nullable()();
  TextColumn get notas => text().nullable()();
}

@DataClassName('Equipo')
class Equipos extends Table {
  IntColumn get id => integer().autoIncrement()();
  /// null = equipo en bodega.
  IntColumn get clienteId => integer().nullable().references(Clientes, #id)();
  TextColumn get tipo => text()(); // antena, router, cable...
  TextColumn get marcaModelo => text().nullable()();
  TextColumn get numeroSerie => text().nullable()();
  TextColumn get propiedad => textEnum<PropiedadEquipo>()();
  IntColumn get costo => integer().nullable()();
  DateTimeColumn get fechaEntrega => dateTime().nullable()();
  DateTimeColumn get fechaRetiro => dateTime().nullable()();
  TextColumn get notas => text().nullable()();
}

/// Un renglón por cada mes de servicio de cada cliente.
@DataClassName('PeriodoRow')
class Periodos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clienteId => integer().references(Clientes, #id)();
  /// Formato 'YYYY-MM' (ver core/mes.dart).
  TextColumn get mes => text().withLength(min: 7, max: 7)();
  DateTimeColumn get fechaVencimiento => dateTime()();
  /// Copia del precio del cliente al momento de generarse.
  IntColumn get monto => integer()();
  BoolColumn get esCortesia => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {clienteId, mes},
      ];
}

@DataClassName('Pago')
class Pagos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clienteId => integer().references(Clientes, #id)();
  DateTimeColumn get fechaPago => dateTime()();
  IntColumn get monto => integer().check(monto.isBiggerThanValue(0))();
  TextColumn get metodo => textEnum<MetodoPago>()();
  TextColumn get folio => text().nullable()();
  IntColumn get registradoPor => integer().nullable().references(Usuarios, #id)();
  BoolColumn get cancelado => boolean().withDefault(const Constant(false))();
  TextColumn get notas => text().nullable()();
  DateTimeColumn get creadoEn => dateTime().withDefault(currentDateAndTime)();
}

/// Qué parte de cada pago se aplicó a qué mes.
@DataClassName('PagoAplicacion')
class PagoAplicaciones extends Table {
  IntColumn get pagoId => integer().references(Pagos, #id)();
  IntColumn get periodoId => integer().references(Periodos, #id)();
  IntColumn get monto => integer().check(monto.isBiggerThanValue(0))();

  @override
  Set<Column> get primaryKey => {pagoId, periodoId};
}

/// Cargo extra a un cliente (p. ej. equipo no devuelto, reconexión).
/// Se debe desde su fecha y los pagos lo cubren junto con los meses.
@DataClassName('Cargo')
class Cargos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clienteId => integer().references(Clientes, #id)();
  DateTimeColumn get fecha => dateTime()();
  TextColumn get concepto => text()();
  IntColumn get monto => integer().check(monto.isBiggerThanValue(0))();
  /// Equipo relacionado (si el cargo es por equipo no devuelto).
  IntColumn get equipoId => integer().nullable().references(Equipos, #id)();
  BoolColumn get cancelado => boolean().withDefault(const Constant(false))();
  TextColumn get notas => text().nullable()();
  DateTimeColumn get creadoEn => dateTime()();
}

/// Qué parte de cada pago se aplicó a qué cargo extra.
@DataClassName('CargoAplicacion')
class CargoAplicaciones extends Table {
  IntColumn get pagoId => integer().references(Pagos, #id)();
  IntColumn get cargoId => integer().references(Cargos, #id)();
  IntColumn get monto => integer().check(monto.isBiggerThanValue(0))();

  @override
  Set<Column> get primaryKey => {pagoId, cargoId};
}

@DataClassName('HistorialEstado')
class HistorialEstados extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clienteId => integer().references(Clientes, #id)();
  TextColumn get estadoAnterior => textEnum<EstadoCliente>().nullable()();
  TextColumn get estadoNuevo => textEnum<EstadoCliente>()();
  TextColumn get motivo => text().nullable()();
  IntColumn get usuarioId => integer().nullable().references(Usuarios, #id)();
  DateTimeColumn get fecha => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Gasto')
class Gastos extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get fecha => dateTime()();
  TextColumn get concepto => text()();
  TextColumn get categoria => text().nullable()();
  IntColumn get monto => integer().check(monto.isBiggerThanValue(0))();
  IntColumn get usuarioId => integer().nullable().references(Usuarios, #id)();
  TextColumn get notas => text().nullable()();
}

@DataClassName('ConfigItem')
class Configuraciones extends Table {
  TextColumn get clave => text()();
  TextColumn get valor => text()();

  @override
  Set<Column> get primaryKey => {clave};
}

// ---------------------------------------------------------------------------
// Base de datos
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [
  Usuarios,
  Planes,
  Clientes,
  Instalaciones,
  Equipos,
  Periodos,
  Pagos,
  PagoAplicaciones,
  Cargos,
  CargoAplicaciones,
  HistorialEstados,
  Gastos,
  Configuraciones,
])
class AppDatabase extends _$AppDatabase {
  /// Sin parámetros abre el archivo de la app ([rutaArchivo]).
  /// En pruebas se puede pasar una base en memoria.
  AppDatabase([QueryExecutor? executor])
      : super(executor ??
            driftDatabase(
              name: 'netmax',
              native: const DriftNativeOptions(databasePath: rutaArchivo),
            ));

  /// Ruta del archivo de la base de datos: `netmax.sqlite` en la carpeta de
  /// documentos de la app (la misma que usa drift_flutter por defecto).
  static Future<String> rutaArchivo() async {
    final carpeta = await getApplicationDocumentsDirectory();
    return '${carpeta.path}${Platform.pathSeparator}netmax.sqlite';
  }

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _datosIniciales();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2: primer mes de cobro. Para clientes existentes = mes de la fecha de alta
            // (la regla que se usaba hasta ahora).
            await m.addColumn(clientes, clientes.primerMesCobro);
            await customStatement(
                'UPDATE clientes SET primer_mes_cobro = substr(fecha_alta, 1, 7)');
          }
          if (from < 3) {
            // v3: cargos extra.
            await m.createTable(cargos);
            await m.createTable(cargoAplicaciones);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _datosIniciales() async {
    await into(planes).insert(PlanesCompanion.insert(
      nombre: '10 Mbps',
      velocidadMbps: 10,
      precioBase: 25000,
    ));
    await batch((b) {
      b.insertAll(configuraciones, [
        ConfiguracionesCompanion.insert(clave: 'negocio_nombre', valor: 'NetMAX'),
        ConfiguracionesCompanion.insert(clave: 'dias_gracia', valor: '5'),
        ConfiguracionesCompanion.insert(clave: 'meses_generar_adelante', valor: '12'),
      ]);
    });
  }
}
