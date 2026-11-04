// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsuariosTable extends Usuarios with TableInfo<$UsuariosTable, Usuario> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsuariosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usuarioMeta = const VerificationMeta(
    'usuario',
  );
  @override
  late final GeneratedColumn<String> usuario = GeneratedColumn<String>(
    'usuario',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _pinHashMeta = const VerificationMeta(
    'pinHash',
  );
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
    'pin_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RolUsuario, String> rol =
      GeneratedColumn<String>(
        'rol',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RolUsuario>($UsuariosTable.$converterrol);
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    usuario,
    pinHash,
    rol,
    activo,
    creadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'usuarios';
  @override
  VerificationContext validateIntegrity(
    Insertable<Usuario> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('usuario')) {
      context.handle(
        _usuarioMeta,
        usuario.isAcceptableOrUnknown(data['usuario']!, _usuarioMeta),
      );
    } else if (isInserting) {
      context.missing(_usuarioMeta);
    }
    if (data.containsKey('pin_hash')) {
      context.handle(
        _pinHashMeta,
        pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta),
      );
    } else if (isInserting) {
      context.missing(_pinHashMeta);
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Usuario map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Usuario(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      usuario: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usuario'],
      )!,
      pinHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_hash'],
      )!,
      rol: $UsuariosTable.$converterrol.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}rol'],
        )!,
      ),
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
    );
  }

  @override
  $UsuariosTable createAlias(String alias) {
    return $UsuariosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RolUsuario, String, String> $converterrol =
      const EnumNameConverter<RolUsuario>(RolUsuario.values);
}

class Usuario extends DataClass implements Insertable<Usuario> {
  final int id;
  final String nombre;
  final String usuario;
  final String pinHash;
  final RolUsuario rol;
  final bool activo;
  final DateTime creadoEn;
  const Usuario({
    required this.id,
    required this.nombre,
    required this.usuario,
    required this.pinHash,
    required this.rol,
    required this.activo,
    required this.creadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    map['usuario'] = Variable<String>(usuario);
    map['pin_hash'] = Variable<String>(pinHash);
    {
      map['rol'] = Variable<String>($UsuariosTable.$converterrol.toSql(rol));
    }
    map['activo'] = Variable<bool>(activo);
    map['creado_en'] = Variable<DateTime>(creadoEn);
    return map;
  }

  UsuariosCompanion toCompanion(bool nullToAbsent) {
    return UsuariosCompanion(
      id: Value(id),
      nombre: Value(nombre),
      usuario: Value(usuario),
      pinHash: Value(pinHash),
      rol: Value(rol),
      activo: Value(activo),
      creadoEn: Value(creadoEn),
    );
  }

  factory Usuario.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Usuario(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      usuario: serializer.fromJson<String>(json['usuario']),
      pinHash: serializer.fromJson<String>(json['pinHash']),
      rol: $UsuariosTable.$converterrol.fromJson(
        serializer.fromJson<String>(json['rol']),
      ),
      activo: serializer.fromJson<bool>(json['activo']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'usuario': serializer.toJson<String>(usuario),
      'pinHash': serializer.toJson<String>(pinHash),
      'rol': serializer.toJson<String>(
        $UsuariosTable.$converterrol.toJson(rol),
      ),
      'activo': serializer.toJson<bool>(activo),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
    };
  }

  Usuario copyWith({
    int? id,
    String? nombre,
    String? usuario,
    String? pinHash,
    RolUsuario? rol,
    bool? activo,
    DateTime? creadoEn,
  }) => Usuario(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    usuario: usuario ?? this.usuario,
    pinHash: pinHash ?? this.pinHash,
    rol: rol ?? this.rol,
    activo: activo ?? this.activo,
    creadoEn: creadoEn ?? this.creadoEn,
  );
  Usuario copyWithCompanion(UsuariosCompanion data) {
    return Usuario(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      usuario: data.usuario.present ? data.usuario.value : this.usuario,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      rol: data.rol.present ? data.rol.value : this.rol,
      activo: data.activo.present ? data.activo.value : this.activo,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Usuario(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('usuario: $usuario, ')
          ..write('pinHash: $pinHash, ')
          ..write('rol: $rol, ')
          ..write('activo: $activo, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nombre, usuario, pinHash, rol, activo, creadoEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Usuario &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.usuario == this.usuario &&
          other.pinHash == this.pinHash &&
          other.rol == this.rol &&
          other.activo == this.activo &&
          other.creadoEn == this.creadoEn);
}

class UsuariosCompanion extends UpdateCompanion<Usuario> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String> usuario;
  final Value<String> pinHash;
  final Value<RolUsuario> rol;
  final Value<bool> activo;
  final Value<DateTime> creadoEn;
  const UsuariosCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.usuario = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.rol = const Value.absent(),
    this.activo = const Value.absent(),
    this.creadoEn = const Value.absent(),
  });
  UsuariosCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    required String usuario,
    required String pinHash,
    required RolUsuario rol,
    this.activo = const Value.absent(),
    this.creadoEn = const Value.absent(),
  }) : nombre = Value(nombre),
       usuario = Value(usuario),
       pinHash = Value(pinHash),
       rol = Value(rol);
  static Insertable<Usuario> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? usuario,
    Expression<String>? pinHash,
    Expression<String>? rol,
    Expression<bool>? activo,
    Expression<DateTime>? creadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (usuario != null) 'usuario': usuario,
      if (pinHash != null) 'pin_hash': pinHash,
      if (rol != null) 'rol': rol,
      if (activo != null) 'activo': activo,
      if (creadoEn != null) 'creado_en': creadoEn,
    });
  }

  UsuariosCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<String>? usuario,
    Value<String>? pinHash,
    Value<RolUsuario>? rol,
    Value<bool>? activo,
    Value<DateTime>? creadoEn,
  }) {
    return UsuariosCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      usuario: usuario ?? this.usuario,
      pinHash: pinHash ?? this.pinHash,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (usuario.present) {
      map['usuario'] = Variable<String>(usuario.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (rol.present) {
      map['rol'] = Variable<String>(
        $UsuariosTable.$converterrol.toSql(rol.value),
      );
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsuariosCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('usuario: $usuario, ')
          ..write('pinHash: $pinHash, ')
          ..write('rol: $rol, ')
          ..write('activo: $activo, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }
}

class $PlanesTable extends Planes with TableInfo<$PlanesTable, Plan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _velocidadMbpsMeta = const VerificationMeta(
    'velocidadMbps',
  );
  @override
  late final GeneratedColumn<int> velocidadMbps = GeneratedColumn<int>(
    'velocidad_mbps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precioBaseMeta = const VerificationMeta(
    'precioBase',
  );
  @override
  late final GeneratedColumn<int> precioBase = GeneratedColumn<int>(
    'precio_base',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    velocidadMbps,
    precioBase,
    activo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'planes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Plan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('velocidad_mbps')) {
      context.handle(
        _velocidadMbpsMeta,
        velocidadMbps.isAcceptableOrUnknown(
          data['velocidad_mbps']!,
          _velocidadMbpsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_velocidadMbpsMeta);
    }
    if (data.containsKey('precio_base')) {
      context.handle(
        _precioBaseMeta,
        precioBase.isAcceptableOrUnknown(data['precio_base']!, _precioBaseMeta),
      );
    } else if (isInserting) {
      context.missing(_precioBaseMeta);
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Plan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Plan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      velocidadMbps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}velocidad_mbps'],
      )!,
      precioBase: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}precio_base'],
      )!,
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
    );
  }

  @override
  $PlanesTable createAlias(String alias) {
    return $PlanesTable(attachedDatabase, alias);
  }
}

class Plan extends DataClass implements Insertable<Plan> {
  final int id;
  final String nombre;
  final int velocidadMbps;
  final int precioBase;
  final bool activo;
  const Plan({
    required this.id,
    required this.nombre,
    required this.velocidadMbps,
    required this.precioBase,
    required this.activo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    map['velocidad_mbps'] = Variable<int>(velocidadMbps);
    map['precio_base'] = Variable<int>(precioBase);
    map['activo'] = Variable<bool>(activo);
    return map;
  }

  PlanesCompanion toCompanion(bool nullToAbsent) {
    return PlanesCompanion(
      id: Value(id),
      nombre: Value(nombre),
      velocidadMbps: Value(velocidadMbps),
      precioBase: Value(precioBase),
      activo: Value(activo),
    );
  }

  factory Plan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Plan(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      velocidadMbps: serializer.fromJson<int>(json['velocidadMbps']),
      precioBase: serializer.fromJson<int>(json['precioBase']),
      activo: serializer.fromJson<bool>(json['activo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'velocidadMbps': serializer.toJson<int>(velocidadMbps),
      'precioBase': serializer.toJson<int>(precioBase),
      'activo': serializer.toJson<bool>(activo),
    };
  }

  Plan copyWith({
    int? id,
    String? nombre,
    int? velocidadMbps,
    int? precioBase,
    bool? activo,
  }) => Plan(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    velocidadMbps: velocidadMbps ?? this.velocidadMbps,
    precioBase: precioBase ?? this.precioBase,
    activo: activo ?? this.activo,
  );
  Plan copyWithCompanion(PlanesCompanion data) {
    return Plan(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      velocidadMbps: data.velocidadMbps.present
          ? data.velocidadMbps.value
          : this.velocidadMbps,
      precioBase: data.precioBase.present
          ? data.precioBase.value
          : this.precioBase,
      activo: data.activo.present ? data.activo.value : this.activo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Plan(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('velocidadMbps: $velocidadMbps, ')
          ..write('precioBase: $precioBase, ')
          ..write('activo: $activo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nombre, velocidadMbps, precioBase, activo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Plan &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.velocidadMbps == this.velocidadMbps &&
          other.precioBase == this.precioBase &&
          other.activo == this.activo);
}

class PlanesCompanion extends UpdateCompanion<Plan> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<int> velocidadMbps;
  final Value<int> precioBase;
  final Value<bool> activo;
  const PlanesCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.velocidadMbps = const Value.absent(),
    this.precioBase = const Value.absent(),
    this.activo = const Value.absent(),
  });
  PlanesCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    required int velocidadMbps,
    required int precioBase,
    this.activo = const Value.absent(),
  }) : nombre = Value(nombre),
       velocidadMbps = Value(velocidadMbps),
       precioBase = Value(precioBase);
  static Insertable<Plan> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<int>? velocidadMbps,
    Expression<int>? precioBase,
    Expression<bool>? activo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (velocidadMbps != null) 'velocidad_mbps': velocidadMbps,
      if (precioBase != null) 'precio_base': precioBase,
      if (activo != null) 'activo': activo,
    });
  }

  PlanesCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<int>? velocidadMbps,
    Value<int>? precioBase,
    Value<bool>? activo,
  }) {
    return PlanesCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      velocidadMbps: velocidadMbps ?? this.velocidadMbps,
      precioBase: precioBase ?? this.precioBase,
      activo: activo ?? this.activo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (velocidadMbps.present) {
      map['velocidad_mbps'] = Variable<int>(velocidadMbps.value);
    }
    if (precioBase.present) {
      map['precio_base'] = Variable<int>(precioBase.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanesCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('velocidadMbps: $velocidadMbps, ')
          ..write('precioBase: $precioBase, ')
          ..write('activo: $activo')
          ..write(')'))
        .toString();
  }
}

class $ClientesTable extends Clientes with TableInfo<$ClientesTable, Cliente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _telefonoMeta = const VerificationMeta(
    'telefono',
  );
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
    'telefono',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _direccionMeta = const VerificationMeta(
    'direccion',
  );
  @override
  late final GeneratedColumn<String> direccion = GeneratedColumn<String>(
    'direccion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _zonaMeta = const VerificationMeta('zona');
  @override
  late final GeneratedColumn<String> zona = GeneratedColumn<String>(
    'zona',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenciaMeta = const VerificationMeta(
    'referencia',
  );
  @override
  late final GeneratedColumn<String> referencia = GeneratedColumn<String>(
    'referencia',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES planes (id)',
    ),
  );
  static const VerificationMeta _precioMensualMeta = const VerificationMeta(
    'precioMensual',
  );
  @override
  late final GeneratedColumn<int> precioMensual = GeneratedColumn<int>(
    'precio_mensual',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diaCorteMeta = const VerificationMeta(
    'diaCorte',
  );
  @override
  late final GeneratedColumn<int> diaCorte = GeneratedColumn<int>(
    'dia_corte',
    aliasedName,
    false,
    check: () => ComparableExpr(diaCorte).isBetweenValues(1, 28),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoContratacion, String>
  tipoContratacion = GeneratedColumn<String>(
    'tipo_contratacion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<TipoContratacion>($ClientesTable.$convertertipoContratacion);
  static const VerificationMeta _fechaAltaMeta = const VerificationMeta(
    'fechaAlta',
  );
  @override
  late final GeneratedColumn<DateTime> fechaAlta = GeneratedColumn<DateTime>(
    'fecha_alta',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _primerMesCobroMeta = const VerificationMeta(
    'primerMesCobro',
  );
  @override
  late final GeneratedColumn<String> primerMesCobro = GeneratedColumn<String>(
    'primer_mes_cobro',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 7,
      maxTextLength: 7,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<EstadoCliente, String> estado =
      GeneratedColumn<String>(
        'estado',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(EstadoCliente.activo.name),
      ).withConverter<EstadoCliente>($ClientesTable.$converterestado);
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
    'notas',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    telefono,
    direccion,
    zona,
    referencia,
    planId,
    precioMensual,
    diaCorte,
    tipoContratacion,
    fechaAlta,
    primerMesCobro,
    estado,
    notas,
    creadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clientes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Cliente> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('telefono')) {
      context.handle(
        _telefonoMeta,
        telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta),
      );
    }
    if (data.containsKey('direccion')) {
      context.handle(
        _direccionMeta,
        direccion.isAcceptableOrUnknown(data['direccion']!, _direccionMeta),
      );
    }
    if (data.containsKey('zona')) {
      context.handle(
        _zonaMeta,
        zona.isAcceptableOrUnknown(data['zona']!, _zonaMeta),
      );
    }
    if (data.containsKey('referencia')) {
      context.handle(
        _referenciaMeta,
        referencia.isAcceptableOrUnknown(data['referencia']!, _referenciaMeta),
      );
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('precio_mensual')) {
      context.handle(
        _precioMensualMeta,
        precioMensual.isAcceptableOrUnknown(
          data['precio_mensual']!,
          _precioMensualMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precioMensualMeta);
    }
    if (data.containsKey('dia_corte')) {
      context.handle(
        _diaCorteMeta,
        diaCorte.isAcceptableOrUnknown(data['dia_corte']!, _diaCorteMeta),
      );
    } else if (isInserting) {
      context.missing(_diaCorteMeta);
    }
    if (data.containsKey('fecha_alta')) {
      context.handle(
        _fechaAltaMeta,
        fechaAlta.isAcceptableOrUnknown(data['fecha_alta']!, _fechaAltaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaAltaMeta);
    }
    if (data.containsKey('primer_mes_cobro')) {
      context.handle(
        _primerMesCobroMeta,
        primerMesCobro.isAcceptableOrUnknown(
          data['primer_mes_cobro']!,
          _primerMesCobroMeta,
        ),
      );
    }
    if (data.containsKey('notas')) {
      context.handle(
        _notasMeta,
        notas.isAcceptableOrUnknown(data['notas']!, _notasMeta),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cliente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cliente(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      telefono: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telefono'],
      ),
      direccion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direccion'],
      ),
      zona: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zona'],
      ),
      referencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}referencia'],
      ),
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_id'],
      )!,
      precioMensual: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}precio_mensual'],
      )!,
      diaCorte: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dia_corte'],
      )!,
      tipoContratacion: $ClientesTable.$convertertipoContratacion.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo_contratacion'],
        )!,
      ),
      fechaAlta: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_alta'],
      )!,
      primerMesCobro: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primer_mes_cobro'],
      ),
      estado: $ClientesTable.$converterestado.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}estado'],
        )!,
      ),
      notas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notas'],
      ),
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
    );
  }

  @override
  $ClientesTable createAlias(String alias) {
    return $ClientesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoContratacion, String, String>
  $convertertipoContratacion = const EnumNameConverter<TipoContratacion>(
    TipoContratacion.values,
  );
  static JsonTypeConverter2<EstadoCliente, String, String> $converterestado =
      const EnumNameConverter<EstadoCliente>(EstadoCliente.values);
}

class Cliente extends DataClass implements Insertable<Cliente> {
  final int id;
  final String nombre;
  final String? telefono;
  final String? direccion;
  final String? zona;
  final String? referencia;
  final int planId;
  final int precioMensual;
  final int diaCorte;
  final TipoContratacion tipoContratacion;
  final DateTime fechaAlta;

  /// Primer mes que se cobra, 'YYYY-MM' (puede ser el mes del alta, el siguiente u otro).
  /// Nullable solo por la migración; siempre se llena. Ver domain/vencimientos.dart.
  final String? primerMesCobro;
  final EstadoCliente estado;
  final String? notas;
  final DateTime creadoEn;
  const Cliente({
    required this.id,
    required this.nombre,
    this.telefono,
    this.direccion,
    this.zona,
    this.referencia,
    required this.planId,
    required this.precioMensual,
    required this.diaCorte,
    required this.tipoContratacion,
    required this.fechaAlta,
    this.primerMesCobro,
    required this.estado,
    this.notas,
    required this.creadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || telefono != null) {
      map['telefono'] = Variable<String>(telefono);
    }
    if (!nullToAbsent || direccion != null) {
      map['direccion'] = Variable<String>(direccion);
    }
    if (!nullToAbsent || zona != null) {
      map['zona'] = Variable<String>(zona);
    }
    if (!nullToAbsent || referencia != null) {
      map['referencia'] = Variable<String>(referencia);
    }
    map['plan_id'] = Variable<int>(planId);
    map['precio_mensual'] = Variable<int>(precioMensual);
    map['dia_corte'] = Variable<int>(diaCorte);
    {
      map['tipo_contratacion'] = Variable<String>(
        $ClientesTable.$convertertipoContratacion.toSql(tipoContratacion),
      );
    }
    map['fecha_alta'] = Variable<DateTime>(fechaAlta);
    if (!nullToAbsent || primerMesCobro != null) {
      map['primer_mes_cobro'] = Variable<String>(primerMesCobro);
    }
    {
      map['estado'] = Variable<String>(
        $ClientesTable.$converterestado.toSql(estado),
      );
    }
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    map['creado_en'] = Variable<DateTime>(creadoEn);
    return map;
  }

  ClientesCompanion toCompanion(bool nullToAbsent) {
    return ClientesCompanion(
      id: Value(id),
      nombre: Value(nombre),
      telefono: telefono == null && nullToAbsent
          ? const Value.absent()
          : Value(telefono),
      direccion: direccion == null && nullToAbsent
          ? const Value.absent()
          : Value(direccion),
      zona: zona == null && nullToAbsent ? const Value.absent() : Value(zona),
      referencia: referencia == null && nullToAbsent
          ? const Value.absent()
          : Value(referencia),
      planId: Value(planId),
      precioMensual: Value(precioMensual),
      diaCorte: Value(diaCorte),
      tipoContratacion: Value(tipoContratacion),
      fechaAlta: Value(fechaAlta),
      primerMesCobro: primerMesCobro == null && nullToAbsent
          ? const Value.absent()
          : Value(primerMesCobro),
      estado: Value(estado),
      notas: notas == null && nullToAbsent
          ? const Value.absent()
          : Value(notas),
      creadoEn: Value(creadoEn),
    );
  }

  factory Cliente.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cliente(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      telefono: serializer.fromJson<String?>(json['telefono']),
      direccion: serializer.fromJson<String?>(json['direccion']),
      zona: serializer.fromJson<String?>(json['zona']),
      referencia: serializer.fromJson<String?>(json['referencia']),
      planId: serializer.fromJson<int>(json['planId']),
      precioMensual: serializer.fromJson<int>(json['precioMensual']),
      diaCorte: serializer.fromJson<int>(json['diaCorte']),
      tipoContratacion: $ClientesTable.$convertertipoContratacion.fromJson(
        serializer.fromJson<String>(json['tipoContratacion']),
      ),
      fechaAlta: serializer.fromJson<DateTime>(json['fechaAlta']),
      primerMesCobro: serializer.fromJson<String?>(json['primerMesCobro']),
      estado: $ClientesTable.$converterestado.fromJson(
        serializer.fromJson<String>(json['estado']),
      ),
      notas: serializer.fromJson<String?>(json['notas']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'telefono': serializer.toJson<String?>(telefono),
      'direccion': serializer.toJson<String?>(direccion),
      'zona': serializer.toJson<String?>(zona),
      'referencia': serializer.toJson<String?>(referencia),
      'planId': serializer.toJson<int>(planId),
      'precioMensual': serializer.toJson<int>(precioMensual),
      'diaCorte': serializer.toJson<int>(diaCorte),
      'tipoContratacion': serializer.toJson<String>(
        $ClientesTable.$convertertipoContratacion.toJson(tipoContratacion),
      ),
      'fechaAlta': serializer.toJson<DateTime>(fechaAlta),
      'primerMesCobro': serializer.toJson<String?>(primerMesCobro),
      'estado': serializer.toJson<String>(
        $ClientesTable.$converterestado.toJson(estado),
      ),
      'notas': serializer.toJson<String?>(notas),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
    };
  }

  Cliente copyWith({
    int? id,
    String? nombre,
    Value<String?> telefono = const Value.absent(),
    Value<String?> direccion = const Value.absent(),
    Value<String?> zona = const Value.absent(),
    Value<String?> referencia = const Value.absent(),
    int? planId,
    int? precioMensual,
    int? diaCorte,
    TipoContratacion? tipoContratacion,
    DateTime? fechaAlta,
    Value<String?> primerMesCobro = const Value.absent(),
    EstadoCliente? estado,
    Value<String?> notas = const Value.absent(),
    DateTime? creadoEn,
  }) => Cliente(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    telefono: telefono.present ? telefono.value : this.telefono,
    direccion: direccion.present ? direccion.value : this.direccion,
    zona: zona.present ? zona.value : this.zona,
    referencia: referencia.present ? referencia.value : this.referencia,
    planId: planId ?? this.planId,
    precioMensual: precioMensual ?? this.precioMensual,
    diaCorte: diaCorte ?? this.diaCorte,
    tipoContratacion: tipoContratacion ?? this.tipoContratacion,
    fechaAlta: fechaAlta ?? this.fechaAlta,
    primerMesCobro: primerMesCobro.present
        ? primerMesCobro.value
        : this.primerMesCobro,
    estado: estado ?? this.estado,
    notas: notas.present ? notas.value : this.notas,
    creadoEn: creadoEn ?? this.creadoEn,
  );
  Cliente copyWithCompanion(ClientesCompanion data) {
    return Cliente(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
      direccion: data.direccion.present ? data.direccion.value : this.direccion,
      zona: data.zona.present ? data.zona.value : this.zona,
      referencia: data.referencia.present
          ? data.referencia.value
          : this.referencia,
      planId: data.planId.present ? data.planId.value : this.planId,
      precioMensual: data.precioMensual.present
          ? data.precioMensual.value
          : this.precioMensual,
      diaCorte: data.diaCorte.present ? data.diaCorte.value : this.diaCorte,
      tipoContratacion: data.tipoContratacion.present
          ? data.tipoContratacion.value
          : this.tipoContratacion,
      fechaAlta: data.fechaAlta.present ? data.fechaAlta.value : this.fechaAlta,
      primerMesCobro: data.primerMesCobro.present
          ? data.primerMesCobro.value
          : this.primerMesCobro,
      estado: data.estado.present ? data.estado.value : this.estado,
      notas: data.notas.present ? data.notas.value : this.notas,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cliente(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('telefono: $telefono, ')
          ..write('direccion: $direccion, ')
          ..write('zona: $zona, ')
          ..write('referencia: $referencia, ')
          ..write('planId: $planId, ')
          ..write('precioMensual: $precioMensual, ')
          ..write('diaCorte: $diaCorte, ')
          ..write('tipoContratacion: $tipoContratacion, ')
          ..write('fechaAlta: $fechaAlta, ')
          ..write('primerMesCobro: $primerMesCobro, ')
          ..write('estado: $estado, ')
          ..write('notas: $notas, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nombre,
    telefono,
    direccion,
    zona,
    referencia,
    planId,
    precioMensual,
    diaCorte,
    tipoContratacion,
    fechaAlta,
    primerMesCobro,
    estado,
    notas,
    creadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cliente &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.telefono == this.telefono &&
          other.direccion == this.direccion &&
          other.zona == this.zona &&
          other.referencia == this.referencia &&
          other.planId == this.planId &&
          other.precioMensual == this.precioMensual &&
          other.diaCorte == this.diaCorte &&
          other.tipoContratacion == this.tipoContratacion &&
          other.fechaAlta == this.fechaAlta &&
          other.primerMesCobro == this.primerMesCobro &&
          other.estado == this.estado &&
          other.notas == this.notas &&
          other.creadoEn == this.creadoEn);
}

class ClientesCompanion extends UpdateCompanion<Cliente> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String?> telefono;
  final Value<String?> direccion;
  final Value<String?> zona;
  final Value<String?> referencia;
  final Value<int> planId;
  final Value<int> precioMensual;
  final Value<int> diaCorte;
  final Value<TipoContratacion> tipoContratacion;
  final Value<DateTime> fechaAlta;
  final Value<String?> primerMesCobro;
  final Value<EstadoCliente> estado;
  final Value<String?> notas;
  final Value<DateTime> creadoEn;
  const ClientesCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.telefono = const Value.absent(),
    this.direccion = const Value.absent(),
    this.zona = const Value.absent(),
    this.referencia = const Value.absent(),
    this.planId = const Value.absent(),
    this.precioMensual = const Value.absent(),
    this.diaCorte = const Value.absent(),
    this.tipoContratacion = const Value.absent(),
    this.fechaAlta = const Value.absent(),
    this.primerMesCobro = const Value.absent(),
    this.estado = const Value.absent(),
    this.notas = const Value.absent(),
    this.creadoEn = const Value.absent(),
  });
  ClientesCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    this.telefono = const Value.absent(),
    this.direccion = const Value.absent(),
    this.zona = const Value.absent(),
    this.referencia = const Value.absent(),
    required int planId,
    required int precioMensual,
    required int diaCorte,
    required TipoContratacion tipoContratacion,
    required DateTime fechaAlta,
    this.primerMesCobro = const Value.absent(),
    this.estado = const Value.absent(),
    this.notas = const Value.absent(),
    this.creadoEn = const Value.absent(),
  }) : nombre = Value(nombre),
       planId = Value(planId),
       precioMensual = Value(precioMensual),
       diaCorte = Value(diaCorte),
       tipoContratacion = Value(tipoContratacion),
       fechaAlta = Value(fechaAlta);
  static Insertable<Cliente> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? telefono,
    Expression<String>? direccion,
    Expression<String>? zona,
    Expression<String>? referencia,
    Expression<int>? planId,
    Expression<int>? precioMensual,
    Expression<int>? diaCorte,
    Expression<String>? tipoContratacion,
    Expression<DateTime>? fechaAlta,
    Expression<String>? primerMesCobro,
    Expression<String>? estado,
    Expression<String>? notas,
    Expression<DateTime>? creadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (telefono != null) 'telefono': telefono,
      if (direccion != null) 'direccion': direccion,
      if (zona != null) 'zona': zona,
      if (referencia != null) 'referencia': referencia,
      if (planId != null) 'plan_id': planId,
      if (precioMensual != null) 'precio_mensual': precioMensual,
      if (diaCorte != null) 'dia_corte': diaCorte,
      if (tipoContratacion != null) 'tipo_contratacion': tipoContratacion,
      if (fechaAlta != null) 'fecha_alta': fechaAlta,
      if (primerMesCobro != null) 'primer_mes_cobro': primerMesCobro,
      if (estado != null) 'estado': estado,
      if (notas != null) 'notas': notas,
      if (creadoEn != null) 'creado_en': creadoEn,
    });
  }

  ClientesCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<String?>? telefono,
    Value<String?>? direccion,
    Value<String?>? zona,
    Value<String?>? referencia,
    Value<int>? planId,
    Value<int>? precioMensual,
    Value<int>? diaCorte,
    Value<TipoContratacion>? tipoContratacion,
    Value<DateTime>? fechaAlta,
    Value<String?>? primerMesCobro,
    Value<EstadoCliente>? estado,
    Value<String?>? notas,
    Value<DateTime>? creadoEn,
  }) {
    return ClientesCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      zona: zona ?? this.zona,
      referencia: referencia ?? this.referencia,
      planId: planId ?? this.planId,
      precioMensual: precioMensual ?? this.precioMensual,
      diaCorte: diaCorte ?? this.diaCorte,
      tipoContratacion: tipoContratacion ?? this.tipoContratacion,
      fechaAlta: fechaAlta ?? this.fechaAlta,
      primerMesCobro: primerMesCobro ?? this.primerMesCobro,
      estado: estado ?? this.estado,
      notas: notas ?? this.notas,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (direccion.present) {
      map['direccion'] = Variable<String>(direccion.value);
    }
    if (zona.present) {
      map['zona'] = Variable<String>(zona.value);
    }
    if (referencia.present) {
      map['referencia'] = Variable<String>(referencia.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (precioMensual.present) {
      map['precio_mensual'] = Variable<int>(precioMensual.value);
    }
    if (diaCorte.present) {
      map['dia_corte'] = Variable<int>(diaCorte.value);
    }
    if (tipoContratacion.present) {
      map['tipo_contratacion'] = Variable<String>(
        $ClientesTable.$convertertipoContratacion.toSql(tipoContratacion.value),
      );
    }
    if (fechaAlta.present) {
      map['fecha_alta'] = Variable<DateTime>(fechaAlta.value);
    }
    if (primerMesCobro.present) {
      map['primer_mes_cobro'] = Variable<String>(primerMesCobro.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(
        $ClientesTable.$converterestado.toSql(estado.value),
      );
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientesCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('telefono: $telefono, ')
          ..write('direccion: $direccion, ')
          ..write('zona: $zona, ')
          ..write('referencia: $referencia, ')
          ..write('planId: $planId, ')
          ..write('precioMensual: $precioMensual, ')
          ..write('diaCorte: $diaCorte, ')
          ..write('tipoContratacion: $tipoContratacion, ')
          ..write('fechaAlta: $fechaAlta, ')
          ..write('primerMesCobro: $primerMesCobro, ')
          ..write('estado: $estado, ')
          ..write('notas: $notas, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }
}

class $InstalacionesTable extends Instalaciones
    with TableInfo<$InstalacionesTable, Instalacion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstalacionesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _clienteIdMeta = const VerificationMeta(
    'clienteId',
  );
  @override
  late final GeneratedColumn<int> clienteId = GeneratedColumn<int>(
    'cliente_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clientes (id)',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costoMeta = const VerificationMeta('costo');
  @override
  late final GeneratedColumn<int> costo = GeneratedColumn<int>(
    'costo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pagadoMeta = const VerificationMeta('pagado');
  @override
  late final GeneratedColumn<bool> pagado = GeneratedColumn<bool>(
    'pagado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pagado" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _tecnicoMeta = const VerificationMeta(
    'tecnico',
  );
  @override
  late final GeneratedColumn<String> tecnico = GeneratedColumn<String>(
    'tecnico',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
    'notas',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clienteId,
    fecha,
    costo,
    pagado,
    tecnico,
    notas,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'instalaciones';
  @override
  VerificationContext validateIntegrity(
    Insertable<Instalacion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cliente_id')) {
      context.handle(
        _clienteIdMeta,
        clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clienteIdMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('costo')) {
      context.handle(
        _costoMeta,
        costo.isAcceptableOrUnknown(data['costo']!, _costoMeta),
      );
    }
    if (data.containsKey('pagado')) {
      context.handle(
        _pagadoMeta,
        pagado.isAcceptableOrUnknown(data['pagado']!, _pagadoMeta),
      );
    }
    if (data.containsKey('tecnico')) {
      context.handle(
        _tecnicoMeta,
        tecnico.isAcceptableOrUnknown(data['tecnico']!, _tecnicoMeta),
      );
    }
    if (data.containsKey('notas')) {
      context.handle(
        _notasMeta,
        notas.isAcceptableOrUnknown(data['notas']!, _notasMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Instalacion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Instalacion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clienteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cliente_id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      costo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}costo'],
      )!,
      pagado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pagado'],
      )!,
      tecnico: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tecnico'],
      ),
      notas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notas'],
      ),
    );
  }

  @override
  $InstalacionesTable createAlias(String alias) {
    return $InstalacionesTable(attachedDatabase, alias);
  }
}

class Instalacion extends DataClass implements Insertable<Instalacion> {
  final int id;
  final int clienteId;
  final DateTime fecha;
  final int costo;
  final bool pagado;
  final String? tecnico;
  final String? notas;
  const Instalacion({
    required this.id,
    required this.clienteId,
    required this.fecha,
    required this.costo,
    required this.pagado,
    this.tecnico,
    this.notas,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cliente_id'] = Variable<int>(clienteId);
    map['fecha'] = Variable<DateTime>(fecha);
    map['costo'] = Variable<int>(costo);
    map['pagado'] = Variable<bool>(pagado);
    if (!nullToAbsent || tecnico != null) {
      map['tecnico'] = Variable<String>(tecnico);
    }
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    return map;
  }

  InstalacionesCompanion toCompanion(bool nullToAbsent) {
    return InstalacionesCompanion(
      id: Value(id),
      clienteId: Value(clienteId),
      fecha: Value(fecha),
      costo: Value(costo),
      pagado: Value(pagado),
      tecnico: tecnico == null && nullToAbsent
          ? const Value.absent()
          : Value(tecnico),
      notas: notas == null && nullToAbsent
          ? const Value.absent()
          : Value(notas),
    );
  }

  factory Instalacion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Instalacion(
      id: serializer.fromJson<int>(json['id']),
      clienteId: serializer.fromJson<int>(json['clienteId']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      costo: serializer.fromJson<int>(json['costo']),
      pagado: serializer.fromJson<bool>(json['pagado']),
      tecnico: serializer.fromJson<String?>(json['tecnico']),
      notas: serializer.fromJson<String?>(json['notas']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clienteId': serializer.toJson<int>(clienteId),
      'fecha': serializer.toJson<DateTime>(fecha),
      'costo': serializer.toJson<int>(costo),
      'pagado': serializer.toJson<bool>(pagado),
      'tecnico': serializer.toJson<String?>(tecnico),
      'notas': serializer.toJson<String?>(notas),
    };
  }

  Instalacion copyWith({
    int? id,
    int? clienteId,
    DateTime? fecha,
    int? costo,
    bool? pagado,
    Value<String?> tecnico = const Value.absent(),
    Value<String?> notas = const Value.absent(),
  }) => Instalacion(
    id: id ?? this.id,
    clienteId: clienteId ?? this.clienteId,
    fecha: fecha ?? this.fecha,
    costo: costo ?? this.costo,
    pagado: pagado ?? this.pagado,
    tecnico: tecnico.present ? tecnico.value : this.tecnico,
    notas: notas.present ? notas.value : this.notas,
  );
  Instalacion copyWithCompanion(InstalacionesCompanion data) {
    return Instalacion(
      id: data.id.present ? data.id.value : this.id,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      costo: data.costo.present ? data.costo.value : this.costo,
      pagado: data.pagado.present ? data.pagado.value : this.pagado,
      tecnico: data.tecnico.present ? data.tecnico.value : this.tecnico,
      notas: data.notas.present ? data.notas.value : this.notas,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Instalacion(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('fecha: $fecha, ')
          ..write('costo: $costo, ')
          ..write('pagado: $pagado, ')
          ..write('tecnico: $tecnico, ')
          ..write('notas: $notas')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, clienteId, fecha, costo, pagado, tecnico, notas);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Instalacion &&
          other.id == this.id &&
          other.clienteId == this.clienteId &&
          other.fecha == this.fecha &&
          other.costo == this.costo &&
          other.pagado == this.pagado &&
          other.tecnico == this.tecnico &&
          other.notas == this.notas);
}

class InstalacionesCompanion extends UpdateCompanion<Instalacion> {
  final Value<int> id;
  final Value<int> clienteId;
  final Value<DateTime> fecha;
  final Value<int> costo;
  final Value<bool> pagado;
  final Value<String?> tecnico;
  final Value<String?> notas;
  const InstalacionesCompanion({
    this.id = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.costo = const Value.absent(),
    this.pagado = const Value.absent(),
    this.tecnico = const Value.absent(),
    this.notas = const Value.absent(),
  });
  InstalacionesCompanion.insert({
    this.id = const Value.absent(),
    required int clienteId,
    required DateTime fecha,
    this.costo = const Value.absent(),
    this.pagado = const Value.absent(),
    this.tecnico = const Value.absent(),
    this.notas = const Value.absent(),
  }) : clienteId = Value(clienteId),
       fecha = Value(fecha);
  static Insertable<Instalacion> custom({
    Expression<int>? id,
    Expression<int>? clienteId,
    Expression<DateTime>? fecha,
    Expression<int>? costo,
    Expression<bool>? pagado,
    Expression<String>? tecnico,
    Expression<String>? notas,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clienteId != null) 'cliente_id': clienteId,
      if (fecha != null) 'fecha': fecha,
      if (costo != null) 'costo': costo,
      if (pagado != null) 'pagado': pagado,
      if (tecnico != null) 'tecnico': tecnico,
      if (notas != null) 'notas': notas,
    });
  }

  InstalacionesCompanion copyWith({
    Value<int>? id,
    Value<int>? clienteId,
    Value<DateTime>? fecha,
    Value<int>? costo,
    Value<bool>? pagado,
    Value<String?>? tecnico,
    Value<String?>? notas,
  }) {
    return InstalacionesCompanion(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      fecha: fecha ?? this.fecha,
      costo: costo ?? this.costo,
      pagado: pagado ?? this.pagado,
      tecnico: tecnico ?? this.tecnico,
      notas: notas ?? this.notas,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<int>(clienteId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (costo.present) {
      map['costo'] = Variable<int>(costo.value);
    }
    if (pagado.present) {
      map['pagado'] = Variable<bool>(pagado.value);
    }
    if (tecnico.present) {
      map['tecnico'] = Variable<String>(tecnico.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstalacionesCompanion(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('fecha: $fecha, ')
          ..write('costo: $costo, ')
          ..write('pagado: $pagado, ')
          ..write('tecnico: $tecnico, ')
          ..write('notas: $notas')
          ..write(')'))
        .toString();
  }
}

class $EquiposTable extends Equipos with TableInfo<$EquiposTable, Equipo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EquiposTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _clienteIdMeta = const VerificationMeta(
    'clienteId',
  );
  @override
  late final GeneratedColumn<int> clienteId = GeneratedColumn<int>(
    'cliente_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clientes (id)',
    ),
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marcaModeloMeta = const VerificationMeta(
    'marcaModelo',
  );
  @override
  late final GeneratedColumn<String> marcaModelo = GeneratedColumn<String>(
    'marca_modelo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _numeroSerieMeta = const VerificationMeta(
    'numeroSerie',
  );
  @override
  late final GeneratedColumn<String> numeroSerie = GeneratedColumn<String>(
    'numero_serie',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PropiedadEquipo, String>
  propiedad = GeneratedColumn<String>(
    'propiedad',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<PropiedadEquipo>($EquiposTable.$converterpropiedad);
  static const VerificationMeta _costoMeta = const VerificationMeta('costo');
  @override
  late final GeneratedColumn<int> costo = GeneratedColumn<int>(
    'costo',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaEntregaMeta = const VerificationMeta(
    'fechaEntrega',
  );
  @override
  late final GeneratedColumn<DateTime> fechaEntrega = GeneratedColumn<DateTime>(
    'fecha_entrega',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaRetiroMeta = const VerificationMeta(
    'fechaRetiro',
  );
  @override
  late final GeneratedColumn<DateTime> fechaRetiro = GeneratedColumn<DateTime>(
    'fecha_retiro',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
    'notas',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clienteId,
    tipo,
    marcaModelo,
    numeroSerie,
    propiedad,
    costo,
    fechaEntrega,
    fechaRetiro,
    notas,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'equipos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Equipo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cliente_id')) {
      context.handle(
        _clienteIdMeta,
        clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta),
      );
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('marca_modelo')) {
      context.handle(
        _marcaModeloMeta,
        marcaModelo.isAcceptableOrUnknown(
          data['marca_modelo']!,
          _marcaModeloMeta,
        ),
      );
    }
    if (data.containsKey('numero_serie')) {
      context.handle(
        _numeroSerieMeta,
        numeroSerie.isAcceptableOrUnknown(
          data['numero_serie']!,
          _numeroSerieMeta,
        ),
      );
    }
    if (data.containsKey('costo')) {
      context.handle(
        _costoMeta,
        costo.isAcceptableOrUnknown(data['costo']!, _costoMeta),
      );
    }
    if (data.containsKey('fecha_entrega')) {
      context.handle(
        _fechaEntregaMeta,
        fechaEntrega.isAcceptableOrUnknown(
          data['fecha_entrega']!,
          _fechaEntregaMeta,
        ),
      );
    }
    if (data.containsKey('fecha_retiro')) {
      context.handle(
        _fechaRetiroMeta,
        fechaRetiro.isAcceptableOrUnknown(
          data['fecha_retiro']!,
          _fechaRetiroMeta,
        ),
      );
    }
    if (data.containsKey('notas')) {
      context.handle(
        _notasMeta,
        notas.isAcceptableOrUnknown(data['notas']!, _notasMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Equipo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Equipo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clienteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cliente_id'],
      ),
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      marcaModelo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marca_modelo'],
      ),
      numeroSerie: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}numero_serie'],
      ),
      propiedad: $EquiposTable.$converterpropiedad.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}propiedad'],
        )!,
      ),
      costo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}costo'],
      ),
      fechaEntrega: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_entrega'],
      ),
      fechaRetiro: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_retiro'],
      ),
      notas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notas'],
      ),
    );
  }

  @override
  $EquiposTable createAlias(String alias) {
    return $EquiposTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PropiedadEquipo, String, String>
  $converterpropiedad = const EnumNameConverter<PropiedadEquipo>(
    PropiedadEquipo.values,
  );
}

class Equipo extends DataClass implements Insertable<Equipo> {
  final int id;

  /// null = equipo en bodega.
  final int? clienteId;
  final String tipo;
  final String? marcaModelo;
  final String? numeroSerie;
  final PropiedadEquipo propiedad;
  final int? costo;
  final DateTime? fechaEntrega;
  final DateTime? fechaRetiro;
  final String? notas;
  const Equipo({
    required this.id,
    this.clienteId,
    required this.tipo,
    this.marcaModelo,
    this.numeroSerie,
    required this.propiedad,
    this.costo,
    this.fechaEntrega,
    this.fechaRetiro,
    this.notas,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || clienteId != null) {
      map['cliente_id'] = Variable<int>(clienteId);
    }
    map['tipo'] = Variable<String>(tipo);
    if (!nullToAbsent || marcaModelo != null) {
      map['marca_modelo'] = Variable<String>(marcaModelo);
    }
    if (!nullToAbsent || numeroSerie != null) {
      map['numero_serie'] = Variable<String>(numeroSerie);
    }
    {
      map['propiedad'] = Variable<String>(
        $EquiposTable.$converterpropiedad.toSql(propiedad),
      );
    }
    if (!nullToAbsent || costo != null) {
      map['costo'] = Variable<int>(costo);
    }
    if (!nullToAbsent || fechaEntrega != null) {
      map['fecha_entrega'] = Variable<DateTime>(fechaEntrega);
    }
    if (!nullToAbsent || fechaRetiro != null) {
      map['fecha_retiro'] = Variable<DateTime>(fechaRetiro);
    }
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    return map;
  }

  EquiposCompanion toCompanion(bool nullToAbsent) {
    return EquiposCompanion(
      id: Value(id),
      clienteId: clienteId == null && nullToAbsent
          ? const Value.absent()
          : Value(clienteId),
      tipo: Value(tipo),
      marcaModelo: marcaModelo == null && nullToAbsent
          ? const Value.absent()
          : Value(marcaModelo),
      numeroSerie: numeroSerie == null && nullToAbsent
          ? const Value.absent()
          : Value(numeroSerie),
      propiedad: Value(propiedad),
      costo: costo == null && nullToAbsent
          ? const Value.absent()
          : Value(costo),
      fechaEntrega: fechaEntrega == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaEntrega),
      fechaRetiro: fechaRetiro == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaRetiro),
      notas: notas == null && nullToAbsent
          ? const Value.absent()
          : Value(notas),
    );
  }

  factory Equipo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Equipo(
      id: serializer.fromJson<int>(json['id']),
      clienteId: serializer.fromJson<int?>(json['clienteId']),
      tipo: serializer.fromJson<String>(json['tipo']),
      marcaModelo: serializer.fromJson<String?>(json['marcaModelo']),
      numeroSerie: serializer.fromJson<String?>(json['numeroSerie']),
      propiedad: $EquiposTable.$converterpropiedad.fromJson(
        serializer.fromJson<String>(json['propiedad']),
      ),
      costo: serializer.fromJson<int?>(json['costo']),
      fechaEntrega: serializer.fromJson<DateTime?>(json['fechaEntrega']),
      fechaRetiro: serializer.fromJson<DateTime?>(json['fechaRetiro']),
      notas: serializer.fromJson<String?>(json['notas']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clienteId': serializer.toJson<int?>(clienteId),
      'tipo': serializer.toJson<String>(tipo),
      'marcaModelo': serializer.toJson<String?>(marcaModelo),
      'numeroSerie': serializer.toJson<String?>(numeroSerie),
      'propiedad': serializer.toJson<String>(
        $EquiposTable.$converterpropiedad.toJson(propiedad),
      ),
      'costo': serializer.toJson<int?>(costo),
      'fechaEntrega': serializer.toJson<DateTime?>(fechaEntrega),
      'fechaRetiro': serializer.toJson<DateTime?>(fechaRetiro),
      'notas': serializer.toJson<String?>(notas),
    };
  }

  Equipo copyWith({
    int? id,
    Value<int?> clienteId = const Value.absent(),
    String? tipo,
    Value<String?> marcaModelo = const Value.absent(),
    Value<String?> numeroSerie = const Value.absent(),
    PropiedadEquipo? propiedad,
    Value<int?> costo = const Value.absent(),
    Value<DateTime?> fechaEntrega = const Value.absent(),
    Value<DateTime?> fechaRetiro = const Value.absent(),
    Value<String?> notas = const Value.absent(),
  }) => Equipo(
    id: id ?? this.id,
    clienteId: clienteId.present ? clienteId.value : this.clienteId,
    tipo: tipo ?? this.tipo,
    marcaModelo: marcaModelo.present ? marcaModelo.value : this.marcaModelo,
    numeroSerie: numeroSerie.present ? numeroSerie.value : this.numeroSerie,
    propiedad: propiedad ?? this.propiedad,
    costo: costo.present ? costo.value : this.costo,
    fechaEntrega: fechaEntrega.present ? fechaEntrega.value : this.fechaEntrega,
    fechaRetiro: fechaRetiro.present ? fechaRetiro.value : this.fechaRetiro,
    notas: notas.present ? notas.value : this.notas,
  );
  Equipo copyWithCompanion(EquiposCompanion data) {
    return Equipo(
      id: data.id.present ? data.id.value : this.id,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      marcaModelo: data.marcaModelo.present
          ? data.marcaModelo.value
          : this.marcaModelo,
      numeroSerie: data.numeroSerie.present
          ? data.numeroSerie.value
          : this.numeroSerie,
      propiedad: data.propiedad.present ? data.propiedad.value : this.propiedad,
      costo: data.costo.present ? data.costo.value : this.costo,
      fechaEntrega: data.fechaEntrega.present
          ? data.fechaEntrega.value
          : this.fechaEntrega,
      fechaRetiro: data.fechaRetiro.present
          ? data.fechaRetiro.value
          : this.fechaRetiro,
      notas: data.notas.present ? data.notas.value : this.notas,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Equipo(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('tipo: $tipo, ')
          ..write('marcaModelo: $marcaModelo, ')
          ..write('numeroSerie: $numeroSerie, ')
          ..write('propiedad: $propiedad, ')
          ..write('costo: $costo, ')
          ..write('fechaEntrega: $fechaEntrega, ')
          ..write('fechaRetiro: $fechaRetiro, ')
          ..write('notas: $notas')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clienteId,
    tipo,
    marcaModelo,
    numeroSerie,
    propiedad,
    costo,
    fechaEntrega,
    fechaRetiro,
    notas,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Equipo &&
          other.id == this.id &&
          other.clienteId == this.clienteId &&
          other.tipo == this.tipo &&
          other.marcaModelo == this.marcaModelo &&
          other.numeroSerie == this.numeroSerie &&
          other.propiedad == this.propiedad &&
          other.costo == this.costo &&
          other.fechaEntrega == this.fechaEntrega &&
          other.fechaRetiro == this.fechaRetiro &&
          other.notas == this.notas);
}

class EquiposCompanion extends UpdateCompanion<Equipo> {
  final Value<int> id;
  final Value<int?> clienteId;
  final Value<String> tipo;
  final Value<String?> marcaModelo;
  final Value<String?> numeroSerie;
  final Value<PropiedadEquipo> propiedad;
  final Value<int?> costo;
  final Value<DateTime?> fechaEntrega;
  final Value<DateTime?> fechaRetiro;
  final Value<String?> notas;
  const EquiposCompanion({
    this.id = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.marcaModelo = const Value.absent(),
    this.numeroSerie = const Value.absent(),
    this.propiedad = const Value.absent(),
    this.costo = const Value.absent(),
    this.fechaEntrega = const Value.absent(),
    this.fechaRetiro = const Value.absent(),
    this.notas = const Value.absent(),
  });
  EquiposCompanion.insert({
    this.id = const Value.absent(),
    this.clienteId = const Value.absent(),
    required String tipo,
    this.marcaModelo = const Value.absent(),
    this.numeroSerie = const Value.absent(),
    required PropiedadEquipo propiedad,
    this.costo = const Value.absent(),
    this.fechaEntrega = const Value.absent(),
    this.fechaRetiro = const Value.absent(),
    this.notas = const Value.absent(),
  }) : tipo = Value(tipo),
       propiedad = Value(propiedad);
  static Insertable<Equipo> custom({
    Expression<int>? id,
    Expression<int>? clienteId,
    Expression<String>? tipo,
    Expression<String>? marcaModelo,
    Expression<String>? numeroSerie,
    Expression<String>? propiedad,
    Expression<int>? costo,
    Expression<DateTime>? fechaEntrega,
    Expression<DateTime>? fechaRetiro,
    Expression<String>? notas,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clienteId != null) 'cliente_id': clienteId,
      if (tipo != null) 'tipo': tipo,
      if (marcaModelo != null) 'marca_modelo': marcaModelo,
      if (numeroSerie != null) 'numero_serie': numeroSerie,
      if (propiedad != null) 'propiedad': propiedad,
      if (costo != null) 'costo': costo,
      if (fechaEntrega != null) 'fecha_entrega': fechaEntrega,
      if (fechaRetiro != null) 'fecha_retiro': fechaRetiro,
      if (notas != null) 'notas': notas,
    });
  }

  EquiposCompanion copyWith({
    Value<int>? id,
    Value<int?>? clienteId,
    Value<String>? tipo,
    Value<String?>? marcaModelo,
    Value<String?>? numeroSerie,
    Value<PropiedadEquipo>? propiedad,
    Value<int?>? costo,
    Value<DateTime?>? fechaEntrega,
    Value<DateTime?>? fechaRetiro,
    Value<String?>? notas,
  }) {
    return EquiposCompanion(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      tipo: tipo ?? this.tipo,
      marcaModelo: marcaModelo ?? this.marcaModelo,
      numeroSerie: numeroSerie ?? this.numeroSerie,
      propiedad: propiedad ?? this.propiedad,
      costo: costo ?? this.costo,
      fechaEntrega: fechaEntrega ?? this.fechaEntrega,
      fechaRetiro: fechaRetiro ?? this.fechaRetiro,
      notas: notas ?? this.notas,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<int>(clienteId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (marcaModelo.present) {
      map['marca_modelo'] = Variable<String>(marcaModelo.value);
    }
    if (numeroSerie.present) {
      map['numero_serie'] = Variable<String>(numeroSerie.value);
    }
    if (propiedad.present) {
      map['propiedad'] = Variable<String>(
        $EquiposTable.$converterpropiedad.toSql(propiedad.value),
      );
    }
    if (costo.present) {
      map['costo'] = Variable<int>(costo.value);
    }
    if (fechaEntrega.present) {
      map['fecha_entrega'] = Variable<DateTime>(fechaEntrega.value);
    }
    if (fechaRetiro.present) {
      map['fecha_retiro'] = Variable<DateTime>(fechaRetiro.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EquiposCompanion(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('tipo: $tipo, ')
          ..write('marcaModelo: $marcaModelo, ')
          ..write('numeroSerie: $numeroSerie, ')
          ..write('propiedad: $propiedad, ')
          ..write('costo: $costo, ')
          ..write('fechaEntrega: $fechaEntrega, ')
          ..write('fechaRetiro: $fechaRetiro, ')
          ..write('notas: $notas')
          ..write(')'))
        .toString();
  }
}

class $PeriodosTable extends Periodos
    with TableInfo<$PeriodosTable, PeriodoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeriodosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _clienteIdMeta = const VerificationMeta(
    'clienteId',
  );
  @override
  late final GeneratedColumn<int> clienteId = GeneratedColumn<int>(
    'cliente_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clientes (id)',
    ),
  );
  static const VerificationMeta _mesMeta = const VerificationMeta('mes');
  @override
  late final GeneratedColumn<String> mes = GeneratedColumn<String>(
    'mes',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 7,
      maxTextLength: 7,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaVencimientoMeta = const VerificationMeta(
    'fechaVencimiento',
  );
  @override
  late final GeneratedColumn<DateTime> fechaVencimiento =
      GeneratedColumn<DateTime>(
        'fecha_vencimiento',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<int> monto = GeneratedColumn<int>(
    'monto',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _esCortesiaMeta = const VerificationMeta(
    'esCortesia',
  );
  @override
  late final GeneratedColumn<bool> esCortesia = GeneratedColumn<bool>(
    'es_cortesia',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("es_cortesia" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clienteId,
    mes,
    fechaVencimiento,
    monto,
    esCortesia,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'periodos';
  @override
  VerificationContext validateIntegrity(
    Insertable<PeriodoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cliente_id')) {
      context.handle(
        _clienteIdMeta,
        clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clienteIdMeta);
    }
    if (data.containsKey('mes')) {
      context.handle(
        _mesMeta,
        mes.isAcceptableOrUnknown(data['mes']!, _mesMeta),
      );
    } else if (isInserting) {
      context.missing(_mesMeta);
    }
    if (data.containsKey('fecha_vencimiento')) {
      context.handle(
        _fechaVencimientoMeta,
        fechaVencimiento.isAcceptableOrUnknown(
          data['fecha_vencimiento']!,
          _fechaVencimientoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaVencimientoMeta);
    }
    if (data.containsKey('monto')) {
      context.handle(
        _montoMeta,
        monto.isAcceptableOrUnknown(data['monto']!, _montoMeta),
      );
    } else if (isInserting) {
      context.missing(_montoMeta);
    }
    if (data.containsKey('es_cortesia')) {
      context.handle(
        _esCortesiaMeta,
        esCortesia.isAcceptableOrUnknown(data['es_cortesia']!, _esCortesiaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {clienteId, mes},
  ];
  @override
  PeriodoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PeriodoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clienteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cliente_id'],
      )!,
      mes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mes'],
      )!,
      fechaVencimiento: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_vencimiento'],
      )!,
      monto: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monto'],
      )!,
      esCortesia: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}es_cortesia'],
      )!,
    );
  }

  @override
  $PeriodosTable createAlias(String alias) {
    return $PeriodosTable(attachedDatabase, alias);
  }
}

class PeriodoRow extends DataClass implements Insertable<PeriodoRow> {
  final int id;
  final int clienteId;

  /// Formato 'YYYY-MM' (ver core/mes.dart).
  final String mes;
  final DateTime fechaVencimiento;

  /// Copia del precio del cliente al momento de generarse.
  final int monto;
  final bool esCortesia;
  const PeriodoRow({
    required this.id,
    required this.clienteId,
    required this.mes,
    required this.fechaVencimiento,
    required this.monto,
    required this.esCortesia,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cliente_id'] = Variable<int>(clienteId);
    map['mes'] = Variable<String>(mes);
    map['fecha_vencimiento'] = Variable<DateTime>(fechaVencimiento);
    map['monto'] = Variable<int>(monto);
    map['es_cortesia'] = Variable<bool>(esCortesia);
    return map;
  }

  PeriodosCompanion toCompanion(bool nullToAbsent) {
    return PeriodosCompanion(
      id: Value(id),
      clienteId: Value(clienteId),
      mes: Value(mes),
      fechaVencimiento: Value(fechaVencimiento),
      monto: Value(monto),
      esCortesia: Value(esCortesia),
    );
  }

  factory PeriodoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PeriodoRow(
      id: serializer.fromJson<int>(json['id']),
      clienteId: serializer.fromJson<int>(json['clienteId']),
      mes: serializer.fromJson<String>(json['mes']),
      fechaVencimiento: serializer.fromJson<DateTime>(json['fechaVencimiento']),
      monto: serializer.fromJson<int>(json['monto']),
      esCortesia: serializer.fromJson<bool>(json['esCortesia']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clienteId': serializer.toJson<int>(clienteId),
      'mes': serializer.toJson<String>(mes),
      'fechaVencimiento': serializer.toJson<DateTime>(fechaVencimiento),
      'monto': serializer.toJson<int>(monto),
      'esCortesia': serializer.toJson<bool>(esCortesia),
    };
  }

  PeriodoRow copyWith({
    int? id,
    int? clienteId,
    String? mes,
    DateTime? fechaVencimiento,
    int? monto,
    bool? esCortesia,
  }) => PeriodoRow(
    id: id ?? this.id,
    clienteId: clienteId ?? this.clienteId,
    mes: mes ?? this.mes,
    fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
    monto: monto ?? this.monto,
    esCortesia: esCortesia ?? this.esCortesia,
  );
  PeriodoRow copyWithCompanion(PeriodosCompanion data) {
    return PeriodoRow(
      id: data.id.present ? data.id.value : this.id,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      mes: data.mes.present ? data.mes.value : this.mes,
      fechaVencimiento: data.fechaVencimiento.present
          ? data.fechaVencimiento.value
          : this.fechaVencimiento,
      monto: data.monto.present ? data.monto.value : this.monto,
      esCortesia: data.esCortesia.present
          ? data.esCortesia.value
          : this.esCortesia,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PeriodoRow(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('mes: $mes, ')
          ..write('fechaVencimiento: $fechaVencimiento, ')
          ..write('monto: $monto, ')
          ..write('esCortesia: $esCortesia')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, clienteId, mes, fechaVencimiento, monto, esCortesia);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PeriodoRow &&
          other.id == this.id &&
          other.clienteId == this.clienteId &&
          other.mes == this.mes &&
          other.fechaVencimiento == this.fechaVencimiento &&
          other.monto == this.monto &&
          other.esCortesia == this.esCortesia);
}

class PeriodosCompanion extends UpdateCompanion<PeriodoRow> {
  final Value<int> id;
  final Value<int> clienteId;
  final Value<String> mes;
  final Value<DateTime> fechaVencimiento;
  final Value<int> monto;
  final Value<bool> esCortesia;
  const PeriodosCompanion({
    this.id = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.mes = const Value.absent(),
    this.fechaVencimiento = const Value.absent(),
    this.monto = const Value.absent(),
    this.esCortesia = const Value.absent(),
  });
  PeriodosCompanion.insert({
    this.id = const Value.absent(),
    required int clienteId,
    required String mes,
    required DateTime fechaVencimiento,
    required int monto,
    this.esCortesia = const Value.absent(),
  }) : clienteId = Value(clienteId),
       mes = Value(mes),
       fechaVencimiento = Value(fechaVencimiento),
       monto = Value(monto);
  static Insertable<PeriodoRow> custom({
    Expression<int>? id,
    Expression<int>? clienteId,
    Expression<String>? mes,
    Expression<DateTime>? fechaVencimiento,
    Expression<int>? monto,
    Expression<bool>? esCortesia,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clienteId != null) 'cliente_id': clienteId,
      if (mes != null) 'mes': mes,
      if (fechaVencimiento != null) 'fecha_vencimiento': fechaVencimiento,
      if (monto != null) 'monto': monto,
      if (esCortesia != null) 'es_cortesia': esCortesia,
    });
  }

  PeriodosCompanion copyWith({
    Value<int>? id,
    Value<int>? clienteId,
    Value<String>? mes,
    Value<DateTime>? fechaVencimiento,
    Value<int>? monto,
    Value<bool>? esCortesia,
  }) {
    return PeriodosCompanion(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      mes: mes ?? this.mes,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      monto: monto ?? this.monto,
      esCortesia: esCortesia ?? this.esCortesia,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<int>(clienteId.value);
    }
    if (mes.present) {
      map['mes'] = Variable<String>(mes.value);
    }
    if (fechaVencimiento.present) {
      map['fecha_vencimiento'] = Variable<DateTime>(fechaVencimiento.value);
    }
    if (monto.present) {
      map['monto'] = Variable<int>(monto.value);
    }
    if (esCortesia.present) {
      map['es_cortesia'] = Variable<bool>(esCortesia.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeriodosCompanion(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('mes: $mes, ')
          ..write('fechaVencimiento: $fechaVencimiento, ')
          ..write('monto: $monto, ')
          ..write('esCortesia: $esCortesia')
          ..write(')'))
        .toString();
  }
}

class $PagosTable extends Pagos with TableInfo<$PagosTable, Pago> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PagosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _clienteIdMeta = const VerificationMeta(
    'clienteId',
  );
  @override
  late final GeneratedColumn<int> clienteId = GeneratedColumn<int>(
    'cliente_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clientes (id)',
    ),
  );
  static const VerificationMeta _fechaPagoMeta = const VerificationMeta(
    'fechaPago',
  );
  @override
  late final GeneratedColumn<DateTime> fechaPago = GeneratedColumn<DateTime>(
    'fecha_pago',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<int> monto = GeneratedColumn<int>(
    'monto',
    aliasedName,
    false,
    check: () => ComparableExpr(monto).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MetodoPago, String> metodo =
      GeneratedColumn<String>(
        'metodo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MetodoPago>($PagosTable.$convertermetodo);
  static const VerificationMeta _folioMeta = const VerificationMeta('folio');
  @override
  late final GeneratedColumn<String> folio = GeneratedColumn<String>(
    'folio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _registradoPorMeta = const VerificationMeta(
    'registradoPor',
  );
  @override
  late final GeneratedColumn<int> registradoPor = GeneratedColumn<int>(
    'registrado_por',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES usuarios (id)',
    ),
  );
  static const VerificationMeta _canceladoMeta = const VerificationMeta(
    'cancelado',
  );
  @override
  late final GeneratedColumn<bool> cancelado = GeneratedColumn<bool>(
    'cancelado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("cancelado" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
    'notas',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clienteId,
    fechaPago,
    monto,
    metodo,
    folio,
    registradoPor,
    cancelado,
    notas,
    creadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pagos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Pago> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cliente_id')) {
      context.handle(
        _clienteIdMeta,
        clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clienteIdMeta);
    }
    if (data.containsKey('fecha_pago')) {
      context.handle(
        _fechaPagoMeta,
        fechaPago.isAcceptableOrUnknown(data['fecha_pago']!, _fechaPagoMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaPagoMeta);
    }
    if (data.containsKey('monto')) {
      context.handle(
        _montoMeta,
        monto.isAcceptableOrUnknown(data['monto']!, _montoMeta),
      );
    } else if (isInserting) {
      context.missing(_montoMeta);
    }
    if (data.containsKey('folio')) {
      context.handle(
        _folioMeta,
        folio.isAcceptableOrUnknown(data['folio']!, _folioMeta),
      );
    }
    if (data.containsKey('registrado_por')) {
      context.handle(
        _registradoPorMeta,
        registradoPor.isAcceptableOrUnknown(
          data['registrado_por']!,
          _registradoPorMeta,
        ),
      );
    }
    if (data.containsKey('cancelado')) {
      context.handle(
        _canceladoMeta,
        cancelado.isAcceptableOrUnknown(data['cancelado']!, _canceladoMeta),
      );
    }
    if (data.containsKey('notas')) {
      context.handle(
        _notasMeta,
        notas.isAcceptableOrUnknown(data['notas']!, _notasMeta),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pago map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pago(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clienteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cliente_id'],
      )!,
      fechaPago: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_pago'],
      )!,
      monto: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monto'],
      )!,
      metodo: $PagosTable.$convertermetodo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}metodo'],
        )!,
      ),
      folio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folio'],
      ),
      registradoPor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}registrado_por'],
      ),
      cancelado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}cancelado'],
      )!,
      notas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notas'],
      ),
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
    );
  }

  @override
  $PagosTable createAlias(String alias) {
    return $PagosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MetodoPago, String, String> $convertermetodo =
      const EnumNameConverter<MetodoPago>(MetodoPago.values);
}

class Pago extends DataClass implements Insertable<Pago> {
  final int id;
  final int clienteId;
  final DateTime fechaPago;
  final int monto;
  final MetodoPago metodo;
  final String? folio;
  final int? registradoPor;
  final bool cancelado;
  final String? notas;
  final DateTime creadoEn;
  const Pago({
    required this.id,
    required this.clienteId,
    required this.fechaPago,
    required this.monto,
    required this.metodo,
    this.folio,
    this.registradoPor,
    required this.cancelado,
    this.notas,
    required this.creadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cliente_id'] = Variable<int>(clienteId);
    map['fecha_pago'] = Variable<DateTime>(fechaPago);
    map['monto'] = Variable<int>(monto);
    {
      map['metodo'] = Variable<String>(
        $PagosTable.$convertermetodo.toSql(metodo),
      );
    }
    if (!nullToAbsent || folio != null) {
      map['folio'] = Variable<String>(folio);
    }
    if (!nullToAbsent || registradoPor != null) {
      map['registrado_por'] = Variable<int>(registradoPor);
    }
    map['cancelado'] = Variable<bool>(cancelado);
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    map['creado_en'] = Variable<DateTime>(creadoEn);
    return map;
  }

  PagosCompanion toCompanion(bool nullToAbsent) {
    return PagosCompanion(
      id: Value(id),
      clienteId: Value(clienteId),
      fechaPago: Value(fechaPago),
      monto: Value(monto),
      metodo: Value(metodo),
      folio: folio == null && nullToAbsent
          ? const Value.absent()
          : Value(folio),
      registradoPor: registradoPor == null && nullToAbsent
          ? const Value.absent()
          : Value(registradoPor),
      cancelado: Value(cancelado),
      notas: notas == null && nullToAbsent
          ? const Value.absent()
          : Value(notas),
      creadoEn: Value(creadoEn),
    );
  }

  factory Pago.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pago(
      id: serializer.fromJson<int>(json['id']),
      clienteId: serializer.fromJson<int>(json['clienteId']),
      fechaPago: serializer.fromJson<DateTime>(json['fechaPago']),
      monto: serializer.fromJson<int>(json['monto']),
      metodo: $PagosTable.$convertermetodo.fromJson(
        serializer.fromJson<String>(json['metodo']),
      ),
      folio: serializer.fromJson<String?>(json['folio']),
      registradoPor: serializer.fromJson<int?>(json['registradoPor']),
      cancelado: serializer.fromJson<bool>(json['cancelado']),
      notas: serializer.fromJson<String?>(json['notas']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clienteId': serializer.toJson<int>(clienteId),
      'fechaPago': serializer.toJson<DateTime>(fechaPago),
      'monto': serializer.toJson<int>(monto),
      'metodo': serializer.toJson<String>(
        $PagosTable.$convertermetodo.toJson(metodo),
      ),
      'folio': serializer.toJson<String?>(folio),
      'registradoPor': serializer.toJson<int?>(registradoPor),
      'cancelado': serializer.toJson<bool>(cancelado),
      'notas': serializer.toJson<String?>(notas),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
    };
  }

  Pago copyWith({
    int? id,
    int? clienteId,
    DateTime? fechaPago,
    int? monto,
    MetodoPago? metodo,
    Value<String?> folio = const Value.absent(),
    Value<int?> registradoPor = const Value.absent(),
    bool? cancelado,
    Value<String?> notas = const Value.absent(),
    DateTime? creadoEn,
  }) => Pago(
    id: id ?? this.id,
    clienteId: clienteId ?? this.clienteId,
    fechaPago: fechaPago ?? this.fechaPago,
    monto: monto ?? this.monto,
    metodo: metodo ?? this.metodo,
    folio: folio.present ? folio.value : this.folio,
    registradoPor: registradoPor.present
        ? registradoPor.value
        : this.registradoPor,
    cancelado: cancelado ?? this.cancelado,
    notas: notas.present ? notas.value : this.notas,
    creadoEn: creadoEn ?? this.creadoEn,
  );
  Pago copyWithCompanion(PagosCompanion data) {
    return Pago(
      id: data.id.present ? data.id.value : this.id,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      fechaPago: data.fechaPago.present ? data.fechaPago.value : this.fechaPago,
      monto: data.monto.present ? data.monto.value : this.monto,
      metodo: data.metodo.present ? data.metodo.value : this.metodo,
      folio: data.folio.present ? data.folio.value : this.folio,
      registradoPor: data.registradoPor.present
          ? data.registradoPor.value
          : this.registradoPor,
      cancelado: data.cancelado.present ? data.cancelado.value : this.cancelado,
      notas: data.notas.present ? data.notas.value : this.notas,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pago(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('fechaPago: $fechaPago, ')
          ..write('monto: $monto, ')
          ..write('metodo: $metodo, ')
          ..write('folio: $folio, ')
          ..write('registradoPor: $registradoPor, ')
          ..write('cancelado: $cancelado, ')
          ..write('notas: $notas, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clienteId,
    fechaPago,
    monto,
    metodo,
    folio,
    registradoPor,
    cancelado,
    notas,
    creadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pago &&
          other.id == this.id &&
          other.clienteId == this.clienteId &&
          other.fechaPago == this.fechaPago &&
          other.monto == this.monto &&
          other.metodo == this.metodo &&
          other.folio == this.folio &&
          other.registradoPor == this.registradoPor &&
          other.cancelado == this.cancelado &&
          other.notas == this.notas &&
          other.creadoEn == this.creadoEn);
}

class PagosCompanion extends UpdateCompanion<Pago> {
  final Value<int> id;
  final Value<int> clienteId;
  final Value<DateTime> fechaPago;
  final Value<int> monto;
  final Value<MetodoPago> metodo;
  final Value<String?> folio;
  final Value<int?> registradoPor;
  final Value<bool> cancelado;
  final Value<String?> notas;
  final Value<DateTime> creadoEn;
  const PagosCompanion({
    this.id = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.fechaPago = const Value.absent(),
    this.monto = const Value.absent(),
    this.metodo = const Value.absent(),
    this.folio = const Value.absent(),
    this.registradoPor = const Value.absent(),
    this.cancelado = const Value.absent(),
    this.notas = const Value.absent(),
    this.creadoEn = const Value.absent(),
  });
  PagosCompanion.insert({
    this.id = const Value.absent(),
    required int clienteId,
    required DateTime fechaPago,
    required int monto,
    required MetodoPago metodo,
    this.folio = const Value.absent(),
    this.registradoPor = const Value.absent(),
    this.cancelado = const Value.absent(),
    this.notas = const Value.absent(),
    this.creadoEn = const Value.absent(),
  }) : clienteId = Value(clienteId),
       fechaPago = Value(fechaPago),
       monto = Value(monto),
       metodo = Value(metodo);
  static Insertable<Pago> custom({
    Expression<int>? id,
    Expression<int>? clienteId,
    Expression<DateTime>? fechaPago,
    Expression<int>? monto,
    Expression<String>? metodo,
    Expression<String>? folio,
    Expression<int>? registradoPor,
    Expression<bool>? cancelado,
    Expression<String>? notas,
    Expression<DateTime>? creadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clienteId != null) 'cliente_id': clienteId,
      if (fechaPago != null) 'fecha_pago': fechaPago,
      if (monto != null) 'monto': monto,
      if (metodo != null) 'metodo': metodo,
      if (folio != null) 'folio': folio,
      if (registradoPor != null) 'registrado_por': registradoPor,
      if (cancelado != null) 'cancelado': cancelado,
      if (notas != null) 'notas': notas,
      if (creadoEn != null) 'creado_en': creadoEn,
    });
  }

  PagosCompanion copyWith({
    Value<int>? id,
    Value<int>? clienteId,
    Value<DateTime>? fechaPago,
    Value<int>? monto,
    Value<MetodoPago>? metodo,
    Value<String?>? folio,
    Value<int?>? registradoPor,
    Value<bool>? cancelado,
    Value<String?>? notas,
    Value<DateTime>? creadoEn,
  }) {
    return PagosCompanion(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      fechaPago: fechaPago ?? this.fechaPago,
      monto: monto ?? this.monto,
      metodo: metodo ?? this.metodo,
      folio: folio ?? this.folio,
      registradoPor: registradoPor ?? this.registradoPor,
      cancelado: cancelado ?? this.cancelado,
      notas: notas ?? this.notas,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<int>(clienteId.value);
    }
    if (fechaPago.present) {
      map['fecha_pago'] = Variable<DateTime>(fechaPago.value);
    }
    if (monto.present) {
      map['monto'] = Variable<int>(monto.value);
    }
    if (metodo.present) {
      map['metodo'] = Variable<String>(
        $PagosTable.$convertermetodo.toSql(metodo.value),
      );
    }
    if (folio.present) {
      map['folio'] = Variable<String>(folio.value);
    }
    if (registradoPor.present) {
      map['registrado_por'] = Variable<int>(registradoPor.value);
    }
    if (cancelado.present) {
      map['cancelado'] = Variable<bool>(cancelado.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PagosCompanion(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('fechaPago: $fechaPago, ')
          ..write('monto: $monto, ')
          ..write('metodo: $metodo, ')
          ..write('folio: $folio, ')
          ..write('registradoPor: $registradoPor, ')
          ..write('cancelado: $cancelado, ')
          ..write('notas: $notas, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }
}

class $PagoAplicacionesTable extends PagoAplicaciones
    with TableInfo<$PagoAplicacionesTable, PagoAplicacion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PagoAplicacionesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pagoIdMeta = const VerificationMeta('pagoId');
  @override
  late final GeneratedColumn<int> pagoId = GeneratedColumn<int>(
    'pago_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pagos (id)',
    ),
  );
  static const VerificationMeta _periodoIdMeta = const VerificationMeta(
    'periodoId',
  );
  @override
  late final GeneratedColumn<int> periodoId = GeneratedColumn<int>(
    'periodo_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES periodos (id)',
    ),
  );
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<int> monto = GeneratedColumn<int>(
    'monto',
    aliasedName,
    false,
    check: () => ComparableExpr(monto).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [pagoId, periodoId, monto];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pago_aplicaciones';
  @override
  VerificationContext validateIntegrity(
    Insertable<PagoAplicacion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pago_id')) {
      context.handle(
        _pagoIdMeta,
        pagoId.isAcceptableOrUnknown(data['pago_id']!, _pagoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pagoIdMeta);
    }
    if (data.containsKey('periodo_id')) {
      context.handle(
        _periodoIdMeta,
        periodoId.isAcceptableOrUnknown(data['periodo_id']!, _periodoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_periodoIdMeta);
    }
    if (data.containsKey('monto')) {
      context.handle(
        _montoMeta,
        monto.isAcceptableOrUnknown(data['monto']!, _montoMeta),
      );
    } else if (isInserting) {
      context.missing(_montoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pagoId, periodoId};
  @override
  PagoAplicacion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PagoAplicacion(
      pagoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pago_id'],
      )!,
      periodoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}periodo_id'],
      )!,
      monto: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monto'],
      )!,
    );
  }

  @override
  $PagoAplicacionesTable createAlias(String alias) {
    return $PagoAplicacionesTable(attachedDatabase, alias);
  }
}

class PagoAplicacion extends DataClass implements Insertable<PagoAplicacion> {
  final int pagoId;
  final int periodoId;
  final int monto;
  const PagoAplicacion({
    required this.pagoId,
    required this.periodoId,
    required this.monto,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pago_id'] = Variable<int>(pagoId);
    map['periodo_id'] = Variable<int>(periodoId);
    map['monto'] = Variable<int>(monto);
    return map;
  }

  PagoAplicacionesCompanion toCompanion(bool nullToAbsent) {
    return PagoAplicacionesCompanion(
      pagoId: Value(pagoId),
      periodoId: Value(periodoId),
      monto: Value(monto),
    );
  }

  factory PagoAplicacion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PagoAplicacion(
      pagoId: serializer.fromJson<int>(json['pagoId']),
      periodoId: serializer.fromJson<int>(json['periodoId']),
      monto: serializer.fromJson<int>(json['monto']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pagoId': serializer.toJson<int>(pagoId),
      'periodoId': serializer.toJson<int>(periodoId),
      'monto': serializer.toJson<int>(monto),
    };
  }

  PagoAplicacion copyWith({int? pagoId, int? periodoId, int? monto}) =>
      PagoAplicacion(
        pagoId: pagoId ?? this.pagoId,
        periodoId: periodoId ?? this.periodoId,
        monto: monto ?? this.monto,
      );
  PagoAplicacion copyWithCompanion(PagoAplicacionesCompanion data) {
    return PagoAplicacion(
      pagoId: data.pagoId.present ? data.pagoId.value : this.pagoId,
      periodoId: data.periodoId.present ? data.periodoId.value : this.periodoId,
      monto: data.monto.present ? data.monto.value : this.monto,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PagoAplicacion(')
          ..write('pagoId: $pagoId, ')
          ..write('periodoId: $periodoId, ')
          ..write('monto: $monto')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pagoId, periodoId, monto);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PagoAplicacion &&
          other.pagoId == this.pagoId &&
          other.periodoId == this.periodoId &&
          other.monto == this.monto);
}

class PagoAplicacionesCompanion extends UpdateCompanion<PagoAplicacion> {
  final Value<int> pagoId;
  final Value<int> periodoId;
  final Value<int> monto;
  final Value<int> rowid;
  const PagoAplicacionesCompanion({
    this.pagoId = const Value.absent(),
    this.periodoId = const Value.absent(),
    this.monto = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PagoAplicacionesCompanion.insert({
    required int pagoId,
    required int periodoId,
    required int monto,
    this.rowid = const Value.absent(),
  }) : pagoId = Value(pagoId),
       periodoId = Value(periodoId),
       monto = Value(monto);
  static Insertable<PagoAplicacion> custom({
    Expression<int>? pagoId,
    Expression<int>? periodoId,
    Expression<int>? monto,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pagoId != null) 'pago_id': pagoId,
      if (periodoId != null) 'periodo_id': periodoId,
      if (monto != null) 'monto': monto,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PagoAplicacionesCompanion copyWith({
    Value<int>? pagoId,
    Value<int>? periodoId,
    Value<int>? monto,
    Value<int>? rowid,
  }) {
    return PagoAplicacionesCompanion(
      pagoId: pagoId ?? this.pagoId,
      periodoId: periodoId ?? this.periodoId,
      monto: monto ?? this.monto,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pagoId.present) {
      map['pago_id'] = Variable<int>(pagoId.value);
    }
    if (periodoId.present) {
      map['periodo_id'] = Variable<int>(periodoId.value);
    }
    if (monto.present) {
      map['monto'] = Variable<int>(monto.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PagoAplicacionesCompanion(')
          ..write('pagoId: $pagoId, ')
          ..write('periodoId: $periodoId, ')
          ..write('monto: $monto, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CargosTable extends Cargos with TableInfo<$CargosTable, Cargo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CargosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _clienteIdMeta = const VerificationMeta(
    'clienteId',
  );
  @override
  late final GeneratedColumn<int> clienteId = GeneratedColumn<int>(
    'cliente_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clientes (id)',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conceptoMeta = const VerificationMeta(
    'concepto',
  );
  @override
  late final GeneratedColumn<String> concepto = GeneratedColumn<String>(
    'concepto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<int> monto = GeneratedColumn<int>(
    'monto',
    aliasedName,
    false,
    check: () => ComparableExpr(monto).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipoIdMeta = const VerificationMeta(
    'equipoId',
  );
  @override
  late final GeneratedColumn<int> equipoId = GeneratedColumn<int>(
    'equipo_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES equipos (id)',
    ),
  );
  static const VerificationMeta _canceladoMeta = const VerificationMeta(
    'cancelado',
  );
  @override
  late final GeneratedColumn<bool> cancelado = GeneratedColumn<bool>(
    'cancelado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("cancelado" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
    'notas',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clienteId,
    fecha,
    concepto,
    monto,
    equipoId,
    cancelado,
    notas,
    creadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cargos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Cargo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cliente_id')) {
      context.handle(
        _clienteIdMeta,
        clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clienteIdMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('concepto')) {
      context.handle(
        _conceptoMeta,
        concepto.isAcceptableOrUnknown(data['concepto']!, _conceptoMeta),
      );
    } else if (isInserting) {
      context.missing(_conceptoMeta);
    }
    if (data.containsKey('monto')) {
      context.handle(
        _montoMeta,
        monto.isAcceptableOrUnknown(data['monto']!, _montoMeta),
      );
    } else if (isInserting) {
      context.missing(_montoMeta);
    }
    if (data.containsKey('equipo_id')) {
      context.handle(
        _equipoIdMeta,
        equipoId.isAcceptableOrUnknown(data['equipo_id']!, _equipoIdMeta),
      );
    }
    if (data.containsKey('cancelado')) {
      context.handle(
        _canceladoMeta,
        cancelado.isAcceptableOrUnknown(data['cancelado']!, _canceladoMeta),
      );
    }
    if (data.containsKey('notas')) {
      context.handle(
        _notasMeta,
        notas.isAcceptableOrUnknown(data['notas']!, _notasMeta),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadoEnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cargo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cargo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clienteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cliente_id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      concepto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concepto'],
      )!,
      monto: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monto'],
      )!,
      equipoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}equipo_id'],
      ),
      cancelado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}cancelado'],
      )!,
      notas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notas'],
      ),
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
    );
  }

  @override
  $CargosTable createAlias(String alias) {
    return $CargosTable(attachedDatabase, alias);
  }
}

class Cargo extends DataClass implements Insertable<Cargo> {
  final int id;
  final int clienteId;
  final DateTime fecha;
  final String concepto;
  final int monto;

  /// Equipo relacionado (si el cargo es por equipo no devuelto).
  final int? equipoId;
  final bool cancelado;
  final String? notas;
  final DateTime creadoEn;
  const Cargo({
    required this.id,
    required this.clienteId,
    required this.fecha,
    required this.concepto,
    required this.monto,
    this.equipoId,
    required this.cancelado,
    this.notas,
    required this.creadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cliente_id'] = Variable<int>(clienteId);
    map['fecha'] = Variable<DateTime>(fecha);
    map['concepto'] = Variable<String>(concepto);
    map['monto'] = Variable<int>(monto);
    if (!nullToAbsent || equipoId != null) {
      map['equipo_id'] = Variable<int>(equipoId);
    }
    map['cancelado'] = Variable<bool>(cancelado);
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    map['creado_en'] = Variable<DateTime>(creadoEn);
    return map;
  }

  CargosCompanion toCompanion(bool nullToAbsent) {
    return CargosCompanion(
      id: Value(id),
      clienteId: Value(clienteId),
      fecha: Value(fecha),
      concepto: Value(concepto),
      monto: Value(monto),
      equipoId: equipoId == null && nullToAbsent
          ? const Value.absent()
          : Value(equipoId),
      cancelado: Value(cancelado),
      notas: notas == null && nullToAbsent
          ? const Value.absent()
          : Value(notas),
      creadoEn: Value(creadoEn),
    );
  }

  factory Cargo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cargo(
      id: serializer.fromJson<int>(json['id']),
      clienteId: serializer.fromJson<int>(json['clienteId']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      concepto: serializer.fromJson<String>(json['concepto']),
      monto: serializer.fromJson<int>(json['monto']),
      equipoId: serializer.fromJson<int?>(json['equipoId']),
      cancelado: serializer.fromJson<bool>(json['cancelado']),
      notas: serializer.fromJson<String?>(json['notas']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clienteId': serializer.toJson<int>(clienteId),
      'fecha': serializer.toJson<DateTime>(fecha),
      'concepto': serializer.toJson<String>(concepto),
      'monto': serializer.toJson<int>(monto),
      'equipoId': serializer.toJson<int?>(equipoId),
      'cancelado': serializer.toJson<bool>(cancelado),
      'notas': serializer.toJson<String?>(notas),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
    };
  }

  Cargo copyWith({
    int? id,
    int? clienteId,
    DateTime? fecha,
    String? concepto,
    int? monto,
    Value<int?> equipoId = const Value.absent(),
    bool? cancelado,
    Value<String?> notas = const Value.absent(),
    DateTime? creadoEn,
  }) => Cargo(
    id: id ?? this.id,
    clienteId: clienteId ?? this.clienteId,
    fecha: fecha ?? this.fecha,
    concepto: concepto ?? this.concepto,
    monto: monto ?? this.monto,
    equipoId: equipoId.present ? equipoId.value : this.equipoId,
    cancelado: cancelado ?? this.cancelado,
    notas: notas.present ? notas.value : this.notas,
    creadoEn: creadoEn ?? this.creadoEn,
  );
  Cargo copyWithCompanion(CargosCompanion data) {
    return Cargo(
      id: data.id.present ? data.id.value : this.id,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      concepto: data.concepto.present ? data.concepto.value : this.concepto,
      monto: data.monto.present ? data.monto.value : this.monto,
      equipoId: data.equipoId.present ? data.equipoId.value : this.equipoId,
      cancelado: data.cancelado.present ? data.cancelado.value : this.cancelado,
      notas: data.notas.present ? data.notas.value : this.notas,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cargo(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('fecha: $fecha, ')
          ..write('concepto: $concepto, ')
          ..write('monto: $monto, ')
          ..write('equipoId: $equipoId, ')
          ..write('cancelado: $cancelado, ')
          ..write('notas: $notas, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clienteId,
    fecha,
    concepto,
    monto,
    equipoId,
    cancelado,
    notas,
    creadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cargo &&
          other.id == this.id &&
          other.clienteId == this.clienteId &&
          other.fecha == this.fecha &&
          other.concepto == this.concepto &&
          other.monto == this.monto &&
          other.equipoId == this.equipoId &&
          other.cancelado == this.cancelado &&
          other.notas == this.notas &&
          other.creadoEn == this.creadoEn);
}

class CargosCompanion extends UpdateCompanion<Cargo> {
  final Value<int> id;
  final Value<int> clienteId;
  final Value<DateTime> fecha;
  final Value<String> concepto;
  final Value<int> monto;
  final Value<int?> equipoId;
  final Value<bool> cancelado;
  final Value<String?> notas;
  final Value<DateTime> creadoEn;
  const CargosCompanion({
    this.id = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.concepto = const Value.absent(),
    this.monto = const Value.absent(),
    this.equipoId = const Value.absent(),
    this.cancelado = const Value.absent(),
    this.notas = const Value.absent(),
    this.creadoEn = const Value.absent(),
  });
  CargosCompanion.insert({
    this.id = const Value.absent(),
    required int clienteId,
    required DateTime fecha,
    required String concepto,
    required int monto,
    this.equipoId = const Value.absent(),
    this.cancelado = const Value.absent(),
    this.notas = const Value.absent(),
    required DateTime creadoEn,
  }) : clienteId = Value(clienteId),
       fecha = Value(fecha),
       concepto = Value(concepto),
       monto = Value(monto),
       creadoEn = Value(creadoEn);
  static Insertable<Cargo> custom({
    Expression<int>? id,
    Expression<int>? clienteId,
    Expression<DateTime>? fecha,
    Expression<String>? concepto,
    Expression<int>? monto,
    Expression<int>? equipoId,
    Expression<bool>? cancelado,
    Expression<String>? notas,
    Expression<DateTime>? creadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clienteId != null) 'cliente_id': clienteId,
      if (fecha != null) 'fecha': fecha,
      if (concepto != null) 'concepto': concepto,
      if (monto != null) 'monto': monto,
      if (equipoId != null) 'equipo_id': equipoId,
      if (cancelado != null) 'cancelado': cancelado,
      if (notas != null) 'notas': notas,
      if (creadoEn != null) 'creado_en': creadoEn,
    });
  }

  CargosCompanion copyWith({
    Value<int>? id,
    Value<int>? clienteId,
    Value<DateTime>? fecha,
    Value<String>? concepto,
    Value<int>? monto,
    Value<int?>? equipoId,
    Value<bool>? cancelado,
    Value<String?>? notas,
    Value<DateTime>? creadoEn,
  }) {
    return CargosCompanion(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      fecha: fecha ?? this.fecha,
      concepto: concepto ?? this.concepto,
      monto: monto ?? this.monto,
      equipoId: equipoId ?? this.equipoId,
      cancelado: cancelado ?? this.cancelado,
      notas: notas ?? this.notas,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<int>(clienteId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (concepto.present) {
      map['concepto'] = Variable<String>(concepto.value);
    }
    if (monto.present) {
      map['monto'] = Variable<int>(monto.value);
    }
    if (equipoId.present) {
      map['equipo_id'] = Variable<int>(equipoId.value);
    }
    if (cancelado.present) {
      map['cancelado'] = Variable<bool>(cancelado.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CargosCompanion(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('fecha: $fecha, ')
          ..write('concepto: $concepto, ')
          ..write('monto: $monto, ')
          ..write('equipoId: $equipoId, ')
          ..write('cancelado: $cancelado, ')
          ..write('notas: $notas, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }
}

class $CargoAplicacionesTable extends CargoAplicaciones
    with TableInfo<$CargoAplicacionesTable, CargoAplicacion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CargoAplicacionesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pagoIdMeta = const VerificationMeta('pagoId');
  @override
  late final GeneratedColumn<int> pagoId = GeneratedColumn<int>(
    'pago_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pagos (id)',
    ),
  );
  static const VerificationMeta _cargoIdMeta = const VerificationMeta(
    'cargoId',
  );
  @override
  late final GeneratedColumn<int> cargoId = GeneratedColumn<int>(
    'cargo_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cargos (id)',
    ),
  );
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<int> monto = GeneratedColumn<int>(
    'monto',
    aliasedName,
    false,
    check: () => ComparableExpr(monto).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [pagoId, cargoId, monto];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cargo_aplicaciones';
  @override
  VerificationContext validateIntegrity(
    Insertable<CargoAplicacion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pago_id')) {
      context.handle(
        _pagoIdMeta,
        pagoId.isAcceptableOrUnknown(data['pago_id']!, _pagoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pagoIdMeta);
    }
    if (data.containsKey('cargo_id')) {
      context.handle(
        _cargoIdMeta,
        cargoId.isAcceptableOrUnknown(data['cargo_id']!, _cargoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cargoIdMeta);
    }
    if (data.containsKey('monto')) {
      context.handle(
        _montoMeta,
        monto.isAcceptableOrUnknown(data['monto']!, _montoMeta),
      );
    } else if (isInserting) {
      context.missing(_montoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pagoId, cargoId};
  @override
  CargoAplicacion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CargoAplicacion(
      pagoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pago_id'],
      )!,
      cargoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cargo_id'],
      )!,
      monto: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monto'],
      )!,
    );
  }

  @override
  $CargoAplicacionesTable createAlias(String alias) {
    return $CargoAplicacionesTable(attachedDatabase, alias);
  }
}

class CargoAplicacion extends DataClass implements Insertable<CargoAplicacion> {
  final int pagoId;
  final int cargoId;
  final int monto;
  const CargoAplicacion({
    required this.pagoId,
    required this.cargoId,
    required this.monto,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pago_id'] = Variable<int>(pagoId);
    map['cargo_id'] = Variable<int>(cargoId);
    map['monto'] = Variable<int>(monto);
    return map;
  }

  CargoAplicacionesCompanion toCompanion(bool nullToAbsent) {
    return CargoAplicacionesCompanion(
      pagoId: Value(pagoId),
      cargoId: Value(cargoId),
      monto: Value(monto),
    );
  }

  factory CargoAplicacion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CargoAplicacion(
      pagoId: serializer.fromJson<int>(json['pagoId']),
      cargoId: serializer.fromJson<int>(json['cargoId']),
      monto: serializer.fromJson<int>(json['monto']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pagoId': serializer.toJson<int>(pagoId),
      'cargoId': serializer.toJson<int>(cargoId),
      'monto': serializer.toJson<int>(monto),
    };
  }

  CargoAplicacion copyWith({int? pagoId, int? cargoId, int? monto}) =>
      CargoAplicacion(
        pagoId: pagoId ?? this.pagoId,
        cargoId: cargoId ?? this.cargoId,
        monto: monto ?? this.monto,
      );
  CargoAplicacion copyWithCompanion(CargoAplicacionesCompanion data) {
    return CargoAplicacion(
      pagoId: data.pagoId.present ? data.pagoId.value : this.pagoId,
      cargoId: data.cargoId.present ? data.cargoId.value : this.cargoId,
      monto: data.monto.present ? data.monto.value : this.monto,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CargoAplicacion(')
          ..write('pagoId: $pagoId, ')
          ..write('cargoId: $cargoId, ')
          ..write('monto: $monto')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pagoId, cargoId, monto);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CargoAplicacion &&
          other.pagoId == this.pagoId &&
          other.cargoId == this.cargoId &&
          other.monto == this.monto);
}

class CargoAplicacionesCompanion extends UpdateCompanion<CargoAplicacion> {
  final Value<int> pagoId;
  final Value<int> cargoId;
  final Value<int> monto;
  final Value<int> rowid;
  const CargoAplicacionesCompanion({
    this.pagoId = const Value.absent(),
    this.cargoId = const Value.absent(),
    this.monto = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CargoAplicacionesCompanion.insert({
    required int pagoId,
    required int cargoId,
    required int monto,
    this.rowid = const Value.absent(),
  }) : pagoId = Value(pagoId),
       cargoId = Value(cargoId),
       monto = Value(monto);
  static Insertable<CargoAplicacion> custom({
    Expression<int>? pagoId,
    Expression<int>? cargoId,
    Expression<int>? monto,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pagoId != null) 'pago_id': pagoId,
      if (cargoId != null) 'cargo_id': cargoId,
      if (monto != null) 'monto': monto,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CargoAplicacionesCompanion copyWith({
    Value<int>? pagoId,
    Value<int>? cargoId,
    Value<int>? monto,
    Value<int>? rowid,
  }) {
    return CargoAplicacionesCompanion(
      pagoId: pagoId ?? this.pagoId,
      cargoId: cargoId ?? this.cargoId,
      monto: monto ?? this.monto,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pagoId.present) {
      map['pago_id'] = Variable<int>(pagoId.value);
    }
    if (cargoId.present) {
      map['cargo_id'] = Variable<int>(cargoId.value);
    }
    if (monto.present) {
      map['monto'] = Variable<int>(monto.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CargoAplicacionesCompanion(')
          ..write('pagoId: $pagoId, ')
          ..write('cargoId: $cargoId, ')
          ..write('monto: $monto, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HistorialEstadosTable extends HistorialEstados
    with TableInfo<$HistorialEstadosTable, HistorialEstado> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistorialEstadosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _clienteIdMeta = const VerificationMeta(
    'clienteId',
  );
  @override
  late final GeneratedColumn<int> clienteId = GeneratedColumn<int>(
    'cliente_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clientes (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<EstadoCliente?, String>
  estadoAnterior =
      GeneratedColumn<String>(
        'estado_anterior',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<EstadoCliente?>(
        $HistorialEstadosTable.$converterestadoAnteriorn,
      );
  @override
  late final GeneratedColumnWithTypeConverter<EstadoCliente, String>
  estadoNuevo = GeneratedColumn<String>(
    'estado_nuevo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<EstadoCliente>($HistorialEstadosTable.$converterestadoNuevo);
  static const VerificationMeta _motivoMeta = const VerificationMeta('motivo');
  @override
  late final GeneratedColumn<String> motivo = GeneratedColumn<String>(
    'motivo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usuarioIdMeta = const VerificationMeta(
    'usuarioId',
  );
  @override
  late final GeneratedColumn<int> usuarioId = GeneratedColumn<int>(
    'usuario_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES usuarios (id)',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clienteId,
    estadoAnterior,
    estadoNuevo,
    motivo,
    usuarioId,
    fecha,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'historial_estados';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistorialEstado> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cliente_id')) {
      context.handle(
        _clienteIdMeta,
        clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clienteIdMeta);
    }
    if (data.containsKey('motivo')) {
      context.handle(
        _motivoMeta,
        motivo.isAcceptableOrUnknown(data['motivo']!, _motivoMeta),
      );
    }
    if (data.containsKey('usuario_id')) {
      context.handle(
        _usuarioIdMeta,
        usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta),
      );
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistorialEstado map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistorialEstado(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clienteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cliente_id'],
      )!,
      estadoAnterior: $HistorialEstadosTable.$converterestadoAnteriorn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}estado_anterior'],
        ),
      ),
      estadoNuevo: $HistorialEstadosTable.$converterestadoNuevo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}estado_nuevo'],
        )!,
      ),
      motivo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}motivo'],
      ),
      usuarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}usuario_id'],
      ),
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
    );
  }

  @override
  $HistorialEstadosTable createAlias(String alias) {
    return $HistorialEstadosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EstadoCliente, String, String>
  $converterestadoAnterior = const EnumNameConverter<EstadoCliente>(
    EstadoCliente.values,
  );
  static JsonTypeConverter2<EstadoCliente?, String?, String?>
  $converterestadoAnteriorn = JsonTypeConverter2.asNullable(
    $converterestadoAnterior,
  );
  static JsonTypeConverter2<EstadoCliente, String, String>
  $converterestadoNuevo = const EnumNameConverter<EstadoCliente>(
    EstadoCliente.values,
  );
}

class HistorialEstado extends DataClass implements Insertable<HistorialEstado> {
  final int id;
  final int clienteId;
  final EstadoCliente? estadoAnterior;
  final EstadoCliente estadoNuevo;
  final String? motivo;
  final int? usuarioId;
  final DateTime fecha;
  const HistorialEstado({
    required this.id,
    required this.clienteId,
    this.estadoAnterior,
    required this.estadoNuevo,
    this.motivo,
    this.usuarioId,
    required this.fecha,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cliente_id'] = Variable<int>(clienteId);
    if (!nullToAbsent || estadoAnterior != null) {
      map['estado_anterior'] = Variable<String>(
        $HistorialEstadosTable.$converterestadoAnteriorn.toSql(estadoAnterior),
      );
    }
    {
      map['estado_nuevo'] = Variable<String>(
        $HistorialEstadosTable.$converterestadoNuevo.toSql(estadoNuevo),
      );
    }
    if (!nullToAbsent || motivo != null) {
      map['motivo'] = Variable<String>(motivo);
    }
    if (!nullToAbsent || usuarioId != null) {
      map['usuario_id'] = Variable<int>(usuarioId);
    }
    map['fecha'] = Variable<DateTime>(fecha);
    return map;
  }

  HistorialEstadosCompanion toCompanion(bool nullToAbsent) {
    return HistorialEstadosCompanion(
      id: Value(id),
      clienteId: Value(clienteId),
      estadoAnterior: estadoAnterior == null && nullToAbsent
          ? const Value.absent()
          : Value(estadoAnterior),
      estadoNuevo: Value(estadoNuevo),
      motivo: motivo == null && nullToAbsent
          ? const Value.absent()
          : Value(motivo),
      usuarioId: usuarioId == null && nullToAbsent
          ? const Value.absent()
          : Value(usuarioId),
      fecha: Value(fecha),
    );
  }

  factory HistorialEstado.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistorialEstado(
      id: serializer.fromJson<int>(json['id']),
      clienteId: serializer.fromJson<int>(json['clienteId']),
      estadoAnterior: $HistorialEstadosTable.$converterestadoAnteriorn.fromJson(
        serializer.fromJson<String?>(json['estadoAnterior']),
      ),
      estadoNuevo: $HistorialEstadosTable.$converterestadoNuevo.fromJson(
        serializer.fromJson<String>(json['estadoNuevo']),
      ),
      motivo: serializer.fromJson<String?>(json['motivo']),
      usuarioId: serializer.fromJson<int?>(json['usuarioId']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clienteId': serializer.toJson<int>(clienteId),
      'estadoAnterior': serializer.toJson<String?>(
        $HistorialEstadosTable.$converterestadoAnteriorn.toJson(estadoAnterior),
      ),
      'estadoNuevo': serializer.toJson<String>(
        $HistorialEstadosTable.$converterestadoNuevo.toJson(estadoNuevo),
      ),
      'motivo': serializer.toJson<String?>(motivo),
      'usuarioId': serializer.toJson<int?>(usuarioId),
      'fecha': serializer.toJson<DateTime>(fecha),
    };
  }

  HistorialEstado copyWith({
    int? id,
    int? clienteId,
    Value<EstadoCliente?> estadoAnterior = const Value.absent(),
    EstadoCliente? estadoNuevo,
    Value<String?> motivo = const Value.absent(),
    Value<int?> usuarioId = const Value.absent(),
    DateTime? fecha,
  }) => HistorialEstado(
    id: id ?? this.id,
    clienteId: clienteId ?? this.clienteId,
    estadoAnterior: estadoAnterior.present
        ? estadoAnterior.value
        : this.estadoAnterior,
    estadoNuevo: estadoNuevo ?? this.estadoNuevo,
    motivo: motivo.present ? motivo.value : this.motivo,
    usuarioId: usuarioId.present ? usuarioId.value : this.usuarioId,
    fecha: fecha ?? this.fecha,
  );
  HistorialEstado copyWithCompanion(HistorialEstadosCompanion data) {
    return HistorialEstado(
      id: data.id.present ? data.id.value : this.id,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      estadoAnterior: data.estadoAnterior.present
          ? data.estadoAnterior.value
          : this.estadoAnterior,
      estadoNuevo: data.estadoNuevo.present
          ? data.estadoNuevo.value
          : this.estadoNuevo,
      motivo: data.motivo.present ? data.motivo.value : this.motivo,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistorialEstado(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('estadoAnterior: $estadoAnterior, ')
          ..write('estadoNuevo: $estadoNuevo, ')
          ..write('motivo: $motivo, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('fecha: $fecha')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clienteId,
    estadoAnterior,
    estadoNuevo,
    motivo,
    usuarioId,
    fecha,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistorialEstado &&
          other.id == this.id &&
          other.clienteId == this.clienteId &&
          other.estadoAnterior == this.estadoAnterior &&
          other.estadoNuevo == this.estadoNuevo &&
          other.motivo == this.motivo &&
          other.usuarioId == this.usuarioId &&
          other.fecha == this.fecha);
}

class HistorialEstadosCompanion extends UpdateCompanion<HistorialEstado> {
  final Value<int> id;
  final Value<int> clienteId;
  final Value<EstadoCliente?> estadoAnterior;
  final Value<EstadoCliente> estadoNuevo;
  final Value<String?> motivo;
  final Value<int?> usuarioId;
  final Value<DateTime> fecha;
  const HistorialEstadosCompanion({
    this.id = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.estadoAnterior = const Value.absent(),
    this.estadoNuevo = const Value.absent(),
    this.motivo = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.fecha = const Value.absent(),
  });
  HistorialEstadosCompanion.insert({
    this.id = const Value.absent(),
    required int clienteId,
    this.estadoAnterior = const Value.absent(),
    required EstadoCliente estadoNuevo,
    this.motivo = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.fecha = const Value.absent(),
  }) : clienteId = Value(clienteId),
       estadoNuevo = Value(estadoNuevo);
  static Insertable<HistorialEstado> custom({
    Expression<int>? id,
    Expression<int>? clienteId,
    Expression<String>? estadoAnterior,
    Expression<String>? estadoNuevo,
    Expression<String>? motivo,
    Expression<int>? usuarioId,
    Expression<DateTime>? fecha,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clienteId != null) 'cliente_id': clienteId,
      if (estadoAnterior != null) 'estado_anterior': estadoAnterior,
      if (estadoNuevo != null) 'estado_nuevo': estadoNuevo,
      if (motivo != null) 'motivo': motivo,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (fecha != null) 'fecha': fecha,
    });
  }

  HistorialEstadosCompanion copyWith({
    Value<int>? id,
    Value<int>? clienteId,
    Value<EstadoCliente?>? estadoAnterior,
    Value<EstadoCliente>? estadoNuevo,
    Value<String?>? motivo,
    Value<int?>? usuarioId,
    Value<DateTime>? fecha,
  }) {
    return HistorialEstadosCompanion(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      estadoAnterior: estadoAnterior ?? this.estadoAnterior,
      estadoNuevo: estadoNuevo ?? this.estadoNuevo,
      motivo: motivo ?? this.motivo,
      usuarioId: usuarioId ?? this.usuarioId,
      fecha: fecha ?? this.fecha,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<int>(clienteId.value);
    }
    if (estadoAnterior.present) {
      map['estado_anterior'] = Variable<String>(
        $HistorialEstadosTable.$converterestadoAnteriorn.toSql(
          estadoAnterior.value,
        ),
      );
    }
    if (estadoNuevo.present) {
      map['estado_nuevo'] = Variable<String>(
        $HistorialEstadosTable.$converterestadoNuevo.toSql(estadoNuevo.value),
      );
    }
    if (motivo.present) {
      map['motivo'] = Variable<String>(motivo.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<int>(usuarioId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistorialEstadosCompanion(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('estadoAnterior: $estadoAnterior, ')
          ..write('estadoNuevo: $estadoNuevo, ')
          ..write('motivo: $motivo, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('fecha: $fecha')
          ..write(')'))
        .toString();
  }
}

class $GastosTable extends Gastos with TableInfo<$GastosTable, Gasto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GastosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conceptoMeta = const VerificationMeta(
    'concepto',
  );
  @override
  late final GeneratedColumn<String> concepto = GeneratedColumn<String>(
    'concepto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaMeta = const VerificationMeta(
    'categoria',
  );
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
    'categoria',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<int> monto = GeneratedColumn<int>(
    'monto',
    aliasedName,
    false,
    check: () => ComparableExpr(monto).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usuarioIdMeta = const VerificationMeta(
    'usuarioId',
  );
  @override
  late final GeneratedColumn<int> usuarioId = GeneratedColumn<int>(
    'usuario_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES usuarios (id)',
    ),
  );
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
    'notas',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fecha,
    concepto,
    categoria,
    monto,
    usuarioId,
    notas,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gastos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Gasto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('concepto')) {
      context.handle(
        _conceptoMeta,
        concepto.isAcceptableOrUnknown(data['concepto']!, _conceptoMeta),
      );
    } else if (isInserting) {
      context.missing(_conceptoMeta);
    }
    if (data.containsKey('categoria')) {
      context.handle(
        _categoriaMeta,
        categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta),
      );
    }
    if (data.containsKey('monto')) {
      context.handle(
        _montoMeta,
        monto.isAcceptableOrUnknown(data['monto']!, _montoMeta),
      );
    } else if (isInserting) {
      context.missing(_montoMeta);
    }
    if (data.containsKey('usuario_id')) {
      context.handle(
        _usuarioIdMeta,
        usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta),
      );
    }
    if (data.containsKey('notas')) {
      context.handle(
        _notasMeta,
        notas.isAcceptableOrUnknown(data['notas']!, _notasMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Gasto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Gasto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      concepto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concepto'],
      )!,
      categoria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria'],
      ),
      monto: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monto'],
      )!,
      usuarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}usuario_id'],
      ),
      notas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notas'],
      ),
    );
  }

  @override
  $GastosTable createAlias(String alias) {
    return $GastosTable(attachedDatabase, alias);
  }
}

class Gasto extends DataClass implements Insertable<Gasto> {
  final int id;
  final DateTime fecha;
  final String concepto;
  final String? categoria;
  final int monto;
  final int? usuarioId;
  final String? notas;
  const Gasto({
    required this.id,
    required this.fecha,
    required this.concepto,
    this.categoria,
    required this.monto,
    this.usuarioId,
    this.notas,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fecha'] = Variable<DateTime>(fecha);
    map['concepto'] = Variable<String>(concepto);
    if (!nullToAbsent || categoria != null) {
      map['categoria'] = Variable<String>(categoria);
    }
    map['monto'] = Variable<int>(monto);
    if (!nullToAbsent || usuarioId != null) {
      map['usuario_id'] = Variable<int>(usuarioId);
    }
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    return map;
  }

  GastosCompanion toCompanion(bool nullToAbsent) {
    return GastosCompanion(
      id: Value(id),
      fecha: Value(fecha),
      concepto: Value(concepto),
      categoria: categoria == null && nullToAbsent
          ? const Value.absent()
          : Value(categoria),
      monto: Value(monto),
      usuarioId: usuarioId == null && nullToAbsent
          ? const Value.absent()
          : Value(usuarioId),
      notas: notas == null && nullToAbsent
          ? const Value.absent()
          : Value(notas),
    );
  }

  factory Gasto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Gasto(
      id: serializer.fromJson<int>(json['id']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      concepto: serializer.fromJson<String>(json['concepto']),
      categoria: serializer.fromJson<String?>(json['categoria']),
      monto: serializer.fromJson<int>(json['monto']),
      usuarioId: serializer.fromJson<int?>(json['usuarioId']),
      notas: serializer.fromJson<String?>(json['notas']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fecha': serializer.toJson<DateTime>(fecha),
      'concepto': serializer.toJson<String>(concepto),
      'categoria': serializer.toJson<String?>(categoria),
      'monto': serializer.toJson<int>(monto),
      'usuarioId': serializer.toJson<int?>(usuarioId),
      'notas': serializer.toJson<String?>(notas),
    };
  }

  Gasto copyWith({
    int? id,
    DateTime? fecha,
    String? concepto,
    Value<String?> categoria = const Value.absent(),
    int? monto,
    Value<int?> usuarioId = const Value.absent(),
    Value<String?> notas = const Value.absent(),
  }) => Gasto(
    id: id ?? this.id,
    fecha: fecha ?? this.fecha,
    concepto: concepto ?? this.concepto,
    categoria: categoria.present ? categoria.value : this.categoria,
    monto: monto ?? this.monto,
    usuarioId: usuarioId.present ? usuarioId.value : this.usuarioId,
    notas: notas.present ? notas.value : this.notas,
  );
  Gasto copyWithCompanion(GastosCompanion data) {
    return Gasto(
      id: data.id.present ? data.id.value : this.id,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      concepto: data.concepto.present ? data.concepto.value : this.concepto,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      monto: data.monto.present ? data.monto.value : this.monto,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
      notas: data.notas.present ? data.notas.value : this.notas,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Gasto(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('concepto: $concepto, ')
          ..write('categoria: $categoria, ')
          ..write('monto: $monto, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('notas: $notas')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, fecha, concepto, categoria, monto, usuarioId, notas);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Gasto &&
          other.id == this.id &&
          other.fecha == this.fecha &&
          other.concepto == this.concepto &&
          other.categoria == this.categoria &&
          other.monto == this.monto &&
          other.usuarioId == this.usuarioId &&
          other.notas == this.notas);
}

class GastosCompanion extends UpdateCompanion<Gasto> {
  final Value<int> id;
  final Value<DateTime> fecha;
  final Value<String> concepto;
  final Value<String?> categoria;
  final Value<int> monto;
  final Value<int?> usuarioId;
  final Value<String?> notas;
  const GastosCompanion({
    this.id = const Value.absent(),
    this.fecha = const Value.absent(),
    this.concepto = const Value.absent(),
    this.categoria = const Value.absent(),
    this.monto = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.notas = const Value.absent(),
  });
  GastosCompanion.insert({
    this.id = const Value.absent(),
    required DateTime fecha,
    required String concepto,
    this.categoria = const Value.absent(),
    required int monto,
    this.usuarioId = const Value.absent(),
    this.notas = const Value.absent(),
  }) : fecha = Value(fecha),
       concepto = Value(concepto),
       monto = Value(monto);
  static Insertable<Gasto> custom({
    Expression<int>? id,
    Expression<DateTime>? fecha,
    Expression<String>? concepto,
    Expression<String>? categoria,
    Expression<int>? monto,
    Expression<int>? usuarioId,
    Expression<String>? notas,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fecha != null) 'fecha': fecha,
      if (concepto != null) 'concepto': concepto,
      if (categoria != null) 'categoria': categoria,
      if (monto != null) 'monto': monto,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (notas != null) 'notas': notas,
    });
  }

  GastosCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? fecha,
    Value<String>? concepto,
    Value<String?>? categoria,
    Value<int>? monto,
    Value<int?>? usuarioId,
    Value<String?>? notas,
  }) {
    return GastosCompanion(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      concepto: concepto ?? this.concepto,
      categoria: categoria ?? this.categoria,
      monto: monto ?? this.monto,
      usuarioId: usuarioId ?? this.usuarioId,
      notas: notas ?? this.notas,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (concepto.present) {
      map['concepto'] = Variable<String>(concepto.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (monto.present) {
      map['monto'] = Variable<int>(monto.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<int>(usuarioId.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GastosCompanion(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('concepto: $concepto, ')
          ..write('categoria: $categoria, ')
          ..write('monto: $monto, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('notas: $notas')
          ..write(')'))
        .toString();
  }
}

class $ConfiguracionesTable extends Configuraciones
    with TableInfo<$ConfiguracionesTable, ConfigItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConfiguracionesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _claveMeta = const VerificationMeta('clave');
  @override
  late final GeneratedColumn<String> clave = GeneratedColumn<String>(
    'clave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<String> valor = GeneratedColumn<String>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [clave, valor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'configuraciones';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConfigItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('clave')) {
      context.handle(
        _claveMeta,
        clave.isAcceptableOrUnknown(data['clave']!, _claveMeta),
      );
    } else if (isInserting) {
      context.missing(_claveMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clave};
  @override
  ConfigItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConfigItem(
      clave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clave'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valor'],
      )!,
    );
  }

  @override
  $ConfiguracionesTable createAlias(String alias) {
    return $ConfiguracionesTable(attachedDatabase, alias);
  }
}

class ConfigItem extends DataClass implements Insertable<ConfigItem> {
  final String clave;
  final String valor;
  const ConfigItem({required this.clave, required this.valor});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['clave'] = Variable<String>(clave);
    map['valor'] = Variable<String>(valor);
    return map;
  }

  ConfiguracionesCompanion toCompanion(bool nullToAbsent) {
    return ConfiguracionesCompanion(clave: Value(clave), valor: Value(valor));
  }

  factory ConfigItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConfigItem(
      clave: serializer.fromJson<String>(json['clave']),
      valor: serializer.fromJson<String>(json['valor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clave': serializer.toJson<String>(clave),
      'valor': serializer.toJson<String>(valor),
    };
  }

  ConfigItem copyWith({String? clave, String? valor}) =>
      ConfigItem(clave: clave ?? this.clave, valor: valor ?? this.valor);
  ConfigItem copyWithCompanion(ConfiguracionesCompanion data) {
    return ConfigItem(
      clave: data.clave.present ? data.clave.value : this.clave,
      valor: data.valor.present ? data.valor.value : this.valor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConfigItem(')
          ..write('clave: $clave, ')
          ..write('valor: $valor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(clave, valor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConfigItem &&
          other.clave == this.clave &&
          other.valor == this.valor);
}

class ConfiguracionesCompanion extends UpdateCompanion<ConfigItem> {
  final Value<String> clave;
  final Value<String> valor;
  final Value<int> rowid;
  const ConfiguracionesCompanion({
    this.clave = const Value.absent(),
    this.valor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConfiguracionesCompanion.insert({
    required String clave,
    required String valor,
    this.rowid = const Value.absent(),
  }) : clave = Value(clave),
       valor = Value(valor);
  static Insertable<ConfigItem> custom({
    Expression<String>? clave,
    Expression<String>? valor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clave != null) 'clave': clave,
      if (valor != null) 'valor': valor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConfiguracionesCompanion copyWith({
    Value<String>? clave,
    Value<String>? valor,
    Value<int>? rowid,
  }) {
    return ConfiguracionesCompanion(
      clave: clave ?? this.clave,
      valor: valor ?? this.valor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clave.present) {
      map['clave'] = Variable<String>(clave.value);
    }
    if (valor.present) {
      map['valor'] = Variable<String>(valor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfiguracionesCompanion(')
          ..write('clave: $clave, ')
          ..write('valor: $valor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsuariosTable usuarios = $UsuariosTable(this);
  late final $PlanesTable planes = $PlanesTable(this);
  late final $ClientesTable clientes = $ClientesTable(this);
  late final $InstalacionesTable instalaciones = $InstalacionesTable(this);
  late final $EquiposTable equipos = $EquiposTable(this);
  late final $PeriodosTable periodos = $PeriodosTable(this);
  late final $PagosTable pagos = $PagosTable(this);
  late final $PagoAplicacionesTable pagoAplicaciones = $PagoAplicacionesTable(
    this,
  );
  late final $CargosTable cargos = $CargosTable(this);
  late final $CargoAplicacionesTable cargoAplicaciones =
      $CargoAplicacionesTable(this);
  late final $HistorialEstadosTable historialEstados = $HistorialEstadosTable(
    this,
  );
  late final $GastosTable gastos = $GastosTable(this);
  late final $ConfiguracionesTable configuraciones = $ConfiguracionesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    usuarios,
    planes,
    clientes,
    instalaciones,
    equipos,
    periodos,
    pagos,
    pagoAplicaciones,
    cargos,
    cargoAplicaciones,
    historialEstados,
    gastos,
    configuraciones,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$UsuariosTableCreateCompanionBuilder = UsuariosCompanion Function({
  Value<int> id,
  required String nombre,
  required String usuario,
  required String pinHash,
  required RolUsuario rol,
  Value<bool> activo,
  Value<DateTime> creadoEn,
});
typedef $$UsuariosTableUpdateCompanionBuilder = UsuariosCompanion Function({
  Value<int> id,
  Value<String> nombre,
  Value<String> usuario,
  Value<String> pinHash,
  Value<RolUsuario> rol,
  Value<bool> activo,
  Value<DateTime> creadoEn,
});

final class $$UsuariosTableReferences
    extends BaseReferences<_$AppDatabase, $UsuariosTable, Usuario> {
  $$UsuariosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PagosTable, List<Pago>> _pagosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.pagos,
    aliasName: 'usuarios__id__pagos__registrado_por',
  );

  $$PagosTableProcessedTableManager get pagosRefs {
    final manager = $$PagosTableTableManager(
      $_db,
      $_db.pagos,
    ).filter((f) => f.registradoPor.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pagosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HistorialEstadosTable, List<HistorialEstado>>
  _historialEstadosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.historialEstados,
    aliasName: 'usuarios__id__historial_estados__usuario_id',
  );

  $$HistorialEstadosTableProcessedTableManager get historialEstadosRefs {
    final manager = $$HistorialEstadosTableTableManager(
      $_db,
      $_db.historialEstados,
    ).filter((f) => f.usuarioId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _historialEstadosRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GastosTable, List<Gasto>> _gastosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.gastos,
    aliasName: 'usuarios__id__gastos__usuario_id',
  );

  $$GastosTableProcessedTableManager get gastosRefs {
    final manager = $$GastosTableTableManager(
      $_db,
      $_db.gastos,
    ).filter((f) => f.usuarioId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gastosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsuariosTableFilterComposer
    extends Composer<_$AppDatabase, $UsuariosTable> {
  $$UsuariosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usuario => $composableBuilder(
    column: $table.usuario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RolUsuario, RolUsuario, String> get rol =>
      $composableBuilder(
        column: $table.rol,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> pagosRefs(
    Expression<bool> Function($$PagosTableFilterComposer f) f,
  ) {
    final $$PagosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pagos,
      getReferencedColumn: (t) => t.registradoPor,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagosTableFilterComposer(
            $db: $db,
            $table: $db.pagos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> historialEstadosRefs(
    Expression<bool> Function($$HistorialEstadosTableFilterComposer f) f,
  ) {
    final $$HistorialEstadosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.historialEstados,
      getReferencedColumn: (t) => t.usuarioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistorialEstadosTableFilterComposer(
            $db: $db,
            $table: $db.historialEstados,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> gastosRefs(
    Expression<bool> Function($$GastosTableFilterComposer f) f,
  ) {
    final $$GastosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gastos,
      getReferencedColumn: (t) => t.usuarioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GastosTableFilterComposer(
            $db: $db,
            $table: $db.gastos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsuariosTableOrderingComposer
    extends Composer<_$AppDatabase, $UsuariosTable> {
  $$UsuariosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usuario => $composableBuilder(
    column: $table.usuario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rol => $composableBuilder(
    column: $table.rol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsuariosTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsuariosTable> {
  $$UsuariosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get usuario =>
      $composableBuilder(column: $table.usuario, builder: (column) => column);

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RolUsuario, String> get rol =>
      $composableBuilder(column: $table.rol, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  Expression<T> pagosRefs<T extends Object>(
    Expression<T> Function($$PagosTableAnnotationComposer a) f,
  ) {
    final $$PagosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pagos,
      getReferencedColumn: (t) => t.registradoPor,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagosTableAnnotationComposer(
            $db: $db,
            $table: $db.pagos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> historialEstadosRefs<T extends Object>(
    Expression<T> Function($$HistorialEstadosTableAnnotationComposer a) f,
  ) {
    final $$HistorialEstadosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.historialEstados,
      getReferencedColumn: (t) => t.usuarioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistorialEstadosTableAnnotationComposer(
            $db: $db,
            $table: $db.historialEstados,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> gastosRefs<T extends Object>(
    Expression<T> Function($$GastosTableAnnotationComposer a) f,
  ) {
    final $$GastosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gastos,
      getReferencedColumn: (t) => t.usuarioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GastosTableAnnotationComposer(
            $db: $db,
            $table: $db.gastos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsuariosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsuariosTable,
          Usuario,
          $$UsuariosTableFilterComposer,
          $$UsuariosTableOrderingComposer,
          $$UsuariosTableAnnotationComposer,
          $$UsuariosTableCreateCompanionBuilder,
          $$UsuariosTableUpdateCompanionBuilder,
          (Usuario, $$UsuariosTableReferences),
          Usuario,
          PrefetchHooks Function({
            bool pagosRefs,
            bool historialEstadosRefs,
            bool gastosRefs,
          })
        > {
  $$UsuariosTableTableManager(_$AppDatabase db, $UsuariosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsuariosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsuariosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsuariosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> usuario = const Value.absent(),
                Value<String> pinHash = const Value.absent(),
                Value<RolUsuario> rol = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => UsuariosCompanion(
                id: id,
                nombre: nombre,
                usuario: usuario,
                pinHash: pinHash,
                rol: rol,
                activo: activo,
                creadoEn: creadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                required String usuario,
                required String pinHash,
                required RolUsuario rol,
                Value<bool> activo = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => UsuariosCompanion.insert(
                id: id,
                nombre: nombre,
                usuario: usuario,
                pinHash: pinHash,
                rol: rol,
                activo: activo,
                creadoEn: creadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UsuariosTable, Usuario>(table),
                  $$UsuariosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                pagosRefs = false,
                historialEstadosRefs = false,
                gastosRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (pagosRefs) db.pagos,
                    if (historialEstadosRefs) db.historialEstados,
                    if (gastosRefs) db.gastos,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (pagosRefs)
                        await $_getPrefetchedDataByColumns<
                          Usuario,
                          $UsuariosTable,
                          Pago,
                          $PagosTable
                        >(
                          currentTable: table,
                          referencedTable: $$UsuariosTableReferences
                              ._pagosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsuariosTableReferences(
                                db,
                                table,
                                p0,
                              ).pagosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'registrado_por',
                          typedResults: items,
                        ),
                      if (historialEstadosRefs)
                        await $_getPrefetchedDataByColumns<
                          Usuario,
                          $UsuariosTable,
                          HistorialEstado,
                          $HistorialEstadosTable
                        >(
                          currentTable: table,
                          referencedTable: $$UsuariosTableReferences
                              ._historialEstadosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsuariosTableReferences(
                                db,
                                table,
                                p0,
                              ).historialEstadosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'usuario_id',
                          typedResults: items,
                        ),
                      if (gastosRefs)
                        await $_getPrefetchedDataByColumns<
                          Usuario,
                          $UsuariosTable,
                          Gasto,
                          $GastosTable
                        >(
                          currentTable: table,
                          referencedTable: $$UsuariosTableReferences
                              ._gastosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsuariosTableReferences(
                                db,
                                table,
                                p0,
                              ).gastosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'usuario_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UsuariosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsuariosTable,
      Usuario,
      $$UsuariosTableFilterComposer,
      $$UsuariosTableOrderingComposer,
      $$UsuariosTableAnnotationComposer,
      $$UsuariosTableCreateCompanionBuilder,
      $$UsuariosTableUpdateCompanionBuilder,
      (Usuario, $$UsuariosTableReferences),
      Usuario,
      PrefetchHooks Function({
        bool pagosRefs,
        bool historialEstadosRefs,
        bool gastosRefs,
      })
    >;
typedef $$PlanesTableCreateCompanionBuilder = PlanesCompanion Function({
  Value<int> id,
  required String nombre,
  required int velocidadMbps,
  required int precioBase,
  Value<bool> activo,
});
typedef $$PlanesTableUpdateCompanionBuilder = PlanesCompanion Function({
  Value<int> id,
  Value<String> nombre,
  Value<int> velocidadMbps,
  Value<int> precioBase,
  Value<bool> activo,
});

final class $$PlanesTableReferences
    extends BaseReferences<_$AppDatabase, $PlanesTable, Plan> {
  $$PlanesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ClientesTable, List<Cliente>> _clientesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.clientes,
    aliasName: 'planes__id__clientes__plan_id',
  );

  $$ClientesTableProcessedTableManager get clientesRefs {
    final manager = $$ClientesTableTableManager(
      $_db,
      $_db.clientes,
    ).filter((f) => f.planId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_clientesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlanesTableFilterComposer
    extends Composer<_$AppDatabase, $PlanesTable> {
  $$PlanesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get velocidadMbps => $composableBuilder(
    column: $table.velocidadMbps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get precioBase => $composableBuilder(
    column: $table.precioBase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> clientesRefs(
    Expression<bool> Function($$ClientesTableFilterComposer f) f,
  ) {
    final $$ClientesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableFilterComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlanesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanesTable> {
  $$PlanesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get velocidadMbps => $composableBuilder(
    column: $table.velocidadMbps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get precioBase => $composableBuilder(
    column: $table.precioBase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlanesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanesTable> {
  $$PlanesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<int> get velocidadMbps => $composableBuilder(
    column: $table.velocidadMbps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get precioBase => $composableBuilder(
    column: $table.precioBase,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  Expression<T> clientesRefs<T extends Object>(
    Expression<T> Function($$ClientesTableAnnotationComposer a) f,
  ) {
    final $$ClientesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableAnnotationComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlanesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanesTable,
          Plan,
          $$PlanesTableFilterComposer,
          $$PlanesTableOrderingComposer,
          $$PlanesTableAnnotationComposer,
          $$PlanesTableCreateCompanionBuilder,
          $$PlanesTableUpdateCompanionBuilder,
          (Plan, $$PlanesTableReferences),
          Plan,
          PrefetchHooks Function({bool clientesRefs})
        > {
  $$PlanesTableTableManager(_$AppDatabase db, $PlanesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<int> velocidadMbps = const Value.absent(),
                Value<int> precioBase = const Value.absent(),
                Value<bool> activo = const Value.absent(),
              }) => PlanesCompanion(
                id: id,
                nombre: nombre,
                velocidadMbps: velocidadMbps,
                precioBase: precioBase,
                activo: activo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                required int velocidadMbps,
                required int precioBase,
                Value<bool> activo = const Value.absent(),
              }) => PlanesCompanion.insert(
                id: id,
                nombre: nombre,
                velocidadMbps: velocidadMbps,
                precioBase: precioBase,
                activo: activo,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlanesTable, Plan>(table),
                  $$PlanesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({clientesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (clientesRefs) db.clientes],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (clientesRefs)
                    await $_getPrefetchedDataByColumns<
                      Plan,
                      $PlanesTable,
                      Cliente,
                      $ClientesTable
                    >(
                      currentTable: table,
                      referencedTable: $$PlanesTableReferences
                          ._clientesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PlanesTableReferences(db, table, p0).clientesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'plan_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlanesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanesTable,
      Plan,
      $$PlanesTableFilterComposer,
      $$PlanesTableOrderingComposer,
      $$PlanesTableAnnotationComposer,
      $$PlanesTableCreateCompanionBuilder,
      $$PlanesTableUpdateCompanionBuilder,
      (Plan, $$PlanesTableReferences),
      Plan,
      PrefetchHooks Function({bool clientesRefs})
    >;
typedef $$ClientesTableCreateCompanionBuilder = ClientesCompanion Function({
  Value<int> id,
  required String nombre,
  Value<String?> telefono,
  Value<String?> direccion,
  Value<String?> zona,
  Value<String?> referencia,
  required int planId,
  required int precioMensual,
  required int diaCorte,
  required TipoContratacion tipoContratacion,
  required DateTime fechaAlta,
  Value<String?> primerMesCobro,
  Value<EstadoCliente> estado,
  Value<String?> notas,
  Value<DateTime> creadoEn,
});
typedef $$ClientesTableUpdateCompanionBuilder = ClientesCompanion Function({
  Value<int> id,
  Value<String> nombre,
  Value<String?> telefono,
  Value<String?> direccion,
  Value<String?> zona,
  Value<String?> referencia,
  Value<int> planId,
  Value<int> precioMensual,
  Value<int> diaCorte,
  Value<TipoContratacion> tipoContratacion,
  Value<DateTime> fechaAlta,
  Value<String?> primerMesCobro,
  Value<EstadoCliente> estado,
  Value<String?> notas,
  Value<DateTime> creadoEn,
});

final class $$ClientesTableReferences
    extends BaseReferences<_$AppDatabase, $ClientesTable, Cliente> {
  $$ClientesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlanesTable _planIdTable(_$AppDatabase db) =>
      db.planes.createAlias('clientes__plan_id__planes__id');

  $$PlanesTableProcessedTableManager get planId {
    final $_column = $_itemColumn<int>('plan_id')!;

    final manager = $$PlanesTableTableManager(
      $_db,
      $_db.planes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$InstalacionesTable, List<Instalacion>>
  _instalacionesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.instalaciones,
    aliasName: 'clientes__id__instalaciones__cliente_id',
  );

  $$InstalacionesTableProcessedTableManager get instalacionesRefs {
    final manager = $$InstalacionesTableTableManager(
      $_db,
      $_db.instalaciones,
    ).filter((f) => f.clienteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_instalacionesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EquiposTable, List<Equipo>> _equiposRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.equipos,
    aliasName: 'clientes__id__equipos__cliente_id',
  );

  $$EquiposTableProcessedTableManager get equiposRefs {
    final manager = $$EquiposTableTableManager(
      $_db,
      $_db.equipos,
    ).filter((f) => f.clienteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_equiposRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PeriodosTable, List<PeriodoRow>>
  _periodosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.periodos,
    aliasName: 'clientes__id__periodos__cliente_id',
  );

  $$PeriodosTableProcessedTableManager get periodosRefs {
    final manager = $$PeriodosTableTableManager(
      $_db,
      $_db.periodos,
    ).filter((f) => f.clienteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_periodosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PagosTable, List<Pago>> _pagosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.pagos,
    aliasName: 'clientes__id__pagos__cliente_id',
  );

  $$PagosTableProcessedTableManager get pagosRefs {
    final manager = $$PagosTableTableManager(
      $_db,
      $_db.pagos,
    ).filter((f) => f.clienteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pagosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CargosTable, List<Cargo>> _cargosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cargos,
    aliasName: 'clientes__id__cargos__cliente_id',
  );

  $$CargosTableProcessedTableManager get cargosRefs {
    final manager = $$CargosTableTableManager(
      $_db,
      $_db.cargos,
    ).filter((f) => f.clienteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cargosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HistorialEstadosTable, List<HistorialEstado>>
  _historialEstadosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.historialEstados,
    aliasName: 'clientes__id__historial_estados__cliente_id',
  );

  $$HistorialEstadosTableProcessedTableManager get historialEstadosRefs {
    final manager = $$HistorialEstadosTableTableManager(
      $_db,
      $_db.historialEstados,
    ).filter((f) => f.clienteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _historialEstadosRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ClientesTableFilterComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direccion => $composableBuilder(
    column: $table.direccion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zona => $composableBuilder(
    column: $table.zona,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referencia => $composableBuilder(
    column: $table.referencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get precioMensual => $composableBuilder(
    column: $table.precioMensual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diaCorte => $composableBuilder(
    column: $table.diaCorte,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoContratacion, TipoContratacion, String>
  get tipoContratacion => $composableBuilder(
    column: $table.tipoContratacion,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get fechaAlta => $composableBuilder(
    column: $table.fechaAlta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primerMesCobro => $composableBuilder(
    column: $table.primerMesCobro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EstadoCliente, EstadoCliente, String>
  get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  $$PlanesTableFilterComposer get planId {
    final $$PlanesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.planes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanesTableFilterComposer(
            $db: $db,
            $table: $db.planes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> instalacionesRefs(
    Expression<bool> Function($$InstalacionesTableFilterComposer f) f,
  ) {
    final $$InstalacionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.instalaciones,
      getReferencedColumn: (t) => t.clienteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstalacionesTableFilterComposer(
            $db: $db,
            $table: $db.instalaciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> equiposRefs(
    Expression<bool> Function($$EquiposTableFilterComposer f) f,
  ) {
    final $$EquiposTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.equipos,
      getReferencedColumn: (t) => t.clienteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquiposTableFilterComposer(
            $db: $db,
            $table: $db.equipos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> periodosRefs(
    Expression<bool> Function($$PeriodosTableFilterComposer f) f,
  ) {
    final $$PeriodosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.periodos,
      getReferencedColumn: (t) => t.clienteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodosTableFilterComposer(
            $db: $db,
            $table: $db.periodos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pagosRefs(
    Expression<bool> Function($$PagosTableFilterComposer f) f,
  ) {
    final $$PagosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pagos,
      getReferencedColumn: (t) => t.clienteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagosTableFilterComposer(
            $db: $db,
            $table: $db.pagos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cargosRefs(
    Expression<bool> Function($$CargosTableFilterComposer f) f,
  ) {
    final $$CargosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cargos,
      getReferencedColumn: (t) => t.clienteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CargosTableFilterComposer(
            $db: $db,
            $table: $db.cargos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> historialEstadosRefs(
    Expression<bool> Function($$HistorialEstadosTableFilterComposer f) f,
  ) {
    final $$HistorialEstadosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.historialEstados,
      getReferencedColumn: (t) => t.clienteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistorialEstadosTableFilterComposer(
            $db: $db,
            $table: $db.historialEstados,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direccion => $composableBuilder(
    column: $table.direccion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zona => $composableBuilder(
    column: $table.zona,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referencia => $composableBuilder(
    column: $table.referencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get precioMensual => $composableBuilder(
    column: $table.precioMensual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diaCorte => $composableBuilder(
    column: $table.diaCorte,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoContratacion => $composableBuilder(
    column: $table.tipoContratacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaAlta => $composableBuilder(
    column: $table.fechaAlta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primerMesCobro => $composableBuilder(
    column: $table.primerMesCobro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlanesTableOrderingComposer get planId {
    final $$PlanesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.planes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanesTableOrderingComposer(
            $db: $db,
            $table: $db.planes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClientesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

  GeneratedColumn<String> get direccion =>
      $composableBuilder(column: $table.direccion, builder: (column) => column);

  GeneratedColumn<String> get zona =>
      $composableBuilder(column: $table.zona, builder: (column) => column);

  GeneratedColumn<String> get referencia => $composableBuilder(
    column: $table.referencia,
    builder: (column) => column,
  );

  GeneratedColumn<int> get precioMensual => $composableBuilder(
    column: $table.precioMensual,
    builder: (column) => column,
  );

  GeneratedColumn<int> get diaCorte =>
      $composableBuilder(column: $table.diaCorte, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TipoContratacion, String>
  get tipoContratacion => $composableBuilder(
    column: $table.tipoContratacion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fechaAlta =>
      $composableBuilder(column: $table.fechaAlta, builder: (column) => column);

  GeneratedColumn<String> get primerMesCobro => $composableBuilder(
    column: $table.primerMesCobro,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<EstadoCliente, String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  $$PlanesTableAnnotationComposer get planId {
    final $$PlanesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.planes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanesTableAnnotationComposer(
            $db: $db,
            $table: $db.planes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> instalacionesRefs<T extends Object>(
    Expression<T> Function($$InstalacionesTableAnnotationComposer a) f,
  ) {
    final $$InstalacionesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.instalaciones,
      getReferencedColumn: (t) => t.clienteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstalacionesTableAnnotationComposer(
            $db: $db,
            $table: $db.instalaciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> equiposRefs<T extends Object>(
    Expression<T> Function($$EquiposTableAnnotationComposer a) f,
  ) {
    final $$EquiposTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.equipos,
      getReferencedColumn: (t) => t.clienteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquiposTableAnnotationComposer(
            $db: $db,
            $table: $db.equipos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> periodosRefs<T extends Object>(
    Expression<T> Function($$PeriodosTableAnnotationComposer a) f,
  ) {
    final $$PeriodosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.periodos,
      getReferencedColumn: (t) => t.clienteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodosTableAnnotationComposer(
            $db: $db,
            $table: $db.periodos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pagosRefs<T extends Object>(
    Expression<T> Function($$PagosTableAnnotationComposer a) f,
  ) {
    final $$PagosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pagos,
      getReferencedColumn: (t) => t.clienteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagosTableAnnotationComposer(
            $db: $db,
            $table: $db.pagos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cargosRefs<T extends Object>(
    Expression<T> Function($$CargosTableAnnotationComposer a) f,
  ) {
    final $$CargosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cargos,
      getReferencedColumn: (t) => t.clienteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CargosTableAnnotationComposer(
            $db: $db,
            $table: $db.cargos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> historialEstadosRefs<T extends Object>(
    Expression<T> Function($$HistorialEstadosTableAnnotationComposer a) f,
  ) {
    final $$HistorialEstadosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.historialEstados,
      getReferencedColumn: (t) => t.clienteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistorialEstadosTableAnnotationComposer(
            $db: $db,
            $table: $db.historialEstados,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClientesTable,
          Cliente,
          $$ClientesTableFilterComposer,
          $$ClientesTableOrderingComposer,
          $$ClientesTableAnnotationComposer,
          $$ClientesTableCreateCompanionBuilder,
          $$ClientesTableUpdateCompanionBuilder,
          (Cliente, $$ClientesTableReferences),
          Cliente,
          PrefetchHooks Function({
            bool planId,
            bool instalacionesRefs,
            bool equiposRefs,
            bool periodosRefs,
            bool pagosRefs,
            bool cargosRefs,
            bool historialEstadosRefs,
          })
        > {
  $$ClientesTableTableManager(_$AppDatabase db, $ClientesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String?> telefono = const Value.absent(),
                Value<String?> direccion = const Value.absent(),
                Value<String?> zona = const Value.absent(),
                Value<String?> referencia = const Value.absent(),
                Value<int> planId = const Value.absent(),
                Value<int> precioMensual = const Value.absent(),
                Value<int> diaCorte = const Value.absent(),
                Value<TipoContratacion> tipoContratacion = const Value.absent(),
                Value<DateTime> fechaAlta = const Value.absent(),
                Value<String?> primerMesCobro = const Value.absent(),
                Value<EstadoCliente> estado = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => ClientesCompanion(
                id: id,
                nombre: nombre,
                telefono: telefono,
                direccion: direccion,
                zona: zona,
                referencia: referencia,
                planId: planId,
                precioMensual: precioMensual,
                diaCorte: diaCorte,
                tipoContratacion: tipoContratacion,
                fechaAlta: fechaAlta,
                primerMesCobro: primerMesCobro,
                estado: estado,
                notas: notas,
                creadoEn: creadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                Value<String?> telefono = const Value.absent(),
                Value<String?> direccion = const Value.absent(),
                Value<String?> zona = const Value.absent(),
                Value<String?> referencia = const Value.absent(),
                required int planId,
                required int precioMensual,
                required int diaCorte,
                required TipoContratacion tipoContratacion,
                required DateTime fechaAlta,
                Value<String?> primerMesCobro = const Value.absent(),
                Value<EstadoCliente> estado = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => ClientesCompanion.insert(
                id: id,
                nombre: nombre,
                telefono: telefono,
                direccion: direccion,
                zona: zona,
                referencia: referencia,
                planId: planId,
                precioMensual: precioMensual,
                diaCorte: diaCorte,
                tipoContratacion: tipoContratacion,
                fechaAlta: fechaAlta,
                primerMesCobro: primerMesCobro,
                estado: estado,
                notas: notas,
                creadoEn: creadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClientesTable, Cliente>(table),
                  $$ClientesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                planId = false,
                instalacionesRefs = false,
                equiposRefs = false,
                periodosRefs = false,
                pagosRefs = false,
                cargosRefs = false,
                historialEstadosRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (instalacionesRefs) db.instalaciones,
                    if (equiposRefs) db.equipos,
                    if (periodosRefs) db.periodos,
                    if (pagosRefs) db.pagos,
                    if (cargosRefs) db.cargos,
                    if (historialEstadosRefs) db.historialEstados,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (planId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.planId,
                            referencedTable: $$ClientesTableReferences
                                ._planIdTable(db),
                            referencedColumn: $$ClientesTableReferences
                                ._planIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (instalacionesRefs)
                        await $_getPrefetchedDataByColumns<
                          Cliente,
                          $ClientesTable,
                          Instalacion,
                          $InstalacionesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ClientesTableReferences
                              ._instalacionesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClientesTableReferences(
                                db,
                                table,
                                p0,
                              ).instalacionesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'cliente_id',
                          typedResults: items,
                        ),
                      if (equiposRefs)
                        await $_getPrefetchedDataByColumns<
                          Cliente,
                          $ClientesTable,
                          Equipo,
                          $EquiposTable
                        >(
                          currentTable: table,
                          referencedTable: $$ClientesTableReferences
                              ._equiposRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClientesTableReferences(
                                db,
                                table,
                                p0,
                              ).equiposRefs,
                          currentColumn: 'id',
                          referencedColumn: 'cliente_id',
                          typedResults: items,
                        ),
                      if (periodosRefs)
                        await $_getPrefetchedDataByColumns<
                          Cliente,
                          $ClientesTable,
                          PeriodoRow,
                          $PeriodosTable
                        >(
                          currentTable: table,
                          referencedTable: $$ClientesTableReferences
                              ._periodosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClientesTableReferences(
                                db,
                                table,
                                p0,
                              ).periodosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'cliente_id',
                          typedResults: items,
                        ),
                      if (pagosRefs)
                        await $_getPrefetchedDataByColumns<
                          Cliente,
                          $ClientesTable,
                          Pago,
                          $PagosTable
                        >(
                          currentTable: table,
                          referencedTable: $$ClientesTableReferences
                              ._pagosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClientesTableReferences(
                                db,
                                table,
                                p0,
                              ).pagosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'cliente_id',
                          typedResults: items,
                        ),
                      if (cargosRefs)
                        await $_getPrefetchedDataByColumns<
                          Cliente,
                          $ClientesTable,
                          Cargo,
                          $CargosTable
                        >(
                          currentTable: table,
                          referencedTable: $$ClientesTableReferences
                              ._cargosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClientesTableReferences(
                                db,
                                table,
                                p0,
                              ).cargosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'cliente_id',
                          typedResults: items,
                        ),
                      if (historialEstadosRefs)
                        await $_getPrefetchedDataByColumns<
                          Cliente,
                          $ClientesTable,
                          HistorialEstado,
                          $HistorialEstadosTable
                        >(
                          currentTable: table,
                          referencedTable: $$ClientesTableReferences
                              ._historialEstadosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClientesTableReferences(
                                db,
                                table,
                                p0,
                              ).historialEstadosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'cliente_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ClientesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClientesTable,
      Cliente,
      $$ClientesTableFilterComposer,
      $$ClientesTableOrderingComposer,
      $$ClientesTableAnnotationComposer,
      $$ClientesTableCreateCompanionBuilder,
      $$ClientesTableUpdateCompanionBuilder,
      (Cliente, $$ClientesTableReferences),
      Cliente,
      PrefetchHooks Function({
        bool planId,
        bool instalacionesRefs,
        bool equiposRefs,
        bool periodosRefs,
        bool pagosRefs,
        bool cargosRefs,
        bool historialEstadosRefs,
      })
    >;
typedef $$InstalacionesTableCreateCompanionBuilder =
    InstalacionesCompanion Function({
      Value<int> id,
      required int clienteId,
      required DateTime fecha,
      Value<int> costo,
      Value<bool> pagado,
      Value<String?> tecnico,
      Value<String?> notas,
    });
typedef $$InstalacionesTableUpdateCompanionBuilder =
    InstalacionesCompanion Function({
      Value<int> id,
      Value<int> clienteId,
      Value<DateTime> fecha,
      Value<int> costo,
      Value<bool> pagado,
      Value<String?> tecnico,
      Value<String?> notas,
    });

final class $$InstalacionesTableReferences
    extends BaseReferences<_$AppDatabase, $InstalacionesTable, Instalacion> {
  $$InstalacionesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ClientesTable _clienteIdTable(_$AppDatabase db) =>
      db.clientes.createAlias('instalaciones__cliente_id__clientes__id');

  $$ClientesTableProcessedTableManager get clienteId {
    final $_column = $_itemColumn<int>('cliente_id')!;

    final manager = $$ClientesTableTableManager(
      $_db,
      $_db.clientes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clienteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InstalacionesTableFilterComposer
    extends Composer<_$AppDatabase, $InstalacionesTable> {
  $$InstalacionesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get costo => $composableBuilder(
    column: $table.costo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pagado => $composableBuilder(
    column: $table.pagado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tecnico => $composableBuilder(
    column: $table.tecnico,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnFilters(column),
  );

  $$ClientesTableFilterComposer get clienteId {
    final $$ClientesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableFilterComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InstalacionesTableOrderingComposer
    extends Composer<_$AppDatabase, $InstalacionesTable> {
  $$InstalacionesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get costo => $composableBuilder(
    column: $table.costo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pagado => $composableBuilder(
    column: $table.pagado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tecnico => $composableBuilder(
    column: $table.tecnico,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientesTableOrderingComposer get clienteId {
    final $$ClientesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableOrderingComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InstalacionesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstalacionesTable> {
  $$InstalacionesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<int> get costo =>
      $composableBuilder(column: $table.costo, builder: (column) => column);

  GeneratedColumn<bool> get pagado =>
      $composableBuilder(column: $table.pagado, builder: (column) => column);

  GeneratedColumn<String> get tecnico =>
      $composableBuilder(column: $table.tecnico, builder: (column) => column);

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);

  $$ClientesTableAnnotationComposer get clienteId {
    final $$ClientesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableAnnotationComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InstalacionesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InstalacionesTable,
          Instalacion,
          $$InstalacionesTableFilterComposer,
          $$InstalacionesTableOrderingComposer,
          $$InstalacionesTableAnnotationComposer,
          $$InstalacionesTableCreateCompanionBuilder,
          $$InstalacionesTableUpdateCompanionBuilder,
          (Instalacion, $$InstalacionesTableReferences),
          Instalacion,
          PrefetchHooks Function({bool clienteId})
        > {
  $$InstalacionesTableTableManager(_$AppDatabase db, $InstalacionesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstalacionesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstalacionesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InstalacionesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> clienteId = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<int> costo = const Value.absent(),
                Value<bool> pagado = const Value.absent(),
                Value<String?> tecnico = const Value.absent(),
                Value<String?> notas = const Value.absent(),
              }) => InstalacionesCompanion(
                id: id,
                clienteId: clienteId,
                fecha: fecha,
                costo: costo,
                pagado: pagado,
                tecnico: tecnico,
                notas: notas,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int clienteId,
                required DateTime fecha,
                Value<int> costo = const Value.absent(),
                Value<bool> pagado = const Value.absent(),
                Value<String?> tecnico = const Value.absent(),
                Value<String?> notas = const Value.absent(),
              }) => InstalacionesCompanion.insert(
                id: id,
                clienteId: clienteId,
                fecha: fecha,
                costo: costo,
                pagado: pagado,
                tecnico: tecnico,
                notas: notas,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InstalacionesTable, Instalacion>(table),
                  $$InstalacionesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({clienteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (clienteId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.clienteId,
                        referencedTable: $$InstalacionesTableReferences
                            ._clienteIdTable(db),
                        referencedColumn: $$InstalacionesTableReferences
                            ._clienteIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InstalacionesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InstalacionesTable,
      Instalacion,
      $$InstalacionesTableFilterComposer,
      $$InstalacionesTableOrderingComposer,
      $$InstalacionesTableAnnotationComposer,
      $$InstalacionesTableCreateCompanionBuilder,
      $$InstalacionesTableUpdateCompanionBuilder,
      (Instalacion, $$InstalacionesTableReferences),
      Instalacion,
      PrefetchHooks Function({bool clienteId})
    >;
typedef $$EquiposTableCreateCompanionBuilder = EquiposCompanion Function({
  Value<int> id,
  Value<int?> clienteId,
  required String tipo,
  Value<String?> marcaModelo,
  Value<String?> numeroSerie,
  required PropiedadEquipo propiedad,
  Value<int?> costo,
  Value<DateTime?> fechaEntrega,
  Value<DateTime?> fechaRetiro,
  Value<String?> notas,
});
typedef $$EquiposTableUpdateCompanionBuilder = EquiposCompanion Function({
  Value<int> id,
  Value<int?> clienteId,
  Value<String> tipo,
  Value<String?> marcaModelo,
  Value<String?> numeroSerie,
  Value<PropiedadEquipo> propiedad,
  Value<int?> costo,
  Value<DateTime?> fechaEntrega,
  Value<DateTime?> fechaRetiro,
  Value<String?> notas,
});

final class $$EquiposTableReferences
    extends BaseReferences<_$AppDatabase, $EquiposTable, Equipo> {
  $$EquiposTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientesTable _clienteIdTable(_$AppDatabase db) =>
      db.clientes.createAlias('equipos__cliente_id__clientes__id');

  $$ClientesTableProcessedTableManager? get clienteId {
    final $_column = $_itemColumn<int>('cliente_id');
    if ($_column == null) return null;
    final manager = $$ClientesTableTableManager(
      $_db,
      $_db.clientes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clienteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CargosTable, List<Cargo>> _cargosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cargos,
    aliasName: 'equipos__id__cargos__equipo_id',
  );

  $$CargosTableProcessedTableManager get cargosRefs {
    final manager = $$CargosTableTableManager(
      $_db,
      $_db.cargos,
    ).filter((f) => f.equipoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cargosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EquiposTableFilterComposer
    extends Composer<_$AppDatabase, $EquiposTable> {
  $$EquiposTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get marcaModelo => $composableBuilder(
    column: $table.marcaModelo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get numeroSerie => $composableBuilder(
    column: $table.numeroSerie,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PropiedadEquipo, PropiedadEquipo, String>
  get propiedad => $composableBuilder(
    column: $table.propiedad,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get costo => $composableBuilder(
    column: $table.costo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaEntrega => $composableBuilder(
    column: $table.fechaEntrega,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaRetiro => $composableBuilder(
    column: $table.fechaRetiro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnFilters(column),
  );

  $$ClientesTableFilterComposer get clienteId {
    final $$ClientesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableFilterComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> cargosRefs(
    Expression<bool> Function($$CargosTableFilterComposer f) f,
  ) {
    final $$CargosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cargos,
      getReferencedColumn: (t) => t.equipoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CargosTableFilterComposer(
            $db: $db,
            $table: $db.cargos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EquiposTableOrderingComposer
    extends Composer<_$AppDatabase, $EquiposTable> {
  $$EquiposTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get marcaModelo => $composableBuilder(
    column: $table.marcaModelo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get numeroSerie => $composableBuilder(
    column: $table.numeroSerie,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get propiedad => $composableBuilder(
    column: $table.propiedad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get costo => $composableBuilder(
    column: $table.costo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaEntrega => $composableBuilder(
    column: $table.fechaEntrega,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaRetiro => $composableBuilder(
    column: $table.fechaRetiro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientesTableOrderingComposer get clienteId {
    final $$ClientesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableOrderingComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EquiposTableAnnotationComposer
    extends Composer<_$AppDatabase, $EquiposTable> {
  $$EquiposTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get marcaModelo => $composableBuilder(
    column: $table.marcaModelo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get numeroSerie => $composableBuilder(
    column: $table.numeroSerie,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PropiedadEquipo, String> get propiedad =>
      $composableBuilder(column: $table.propiedad, builder: (column) => column);

  GeneratedColumn<int> get costo =>
      $composableBuilder(column: $table.costo, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaEntrega => $composableBuilder(
    column: $table.fechaEntrega,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fechaRetiro => $composableBuilder(
    column: $table.fechaRetiro,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);

  $$ClientesTableAnnotationComposer get clienteId {
    final $$ClientesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableAnnotationComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> cargosRefs<T extends Object>(
    Expression<T> Function($$CargosTableAnnotationComposer a) f,
  ) {
    final $$CargosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cargos,
      getReferencedColumn: (t) => t.equipoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CargosTableAnnotationComposer(
            $db: $db,
            $table: $db.cargos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EquiposTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EquiposTable,
          Equipo,
          $$EquiposTableFilterComposer,
          $$EquiposTableOrderingComposer,
          $$EquiposTableAnnotationComposer,
          $$EquiposTableCreateCompanionBuilder,
          $$EquiposTableUpdateCompanionBuilder,
          (Equipo, $$EquiposTableReferences),
          Equipo,
          PrefetchHooks Function({bool clienteId, bool cargosRefs})
        > {
  $$EquiposTableTableManager(_$AppDatabase db, $EquiposTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EquiposTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EquiposTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EquiposTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> clienteId = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String?> marcaModelo = const Value.absent(),
                Value<String?> numeroSerie = const Value.absent(),
                Value<PropiedadEquipo> propiedad = const Value.absent(),
                Value<int?> costo = const Value.absent(),
                Value<DateTime?> fechaEntrega = const Value.absent(),
                Value<DateTime?> fechaRetiro = const Value.absent(),
                Value<String?> notas = const Value.absent(),
              }) => EquiposCompanion(
                id: id,
                clienteId: clienteId,
                tipo: tipo,
                marcaModelo: marcaModelo,
                numeroSerie: numeroSerie,
                propiedad: propiedad,
                costo: costo,
                fechaEntrega: fechaEntrega,
                fechaRetiro: fechaRetiro,
                notas: notas,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> clienteId = const Value.absent(),
                required String tipo,
                Value<String?> marcaModelo = const Value.absent(),
                Value<String?> numeroSerie = const Value.absent(),
                required PropiedadEquipo propiedad,
                Value<int?> costo = const Value.absent(),
                Value<DateTime?> fechaEntrega = const Value.absent(),
                Value<DateTime?> fechaRetiro = const Value.absent(),
                Value<String?> notas = const Value.absent(),
              }) => EquiposCompanion.insert(
                id: id,
                clienteId: clienteId,
                tipo: tipo,
                marcaModelo: marcaModelo,
                numeroSerie: numeroSerie,
                propiedad: propiedad,
                costo: costo,
                fechaEntrega: fechaEntrega,
                fechaRetiro: fechaRetiro,
                notas: notas,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EquiposTable, Equipo>(table),
                  $$EquiposTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({clienteId = false, cargosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (cargosRefs) db.cargos],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (clienteId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.clienteId,
                        referencedTable: $$EquiposTableReferences
                            ._clienteIdTable(db),
                        referencedColumn: $$EquiposTableReferences
                            ._clienteIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cargosRefs)
                    await $_getPrefetchedDataByColumns<
                      Equipo,
                      $EquiposTable,
                      Cargo,
                      $CargosTable
                    >(
                      currentTable: table,
                      referencedTable: $$EquiposTableReferences
                          ._cargosRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$EquiposTableReferences(db, table, p0).cargosRefs,
                      currentColumn: 'id',
                      referencedColumn: 'equipo_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$EquiposTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EquiposTable,
      Equipo,
      $$EquiposTableFilterComposer,
      $$EquiposTableOrderingComposer,
      $$EquiposTableAnnotationComposer,
      $$EquiposTableCreateCompanionBuilder,
      $$EquiposTableUpdateCompanionBuilder,
      (Equipo, $$EquiposTableReferences),
      Equipo,
      PrefetchHooks Function({bool clienteId, bool cargosRefs})
    >;
typedef $$PeriodosTableCreateCompanionBuilder = PeriodosCompanion Function({
  Value<int> id,
  required int clienteId,
  required String mes,
  required DateTime fechaVencimiento,
  required int monto,
  Value<bool> esCortesia,
});
typedef $$PeriodosTableUpdateCompanionBuilder = PeriodosCompanion Function({
  Value<int> id,
  Value<int> clienteId,
  Value<String> mes,
  Value<DateTime> fechaVencimiento,
  Value<int> monto,
  Value<bool> esCortesia,
});

final class $$PeriodosTableReferences
    extends BaseReferences<_$AppDatabase, $PeriodosTable, PeriodoRow> {
  $$PeriodosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientesTable _clienteIdTable(_$AppDatabase db) =>
      db.clientes.createAlias('periodos__cliente_id__clientes__id');

  $$ClientesTableProcessedTableManager get clienteId {
    final $_column = $_itemColumn<int>('cliente_id')!;

    final manager = $$ClientesTableTableManager(
      $_db,
      $_db.clientes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clienteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PagoAplicacionesTable, List<PagoAplicacion>>
  _pagoAplicacionesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pagoAplicaciones,
    aliasName: 'periodos__id__pago_aplicaciones__periodo_id',
  );

  $$PagoAplicacionesTableProcessedTableManager get pagoAplicacionesRefs {
    final manager = $$PagoAplicacionesTableTableManager(
      $_db,
      $_db.pagoAplicaciones,
    ).filter((f) => f.periodoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _pagoAplicacionesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PeriodosTableFilterComposer
    extends Composer<_$AppDatabase, $PeriodosTable> {
  $$PeriodosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mes => $composableBuilder(
    column: $table.mes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaVencimiento => $composableBuilder(
    column: $table.fechaVencimiento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get esCortesia => $composableBuilder(
    column: $table.esCortesia,
    builder: (column) => ColumnFilters(column),
  );

  $$ClientesTableFilterComposer get clienteId {
    final $$ClientesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableFilterComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> pagoAplicacionesRefs(
    Expression<bool> Function($$PagoAplicacionesTableFilterComposer f) f,
  ) {
    final $$PagoAplicacionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pagoAplicaciones,
      getReferencedColumn: (t) => t.periodoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagoAplicacionesTableFilterComposer(
            $db: $db,
            $table: $db.pagoAplicaciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PeriodosTableOrderingComposer
    extends Composer<_$AppDatabase, $PeriodosTable> {
  $$PeriodosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mes => $composableBuilder(
    column: $table.mes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaVencimiento => $composableBuilder(
    column: $table.fechaVencimiento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get esCortesia => $composableBuilder(
    column: $table.esCortesia,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientesTableOrderingComposer get clienteId {
    final $$ClientesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableOrderingComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PeriodosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeriodosTable> {
  $$PeriodosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mes =>
      $composableBuilder(column: $table.mes, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaVencimiento => $composableBuilder(
    column: $table.fechaVencimiento,
    builder: (column) => column,
  );

  GeneratedColumn<int> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  GeneratedColumn<bool> get esCortesia => $composableBuilder(
    column: $table.esCortesia,
    builder: (column) => column,
  );

  $$ClientesTableAnnotationComposer get clienteId {
    final $$ClientesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableAnnotationComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> pagoAplicacionesRefs<T extends Object>(
    Expression<T> Function($$PagoAplicacionesTableAnnotationComposer a) f,
  ) {
    final $$PagoAplicacionesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pagoAplicaciones,
      getReferencedColumn: (t) => t.periodoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagoAplicacionesTableAnnotationComposer(
            $db: $db,
            $table: $db.pagoAplicaciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PeriodosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PeriodosTable,
          PeriodoRow,
          $$PeriodosTableFilterComposer,
          $$PeriodosTableOrderingComposer,
          $$PeriodosTableAnnotationComposer,
          $$PeriodosTableCreateCompanionBuilder,
          $$PeriodosTableUpdateCompanionBuilder,
          (PeriodoRow, $$PeriodosTableReferences),
          PeriodoRow,
          PrefetchHooks Function({bool clienteId, bool pagoAplicacionesRefs})
        > {
  $$PeriodosTableTableManager(_$AppDatabase db, $PeriodosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeriodosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeriodosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeriodosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> clienteId = const Value.absent(),
                Value<String> mes = const Value.absent(),
                Value<DateTime> fechaVencimiento = const Value.absent(),
                Value<int> monto = const Value.absent(),
                Value<bool> esCortesia = const Value.absent(),
              }) => PeriodosCompanion(
                id: id,
                clienteId: clienteId,
                mes: mes,
                fechaVencimiento: fechaVencimiento,
                monto: monto,
                esCortesia: esCortesia,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int clienteId,
                required String mes,
                required DateTime fechaVencimiento,
                required int monto,
                Value<bool> esCortesia = const Value.absent(),
              }) => PeriodosCompanion.insert(
                id: id,
                clienteId: clienteId,
                mes: mes,
                fechaVencimiento: fechaVencimiento,
                monto: monto,
                esCortesia: esCortesia,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PeriodosTable, PeriodoRow>(table),
                  $$PeriodosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({clienteId = false, pagoAplicacionesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (pagoAplicacionesRefs) db.pagoAplicaciones,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (clienteId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.clienteId,
                            referencedTable: $$PeriodosTableReferences
                                ._clienteIdTable(db),
                            referencedColumn: $$PeriodosTableReferences
                                ._clienteIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (pagoAplicacionesRefs)
                        await $_getPrefetchedDataByColumns<
                          PeriodoRow,
                          $PeriodosTable,
                          PagoAplicacion,
                          $PagoAplicacionesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PeriodosTableReferences
                              ._pagoAplicacionesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PeriodosTableReferences(
                                db,
                                table,
                                p0,
                              ).pagoAplicacionesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'periodo_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PeriodosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PeriodosTable,
      PeriodoRow,
      $$PeriodosTableFilterComposer,
      $$PeriodosTableOrderingComposer,
      $$PeriodosTableAnnotationComposer,
      $$PeriodosTableCreateCompanionBuilder,
      $$PeriodosTableUpdateCompanionBuilder,
      (PeriodoRow, $$PeriodosTableReferences),
      PeriodoRow,
      PrefetchHooks Function({bool clienteId, bool pagoAplicacionesRefs})
    >;
typedef $$PagosTableCreateCompanionBuilder = PagosCompanion Function({
  Value<int> id,
  required int clienteId,
  required DateTime fechaPago,
  required int monto,
  required MetodoPago metodo,
  Value<String?> folio,
  Value<int?> registradoPor,
  Value<bool> cancelado,
  Value<String?> notas,
  Value<DateTime> creadoEn,
});
typedef $$PagosTableUpdateCompanionBuilder = PagosCompanion Function({
  Value<int> id,
  Value<int> clienteId,
  Value<DateTime> fechaPago,
  Value<int> monto,
  Value<MetodoPago> metodo,
  Value<String?> folio,
  Value<int?> registradoPor,
  Value<bool> cancelado,
  Value<String?> notas,
  Value<DateTime> creadoEn,
});

final class $$PagosTableReferences
    extends BaseReferences<_$AppDatabase, $PagosTable, Pago> {
  $$PagosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientesTable _clienteIdTable(_$AppDatabase db) =>
      db.clientes.createAlias('pagos__cliente_id__clientes__id');

  $$ClientesTableProcessedTableManager get clienteId {
    final $_column = $_itemColumn<int>('cliente_id')!;

    final manager = $$ClientesTableTableManager(
      $_db,
      $_db.clientes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clienteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsuariosTable _registradoPorTable(_$AppDatabase db) =>
      db.usuarios.createAlias('pagos__registrado_por__usuarios__id');

  $$UsuariosTableProcessedTableManager? get registradoPor {
    final $_column = $_itemColumn<int>('registrado_por');
    if ($_column == null) return null;
    final manager = $$UsuariosTableTableManager(
      $_db,
      $_db.usuarios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_registradoPorTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PagoAplicacionesTable, List<PagoAplicacion>>
  _pagoAplicacionesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pagoAplicaciones,
    aliasName: 'pagos__id__pago_aplicaciones__pago_id',
  );

  $$PagoAplicacionesTableProcessedTableManager get pagoAplicacionesRefs {
    final manager = $$PagoAplicacionesTableTableManager(
      $_db,
      $_db.pagoAplicaciones,
    ).filter((f) => f.pagoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _pagoAplicacionesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CargoAplicacionesTable, List<CargoAplicacion>>
  _cargoAplicacionesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.cargoAplicaciones,
        aliasName: 'pagos__id__cargo_aplicaciones__pago_id',
      );

  $$CargoAplicacionesTableProcessedTableManager get cargoAplicacionesRefs {
    final manager = $$CargoAplicacionesTableTableManager(
      $_db,
      $_db.cargoAplicaciones,
    ).filter((f) => f.pagoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _cargoAplicacionesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PagosTableFilterComposer extends Composer<_$AppDatabase, $PagosTable> {
  $$PagosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaPago => $composableBuilder(
    column: $table.fechaPago,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MetodoPago, MetodoPago, String> get metodo =>
      $composableBuilder(
        column: $table.metodo,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get folio => $composableBuilder(
    column: $table.folio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get cancelado => $composableBuilder(
    column: $table.cancelado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  $$ClientesTableFilterComposer get clienteId {
    final $$ClientesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableFilterComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableFilterComposer get registradoPor {
    final $$UsuariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.registradoPor,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableFilterComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> pagoAplicacionesRefs(
    Expression<bool> Function($$PagoAplicacionesTableFilterComposer f) f,
  ) {
    final $$PagoAplicacionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pagoAplicaciones,
      getReferencedColumn: (t) => t.pagoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagoAplicacionesTableFilterComposer(
            $db: $db,
            $table: $db.pagoAplicaciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cargoAplicacionesRefs(
    Expression<bool> Function($$CargoAplicacionesTableFilterComposer f) f,
  ) {
    final $$CargoAplicacionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cargoAplicaciones,
      getReferencedColumn: (t) => t.pagoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CargoAplicacionesTableFilterComposer(
            $db: $db,
            $table: $db.cargoAplicaciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PagosTableOrderingComposer
    extends Composer<_$AppDatabase, $PagosTable> {
  $$PagosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaPago => $composableBuilder(
    column: $table.fechaPago,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metodo => $composableBuilder(
    column: $table.metodo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folio => $composableBuilder(
    column: $table.folio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get cancelado => $composableBuilder(
    column: $table.cancelado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientesTableOrderingComposer get clienteId {
    final $$ClientesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableOrderingComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableOrderingComposer get registradoPor {
    final $$UsuariosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.registradoPor,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableOrderingComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PagosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PagosTable> {
  $$PagosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaPago =>
      $composableBuilder(column: $table.fechaPago, builder: (column) => column);

  GeneratedColumn<int> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MetodoPago, String> get metodo =>
      $composableBuilder(column: $table.metodo, builder: (column) => column);

  GeneratedColumn<String> get folio =>
      $composableBuilder(column: $table.folio, builder: (column) => column);

  GeneratedColumn<bool> get cancelado =>
      $composableBuilder(column: $table.cancelado, builder: (column) => column);

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  $$ClientesTableAnnotationComposer get clienteId {
    final $$ClientesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableAnnotationComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableAnnotationComposer get registradoPor {
    final $$UsuariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.registradoPor,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableAnnotationComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> pagoAplicacionesRefs<T extends Object>(
    Expression<T> Function($$PagoAplicacionesTableAnnotationComposer a) f,
  ) {
    final $$PagoAplicacionesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pagoAplicaciones,
      getReferencedColumn: (t) => t.pagoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagoAplicacionesTableAnnotationComposer(
            $db: $db,
            $table: $db.pagoAplicaciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cargoAplicacionesRefs<T extends Object>(
    Expression<T> Function($$CargoAplicacionesTableAnnotationComposer a) f,
  ) {
    final $$CargoAplicacionesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.cargoAplicaciones,
          getReferencedColumn: (t) => t.pagoId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CargoAplicacionesTableAnnotationComposer(
                $db: $db,
                $table: $db.cargoAplicaciones,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PagosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PagosTable,
          Pago,
          $$PagosTableFilterComposer,
          $$PagosTableOrderingComposer,
          $$PagosTableAnnotationComposer,
          $$PagosTableCreateCompanionBuilder,
          $$PagosTableUpdateCompanionBuilder,
          (Pago, $$PagosTableReferences),
          Pago,
          PrefetchHooks Function({
            bool clienteId,
            bool registradoPor,
            bool pagoAplicacionesRefs,
            bool cargoAplicacionesRefs,
          })
        > {
  $$PagosTableTableManager(_$AppDatabase db, $PagosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PagosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PagosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PagosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> clienteId = const Value.absent(),
                Value<DateTime> fechaPago = const Value.absent(),
                Value<int> monto = const Value.absent(),
                Value<MetodoPago> metodo = const Value.absent(),
                Value<String?> folio = const Value.absent(),
                Value<int?> registradoPor = const Value.absent(),
                Value<bool> cancelado = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => PagosCompanion(
                id: id,
                clienteId: clienteId,
                fechaPago: fechaPago,
                monto: monto,
                metodo: metodo,
                folio: folio,
                registradoPor: registradoPor,
                cancelado: cancelado,
                notas: notas,
                creadoEn: creadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int clienteId,
                required DateTime fechaPago,
                required int monto,
                required MetodoPago metodo,
                Value<String?> folio = const Value.absent(),
                Value<int?> registradoPor = const Value.absent(),
                Value<bool> cancelado = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => PagosCompanion.insert(
                id: id,
                clienteId: clienteId,
                fechaPago: fechaPago,
                monto: monto,
                metodo: metodo,
                folio: folio,
                registradoPor: registradoPor,
                cancelado: cancelado,
                notas: notas,
                creadoEn: creadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PagosTable, Pago>(table),
                  $$PagosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                clienteId = false,
                registradoPor = false,
                pagoAplicacionesRefs = false,
                cargoAplicacionesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (pagoAplicacionesRefs) db.pagoAplicaciones,
                    if (cargoAplicacionesRefs) db.cargoAplicaciones,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (clienteId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.clienteId,
                            referencedTable: $$PagosTableReferences
                                ._clienteIdTable(db),
                            referencedColumn: $$PagosTableReferences
                                ._clienteIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (registradoPor) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.registradoPor,
                            referencedTable: $$PagosTableReferences
                                ._registradoPorTable(db),
                            referencedColumn: $$PagosTableReferences
                                ._registradoPorTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (pagoAplicacionesRefs)
                        await $_getPrefetchedDataByColumns<
                          Pago,
                          $PagosTable,
                          PagoAplicacion,
                          $PagoAplicacionesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PagosTableReferences
                              ._pagoAplicacionesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PagosTableReferences(
                                db,
                                table,
                                p0,
                              ).pagoAplicacionesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'pago_id',
                          typedResults: items,
                        ),
                      if (cargoAplicacionesRefs)
                        await $_getPrefetchedDataByColumns<
                          Pago,
                          $PagosTable,
                          CargoAplicacion,
                          $CargoAplicacionesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PagosTableReferences
                              ._cargoAplicacionesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PagosTableReferences(
                                db,
                                table,
                                p0,
                              ).cargoAplicacionesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'pago_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PagosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PagosTable,
      Pago,
      $$PagosTableFilterComposer,
      $$PagosTableOrderingComposer,
      $$PagosTableAnnotationComposer,
      $$PagosTableCreateCompanionBuilder,
      $$PagosTableUpdateCompanionBuilder,
      (Pago, $$PagosTableReferences),
      Pago,
      PrefetchHooks Function({
        bool clienteId,
        bool registradoPor,
        bool pagoAplicacionesRefs,
        bool cargoAplicacionesRefs,
      })
    >;
typedef $$PagoAplicacionesTableCreateCompanionBuilder =
    PagoAplicacionesCompanion Function({
      required int pagoId,
      required int periodoId,
      required int monto,
      Value<int> rowid,
    });
typedef $$PagoAplicacionesTableUpdateCompanionBuilder =
    PagoAplicacionesCompanion Function({
      Value<int> pagoId,
      Value<int> periodoId,
      Value<int> monto,
      Value<int> rowid,
    });

final class $$PagoAplicacionesTableReferences
    extends
        BaseReferences<_$AppDatabase, $PagoAplicacionesTable, PagoAplicacion> {
  $$PagoAplicacionesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PagosTable _pagoIdTable(_$AppDatabase db) =>
      db.pagos.createAlias('pago_aplicaciones__pago_id__pagos__id');

  $$PagosTableProcessedTableManager get pagoId {
    final $_column = $_itemColumn<int>('pago_id')!;

    final manager = $$PagosTableTableManager(
      $_db,
      $_db.pagos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pagoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PeriodosTable _periodoIdTable(_$AppDatabase db) =>
      db.periodos.createAlias('pago_aplicaciones__periodo_id__periodos__id');

  $$PeriodosTableProcessedTableManager get periodoId {
    final $_column = $_itemColumn<int>('periodo_id')!;

    final manager = $$PeriodosTableTableManager(
      $_db,
      $_db.periodos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_periodoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PagoAplicacionesTableFilterComposer
    extends Composer<_$AppDatabase, $PagoAplicacionesTable> {
  $$PagoAplicacionesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnFilters(column),
  );

  $$PagosTableFilterComposer get pagoId {
    final $$PagosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pagoId,
      referencedTable: $db.pagos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagosTableFilterComposer(
            $db: $db,
            $table: $db.pagos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PeriodosTableFilterComposer get periodoId {
    final $$PeriodosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodoId,
      referencedTable: $db.periodos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodosTableFilterComposer(
            $db: $db,
            $table: $db.periodos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PagoAplicacionesTableOrderingComposer
    extends Composer<_$AppDatabase, $PagoAplicacionesTable> {
  $$PagoAplicacionesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnOrderings(column),
  );

  $$PagosTableOrderingComposer get pagoId {
    final $$PagosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pagoId,
      referencedTable: $db.pagos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagosTableOrderingComposer(
            $db: $db,
            $table: $db.pagos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PeriodosTableOrderingComposer get periodoId {
    final $$PeriodosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodoId,
      referencedTable: $db.periodos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodosTableOrderingComposer(
            $db: $db,
            $table: $db.periodos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PagoAplicacionesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PagoAplicacionesTable> {
  $$PagoAplicacionesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  $$PagosTableAnnotationComposer get pagoId {
    final $$PagosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pagoId,
      referencedTable: $db.pagos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagosTableAnnotationComposer(
            $db: $db,
            $table: $db.pagos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PeriodosTableAnnotationComposer get periodoId {
    final $$PeriodosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodoId,
      referencedTable: $db.periodos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodosTableAnnotationComposer(
            $db: $db,
            $table: $db.periodos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PagoAplicacionesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PagoAplicacionesTable,
          PagoAplicacion,
          $$PagoAplicacionesTableFilterComposer,
          $$PagoAplicacionesTableOrderingComposer,
          $$PagoAplicacionesTableAnnotationComposer,
          $$PagoAplicacionesTableCreateCompanionBuilder,
          $$PagoAplicacionesTableUpdateCompanionBuilder,
          (PagoAplicacion, $$PagoAplicacionesTableReferences),
          PagoAplicacion,
          PrefetchHooks Function({bool pagoId, bool periodoId})
        > {
  $$PagoAplicacionesTableTableManager(
    _$AppDatabase db,
    $PagoAplicacionesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PagoAplicacionesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PagoAplicacionesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PagoAplicacionesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> pagoId = const Value.absent(),
                Value<int> periodoId = const Value.absent(),
                Value<int> monto = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PagoAplicacionesCompanion(
                pagoId: pagoId,
                periodoId: periodoId,
                monto: monto,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int pagoId,
                required int periodoId,
                required int monto,
                Value<int> rowid = const Value.absent(),
              }) => PagoAplicacionesCompanion.insert(
                pagoId: pagoId,
                periodoId: periodoId,
                monto: monto,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PagoAplicacionesTable, PagoAplicacion>(table),
                  $$PagoAplicacionesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pagoId = false, periodoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pagoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.pagoId,
                        referencedTable: $$PagoAplicacionesTableReferences
                            ._pagoIdTable(db),
                        referencedColumn: $$PagoAplicacionesTableReferences
                            ._pagoIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (periodoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.periodoId,
                        referencedTable: $$PagoAplicacionesTableReferences
                            ._periodoIdTable(db),
                        referencedColumn: $$PagoAplicacionesTableReferences
                            ._periodoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PagoAplicacionesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PagoAplicacionesTable,
      PagoAplicacion,
      $$PagoAplicacionesTableFilterComposer,
      $$PagoAplicacionesTableOrderingComposer,
      $$PagoAplicacionesTableAnnotationComposer,
      $$PagoAplicacionesTableCreateCompanionBuilder,
      $$PagoAplicacionesTableUpdateCompanionBuilder,
      (PagoAplicacion, $$PagoAplicacionesTableReferences),
      PagoAplicacion,
      PrefetchHooks Function({bool pagoId, bool periodoId})
    >;
typedef $$CargosTableCreateCompanionBuilder = CargosCompanion Function({
  Value<int> id,
  required int clienteId,
  required DateTime fecha,
  required String concepto,
  required int monto,
  Value<int?> equipoId,
  Value<bool> cancelado,
  Value<String?> notas,
  required DateTime creadoEn,
});
typedef $$CargosTableUpdateCompanionBuilder = CargosCompanion Function({
  Value<int> id,
  Value<int> clienteId,
  Value<DateTime> fecha,
  Value<String> concepto,
  Value<int> monto,
  Value<int?> equipoId,
  Value<bool> cancelado,
  Value<String?> notas,
  Value<DateTime> creadoEn,
});

final class $$CargosTableReferences
    extends BaseReferences<_$AppDatabase, $CargosTable, Cargo> {
  $$CargosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientesTable _clienteIdTable(_$AppDatabase db) =>
      db.clientes.createAlias('cargos__cliente_id__clientes__id');

  $$ClientesTableProcessedTableManager get clienteId {
    final $_column = $_itemColumn<int>('cliente_id')!;

    final manager = $$ClientesTableTableManager(
      $_db,
      $_db.clientes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clienteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EquiposTable _equipoIdTable(_$AppDatabase db) =>
      db.equipos.createAlias('cargos__equipo_id__equipos__id');

  $$EquiposTableProcessedTableManager? get equipoId {
    final $_column = $_itemColumn<int>('equipo_id');
    if ($_column == null) return null;
    final manager = $$EquiposTableTableManager(
      $_db,
      $_db.equipos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_equipoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CargoAplicacionesTable, List<CargoAplicacion>>
  _cargoAplicacionesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.cargoAplicaciones,
        aliasName: 'cargos__id__cargo_aplicaciones__cargo_id',
      );

  $$CargoAplicacionesTableProcessedTableManager get cargoAplicacionesRefs {
    final manager = $$CargoAplicacionesTableTableManager(
      $_db,
      $_db.cargoAplicaciones,
    ).filter((f) => f.cargoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _cargoAplicacionesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CargosTableFilterComposer
    extends Composer<_$AppDatabase, $CargosTable> {
  $$CargosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get concepto => $composableBuilder(
    column: $table.concepto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get cancelado => $composableBuilder(
    column: $table.cancelado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  $$ClientesTableFilterComposer get clienteId {
    final $$ClientesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableFilterComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquiposTableFilterComposer get equipoId {
    final $$EquiposTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipoId,
      referencedTable: $db.equipos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquiposTableFilterComposer(
            $db: $db,
            $table: $db.equipos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> cargoAplicacionesRefs(
    Expression<bool> Function($$CargoAplicacionesTableFilterComposer f) f,
  ) {
    final $$CargoAplicacionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cargoAplicaciones,
      getReferencedColumn: (t) => t.cargoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CargoAplicacionesTableFilterComposer(
            $db: $db,
            $table: $db.cargoAplicaciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CargosTableOrderingComposer
    extends Composer<_$AppDatabase, $CargosTable> {
  $$CargosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get concepto => $composableBuilder(
    column: $table.concepto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get cancelado => $composableBuilder(
    column: $table.cancelado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientesTableOrderingComposer get clienteId {
    final $$ClientesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableOrderingComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquiposTableOrderingComposer get equipoId {
    final $$EquiposTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipoId,
      referencedTable: $db.equipos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquiposTableOrderingComposer(
            $db: $db,
            $table: $db.equipos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CargosTableAnnotationComposer
    extends Composer<_$AppDatabase, $CargosTable> {
  $$CargosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get concepto =>
      $composableBuilder(column: $table.concepto, builder: (column) => column);

  GeneratedColumn<int> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  GeneratedColumn<bool> get cancelado =>
      $composableBuilder(column: $table.cancelado, builder: (column) => column);

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  $$ClientesTableAnnotationComposer get clienteId {
    final $$ClientesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableAnnotationComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquiposTableAnnotationComposer get equipoId {
    final $$EquiposTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipoId,
      referencedTable: $db.equipos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquiposTableAnnotationComposer(
            $db: $db,
            $table: $db.equipos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> cargoAplicacionesRefs<T extends Object>(
    Expression<T> Function($$CargoAplicacionesTableAnnotationComposer a) f,
  ) {
    final $$CargoAplicacionesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.cargoAplicaciones,
          getReferencedColumn: (t) => t.cargoId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CargoAplicacionesTableAnnotationComposer(
                $db: $db,
                $table: $db.cargoAplicaciones,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CargosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CargosTable,
          Cargo,
          $$CargosTableFilterComposer,
          $$CargosTableOrderingComposer,
          $$CargosTableAnnotationComposer,
          $$CargosTableCreateCompanionBuilder,
          $$CargosTableUpdateCompanionBuilder,
          (Cargo, $$CargosTableReferences),
          Cargo,
          PrefetchHooks Function({
            bool clienteId,
            bool equipoId,
            bool cargoAplicacionesRefs,
          })
        > {
  $$CargosTableTableManager(_$AppDatabase db, $CargosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CargosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CargosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CargosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> clienteId = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<String> concepto = const Value.absent(),
                Value<int> monto = const Value.absent(),
                Value<int?> equipoId = const Value.absent(),
                Value<bool> cancelado = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => CargosCompanion(
                id: id,
                clienteId: clienteId,
                fecha: fecha,
                concepto: concepto,
                monto: monto,
                equipoId: equipoId,
                cancelado: cancelado,
                notas: notas,
                creadoEn: creadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int clienteId,
                required DateTime fecha,
                required String concepto,
                required int monto,
                Value<int?> equipoId = const Value.absent(),
                Value<bool> cancelado = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                required DateTime creadoEn,
              }) => CargosCompanion.insert(
                id: id,
                clienteId: clienteId,
                fecha: fecha,
                concepto: concepto,
                monto: monto,
                equipoId: equipoId,
                cancelado: cancelado,
                notas: notas,
                creadoEn: creadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CargosTable, Cargo>(table),
                  $$CargosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                clienteId = false,
                equipoId = false,
                cargoAplicacionesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (cargoAplicacionesRefs) db.cargoAplicaciones,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (clienteId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.clienteId,
                            referencedTable: $$CargosTableReferences
                                ._clienteIdTable(db),
                            referencedColumn: $$CargosTableReferences
                                ._clienteIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (equipoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.equipoId,
                            referencedTable: $$CargosTableReferences
                                ._equipoIdTable(db),
                            referencedColumn: $$CargosTableReferences
                                ._equipoIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (cargoAplicacionesRefs)
                        await $_getPrefetchedDataByColumns<
                          Cargo,
                          $CargosTable,
                          CargoAplicacion,
                          $CargoAplicacionesTable
                        >(
                          currentTable: table,
                          referencedTable: $$CargosTableReferences
                              ._cargoAplicacionesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CargosTableReferences(
                                db,
                                table,
                                p0,
                              ).cargoAplicacionesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'cargo_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CargosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CargosTable,
      Cargo,
      $$CargosTableFilterComposer,
      $$CargosTableOrderingComposer,
      $$CargosTableAnnotationComposer,
      $$CargosTableCreateCompanionBuilder,
      $$CargosTableUpdateCompanionBuilder,
      (Cargo, $$CargosTableReferences),
      Cargo,
      PrefetchHooks Function({
        bool clienteId,
        bool equipoId,
        bool cargoAplicacionesRefs,
      })
    >;
typedef $$CargoAplicacionesTableCreateCompanionBuilder =
    CargoAplicacionesCompanion Function({
      required int pagoId,
      required int cargoId,
      required int monto,
      Value<int> rowid,
    });
typedef $$CargoAplicacionesTableUpdateCompanionBuilder =
    CargoAplicacionesCompanion Function({
      Value<int> pagoId,
      Value<int> cargoId,
      Value<int> monto,
      Value<int> rowid,
    });

final class $$CargoAplicacionesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CargoAplicacionesTable,
          CargoAplicacion
        > {
  $$CargoAplicacionesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PagosTable _pagoIdTable(_$AppDatabase db) =>
      db.pagos.createAlias('cargo_aplicaciones__pago_id__pagos__id');

  $$PagosTableProcessedTableManager get pagoId {
    final $_column = $_itemColumn<int>('pago_id')!;

    final manager = $$PagosTableTableManager(
      $_db,
      $_db.pagos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pagoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CargosTable _cargoIdTable(_$AppDatabase db) =>
      db.cargos.createAlias('cargo_aplicaciones__cargo_id__cargos__id');

  $$CargosTableProcessedTableManager get cargoId {
    final $_column = $_itemColumn<int>('cargo_id')!;

    final manager = $$CargosTableTableManager(
      $_db,
      $_db.cargos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cargoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CargoAplicacionesTableFilterComposer
    extends Composer<_$AppDatabase, $CargoAplicacionesTable> {
  $$CargoAplicacionesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnFilters(column),
  );

  $$PagosTableFilterComposer get pagoId {
    final $$PagosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pagoId,
      referencedTable: $db.pagos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagosTableFilterComposer(
            $db: $db,
            $table: $db.pagos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CargosTableFilterComposer get cargoId {
    final $$CargosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cargoId,
      referencedTable: $db.cargos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CargosTableFilterComposer(
            $db: $db,
            $table: $db.cargos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CargoAplicacionesTableOrderingComposer
    extends Composer<_$AppDatabase, $CargoAplicacionesTable> {
  $$CargoAplicacionesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnOrderings(column),
  );

  $$PagosTableOrderingComposer get pagoId {
    final $$PagosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pagoId,
      referencedTable: $db.pagos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagosTableOrderingComposer(
            $db: $db,
            $table: $db.pagos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CargosTableOrderingComposer get cargoId {
    final $$CargosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cargoId,
      referencedTable: $db.cargos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CargosTableOrderingComposer(
            $db: $db,
            $table: $db.cargos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CargoAplicacionesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CargoAplicacionesTable> {
  $$CargoAplicacionesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  $$PagosTableAnnotationComposer get pagoId {
    final $$PagosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pagoId,
      referencedTable: $db.pagos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagosTableAnnotationComposer(
            $db: $db,
            $table: $db.pagos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CargosTableAnnotationComposer get cargoId {
    final $$CargosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cargoId,
      referencedTable: $db.cargos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CargosTableAnnotationComposer(
            $db: $db,
            $table: $db.cargos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CargoAplicacionesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CargoAplicacionesTable,
          CargoAplicacion,
          $$CargoAplicacionesTableFilterComposer,
          $$CargoAplicacionesTableOrderingComposer,
          $$CargoAplicacionesTableAnnotationComposer,
          $$CargoAplicacionesTableCreateCompanionBuilder,
          $$CargoAplicacionesTableUpdateCompanionBuilder,
          (CargoAplicacion, $$CargoAplicacionesTableReferences),
          CargoAplicacion,
          PrefetchHooks Function({bool pagoId, bool cargoId})
        > {
  $$CargoAplicacionesTableTableManager(
    _$AppDatabase db,
    $CargoAplicacionesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CargoAplicacionesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CargoAplicacionesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CargoAplicacionesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> pagoId = const Value.absent(),
                Value<int> cargoId = const Value.absent(),
                Value<int> monto = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CargoAplicacionesCompanion(
                pagoId: pagoId,
                cargoId: cargoId,
                monto: monto,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int pagoId,
                required int cargoId,
                required int monto,
                Value<int> rowid = const Value.absent(),
              }) => CargoAplicacionesCompanion.insert(
                pagoId: pagoId,
                cargoId: cargoId,
                monto: monto,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CargoAplicacionesTable, CargoAplicacion>(table),
                  $$CargoAplicacionesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pagoId = false, cargoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pagoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.pagoId,
                        referencedTable: $$CargoAplicacionesTableReferences
                            ._pagoIdTable(db),
                        referencedColumn: $$CargoAplicacionesTableReferences
                            ._pagoIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (cargoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cargoId,
                        referencedTable: $$CargoAplicacionesTableReferences
                            ._cargoIdTable(db),
                        referencedColumn: $$CargoAplicacionesTableReferences
                            ._cargoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CargoAplicacionesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CargoAplicacionesTable,
      CargoAplicacion,
      $$CargoAplicacionesTableFilterComposer,
      $$CargoAplicacionesTableOrderingComposer,
      $$CargoAplicacionesTableAnnotationComposer,
      $$CargoAplicacionesTableCreateCompanionBuilder,
      $$CargoAplicacionesTableUpdateCompanionBuilder,
      (CargoAplicacion, $$CargoAplicacionesTableReferences),
      CargoAplicacion,
      PrefetchHooks Function({bool pagoId, bool cargoId})
    >;
typedef $$HistorialEstadosTableCreateCompanionBuilder =
    HistorialEstadosCompanion Function({
      Value<int> id,
      required int clienteId,
      Value<EstadoCliente?> estadoAnterior,
      required EstadoCliente estadoNuevo,
      Value<String?> motivo,
      Value<int?> usuarioId,
      Value<DateTime> fecha,
    });
typedef $$HistorialEstadosTableUpdateCompanionBuilder =
    HistorialEstadosCompanion Function({
      Value<int> id,
      Value<int> clienteId,
      Value<EstadoCliente?> estadoAnterior,
      Value<EstadoCliente> estadoNuevo,
      Value<String?> motivo,
      Value<int?> usuarioId,
      Value<DateTime> fecha,
    });

final class $$HistorialEstadosTableReferences
    extends
        BaseReferences<_$AppDatabase, $HistorialEstadosTable, HistorialEstado> {
  $$HistorialEstadosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ClientesTable _clienteIdTable(_$AppDatabase db) =>
      db.clientes.createAlias('historial_estados__cliente_id__clientes__id');

  $$ClientesTableProcessedTableManager get clienteId {
    final $_column = $_itemColumn<int>('cliente_id')!;

    final manager = $$ClientesTableTableManager(
      $_db,
      $_db.clientes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clienteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsuariosTable _usuarioIdTable(_$AppDatabase db) =>
      db.usuarios.createAlias('historial_estados__usuario_id__usuarios__id');

  $$UsuariosTableProcessedTableManager? get usuarioId {
    final $_column = $_itemColumn<int>('usuario_id');
    if ($_column == null) return null;
    final manager = $$UsuariosTableTableManager(
      $_db,
      $_db.usuarios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_usuarioIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HistorialEstadosTableFilterComposer
    extends Composer<_$AppDatabase, $HistorialEstadosTable> {
  $$HistorialEstadosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EstadoCliente?, EstadoCliente, String>
  get estadoAnterior => $composableBuilder(
    column: $table.estadoAnterior,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<EstadoCliente, EstadoCliente, String>
  get estadoNuevo => $composableBuilder(
    column: $table.estadoNuevo,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get motivo => $composableBuilder(
    column: $table.motivo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  $$ClientesTableFilterComposer get clienteId {
    final $$ClientesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableFilterComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableFilterComposer get usuarioId {
    final $$UsuariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableFilterComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HistorialEstadosTableOrderingComposer
    extends Composer<_$AppDatabase, $HistorialEstadosTable> {
  $$HistorialEstadosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estadoAnterior => $composableBuilder(
    column: $table.estadoAnterior,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estadoNuevo => $composableBuilder(
    column: $table.estadoNuevo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motivo => $composableBuilder(
    column: $table.motivo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientesTableOrderingComposer get clienteId {
    final $$ClientesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableOrderingComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableOrderingComposer get usuarioId {
    final $$UsuariosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableOrderingComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HistorialEstadosTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistorialEstadosTable> {
  $$HistorialEstadosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EstadoCliente?, String> get estadoAnterior =>
      $composableBuilder(
        column: $table.estadoAnterior,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<EstadoCliente, String> get estadoNuevo =>
      $composableBuilder(
        column: $table.estadoNuevo,
        builder: (column) => column,
      );

  GeneratedColumn<String> get motivo =>
      $composableBuilder(column: $table.motivo, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  $$ClientesTableAnnotationComposer get clienteId {
    final $$ClientesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableAnnotationComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableAnnotationComposer get usuarioId {
    final $$UsuariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableAnnotationComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HistorialEstadosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HistorialEstadosTable,
          HistorialEstado,
          $$HistorialEstadosTableFilterComposer,
          $$HistorialEstadosTableOrderingComposer,
          $$HistorialEstadosTableAnnotationComposer,
          $$HistorialEstadosTableCreateCompanionBuilder,
          $$HistorialEstadosTableUpdateCompanionBuilder,
          (HistorialEstado, $$HistorialEstadosTableReferences),
          HistorialEstado,
          PrefetchHooks Function({bool clienteId, bool usuarioId})
        > {
  $$HistorialEstadosTableTableManager(
    _$AppDatabase db,
    $HistorialEstadosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistorialEstadosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistorialEstadosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistorialEstadosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> clienteId = const Value.absent(),
                Value<EstadoCliente?> estadoAnterior = const Value.absent(),
                Value<EstadoCliente> estadoNuevo = const Value.absent(),
                Value<String?> motivo = const Value.absent(),
                Value<int?> usuarioId = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
              }) => HistorialEstadosCompanion(
                id: id,
                clienteId: clienteId,
                estadoAnterior: estadoAnterior,
                estadoNuevo: estadoNuevo,
                motivo: motivo,
                usuarioId: usuarioId,
                fecha: fecha,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int clienteId,
                Value<EstadoCliente?> estadoAnterior = const Value.absent(),
                required EstadoCliente estadoNuevo,
                Value<String?> motivo = const Value.absent(),
                Value<int?> usuarioId = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
              }) => HistorialEstadosCompanion.insert(
                id: id,
                clienteId: clienteId,
                estadoAnterior: estadoAnterior,
                estadoNuevo: estadoNuevo,
                motivo: motivo,
                usuarioId: usuarioId,
                fecha: fecha,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HistorialEstadosTable, HistorialEstado>(table),
                  $$HistorialEstadosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({clienteId = false, usuarioId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (clienteId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.clienteId,
                        referencedTable: $$HistorialEstadosTableReferences
                            ._clienteIdTable(db),
                        referencedColumn: $$HistorialEstadosTableReferences
                            ._clienteIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (usuarioId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.usuarioId,
                        referencedTable: $$HistorialEstadosTableReferences
                            ._usuarioIdTable(db),
                        referencedColumn: $$HistorialEstadosTableReferences
                            ._usuarioIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HistorialEstadosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HistorialEstadosTable,
      HistorialEstado,
      $$HistorialEstadosTableFilterComposer,
      $$HistorialEstadosTableOrderingComposer,
      $$HistorialEstadosTableAnnotationComposer,
      $$HistorialEstadosTableCreateCompanionBuilder,
      $$HistorialEstadosTableUpdateCompanionBuilder,
      (HistorialEstado, $$HistorialEstadosTableReferences),
      HistorialEstado,
      PrefetchHooks Function({bool clienteId, bool usuarioId})
    >;
typedef $$GastosTableCreateCompanionBuilder = GastosCompanion Function({
  Value<int> id,
  required DateTime fecha,
  required String concepto,
  Value<String?> categoria,
  required int monto,
  Value<int?> usuarioId,
  Value<String?> notas,
});
typedef $$GastosTableUpdateCompanionBuilder = GastosCompanion Function({
  Value<int> id,
  Value<DateTime> fecha,
  Value<String> concepto,
  Value<String?> categoria,
  Value<int> monto,
  Value<int?> usuarioId,
  Value<String?> notas,
});

final class $$GastosTableReferences
    extends BaseReferences<_$AppDatabase, $GastosTable, Gasto> {
  $$GastosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsuariosTable _usuarioIdTable(_$AppDatabase db) =>
      db.usuarios.createAlias('gastos__usuario_id__usuarios__id');

  $$UsuariosTableProcessedTableManager? get usuarioId {
    final $_column = $_itemColumn<int>('usuario_id');
    if ($_column == null) return null;
    final manager = $$UsuariosTableTableManager(
      $_db,
      $_db.usuarios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_usuarioIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GastosTableFilterComposer
    extends Composer<_$AppDatabase, $GastosTable> {
  $$GastosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get concepto => $composableBuilder(
    column: $table.concepto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnFilters(column),
  );

  $$UsuariosTableFilterComposer get usuarioId {
    final $$UsuariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableFilterComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GastosTableOrderingComposer
    extends Composer<_$AppDatabase, $GastosTable> {
  $$GastosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get concepto => $composableBuilder(
    column: $table.concepto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsuariosTableOrderingComposer get usuarioId {
    final $$UsuariosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableOrderingComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GastosTableAnnotationComposer
    extends Composer<_$AppDatabase, $GastosTable> {
  $$GastosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get concepto =>
      $composableBuilder(column: $table.concepto, builder: (column) => column);

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<int> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);

  $$UsuariosTableAnnotationComposer get usuarioId {
    final $$UsuariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableAnnotationComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GastosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GastosTable,
          Gasto,
          $$GastosTableFilterComposer,
          $$GastosTableOrderingComposer,
          $$GastosTableAnnotationComposer,
          $$GastosTableCreateCompanionBuilder,
          $$GastosTableUpdateCompanionBuilder,
          (Gasto, $$GastosTableReferences),
          Gasto,
          PrefetchHooks Function({bool usuarioId})
        > {
  $$GastosTableTableManager(_$AppDatabase db, $GastosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GastosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GastosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GastosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<String> concepto = const Value.absent(),
                Value<String?> categoria = const Value.absent(),
                Value<int> monto = const Value.absent(),
                Value<int?> usuarioId = const Value.absent(),
                Value<String?> notas = const Value.absent(),
              }) => GastosCompanion(
                id: id,
                fecha: fecha,
                concepto: concepto,
                categoria: categoria,
                monto: monto,
                usuarioId: usuarioId,
                notas: notas,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime fecha,
                required String concepto,
                Value<String?> categoria = const Value.absent(),
                required int monto,
                Value<int?> usuarioId = const Value.absent(),
                Value<String?> notas = const Value.absent(),
              }) => GastosCompanion.insert(
                id: id,
                fecha: fecha,
                concepto: concepto,
                categoria: categoria,
                monto: monto,
                usuarioId: usuarioId,
                notas: notas,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GastosTable, Gasto>(table),
                  $$GastosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({usuarioId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (usuarioId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.usuarioId,
                        referencedTable: $$GastosTableReferences
                            ._usuarioIdTable(db),
                        referencedColumn: $$GastosTableReferences
                            ._usuarioIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GastosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GastosTable,
      Gasto,
      $$GastosTableFilterComposer,
      $$GastosTableOrderingComposer,
      $$GastosTableAnnotationComposer,
      $$GastosTableCreateCompanionBuilder,
      $$GastosTableUpdateCompanionBuilder,
      (Gasto, $$GastosTableReferences),
      Gasto,
      PrefetchHooks Function({bool usuarioId})
    >;
typedef $$ConfiguracionesTableCreateCompanionBuilder =
    ConfiguracionesCompanion Function({
      required String clave,
      required String valor,
      Value<int> rowid,
    });
typedef $$ConfiguracionesTableUpdateCompanionBuilder =
    ConfiguracionesCompanion Function({
      Value<String> clave,
      Value<String> valor,
      Value<int> rowid,
    });

class $$ConfiguracionesTableFilterComposer
    extends Composer<_$AppDatabase, $ConfiguracionesTable> {
  $$ConfiguracionesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clave => $composableBuilder(
    column: $table.clave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConfiguracionesTableOrderingComposer
    extends Composer<_$AppDatabase, $ConfiguracionesTable> {
  $$ConfiguracionesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clave => $composableBuilder(
    column: $table.clave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConfiguracionesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConfiguracionesTable> {
  $$ConfiguracionesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clave =>
      $composableBuilder(column: $table.clave, builder: (column) => column);

  GeneratedColumn<String> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);
}

class $$ConfiguracionesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConfiguracionesTable,
          ConfigItem,
          $$ConfiguracionesTableFilterComposer,
          $$ConfiguracionesTableOrderingComposer,
          $$ConfiguracionesTableAnnotationComposer,
          $$ConfiguracionesTableCreateCompanionBuilder,
          $$ConfiguracionesTableUpdateCompanionBuilder,
          (
            ConfigItem,
            BaseReferences<_$AppDatabase, $ConfiguracionesTable, ConfigItem>,
          ),
          ConfigItem,
          PrefetchHooks Function()
        > {
  $$ConfiguracionesTableTableManager(
    _$AppDatabase db,
    $ConfiguracionesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConfiguracionesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConfiguracionesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConfiguracionesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clave = const Value.absent(),
                Value<String> valor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConfiguracionesCompanion(
                clave: clave,
                valor: valor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clave,
                required String valor,
                Value<int> rowid = const Value.absent(),
              }) => ConfiguracionesCompanion.insert(
                clave: clave,
                valor: valor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConfiguracionesTable, ConfigItem>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ConfiguracionesTable,
                    ConfigItem
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConfiguracionesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConfiguracionesTable,
      ConfigItem,
      $$ConfiguracionesTableFilterComposer,
      $$ConfiguracionesTableOrderingComposer,
      $$ConfiguracionesTableAnnotationComposer,
      $$ConfiguracionesTableCreateCompanionBuilder,
      $$ConfiguracionesTableUpdateCompanionBuilder,
      (
        ConfigItem,
        BaseReferences<_$AppDatabase, $ConfiguracionesTable, ConfigItem>,
      ),
      ConfigItem,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsuariosTableTableManager get usuarios =>
      $$UsuariosTableTableManager(_db, _db.usuarios);
  $$PlanesTableTableManager get planes =>
      $$PlanesTableTableManager(_db, _db.planes);
  $$ClientesTableTableManager get clientes =>
      $$ClientesTableTableManager(_db, _db.clientes);
  $$InstalacionesTableTableManager get instalaciones =>
      $$InstalacionesTableTableManager(_db, _db.instalaciones);
  $$EquiposTableTableManager get equipos =>
      $$EquiposTableTableManager(_db, _db.equipos);
  $$PeriodosTableTableManager get periodos =>
      $$PeriodosTableTableManager(_db, _db.periodos);
  $$PagosTableTableManager get pagos =>
      $$PagosTableTableManager(_db, _db.pagos);
  $$PagoAplicacionesTableTableManager get pagoAplicaciones =>
      $$PagoAplicacionesTableTableManager(_db, _db.pagoAplicaciones);
  $$CargosTableTableManager get cargos =>
      $$CargosTableTableManager(_db, _db.cargos);
  $$CargoAplicacionesTableTableManager get cargoAplicaciones =>
      $$CargoAplicacionesTableTableManager(_db, _db.cargoAplicaciones);
  $$HistorialEstadosTableTableManager get historialEstados =>
      $$HistorialEstadosTableTableManager(_db, _db.historialEstados);
  $$GastosTableTableManager get gastos =>
      $$GastosTableTableManager(_db, _db.gastos);
  $$ConfiguracionesTableTableManager get configuraciones =>
      $$ConfiguracionesTableTableManager(_db, _db.configuraciones);
}
