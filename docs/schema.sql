-- NetMAX Manager — Modelo de datos v1.0 (SQLite)
-- Montos en centavos (INTEGER). Fechas en texto ISO-8601 (YYYY-MM-DD).
PRAGMA foreign_keys = ON;

CREATE TABLE usuarios (
  id            INTEGER PRIMARY KEY,
  nombre        TEXT NOT NULL,
  usuario       TEXT NOT NULL UNIQUE,
  pin_hash      TEXT NOT NULL,              -- PIN de 4-6 dígitos, hasheado
  rol           TEXT NOT NULL DEFAULT 'admin' CHECK (rol IN ('propietario','admin')),
  activo        INTEGER NOT NULL DEFAULT 1,
  creado_en     TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE planes (
  id            INTEGER PRIMARY KEY,
  nombre        TEXT NOT NULL,              -- "10 Mbps"
  velocidad_mbps INTEGER NOT NULL,
  precio_base   INTEGER NOT NULL,           -- 25000 = $250.00
  activo        INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE clientes (
  id                INTEGER PRIMARY KEY,
  nombre            TEXT NOT NULL,
  telefono          TEXT,
  direccion         TEXT,
  zona              TEXT,                   -- p.ej. "Centro", "Rancho X"
  referencia        TEXT,                   -- cómo llegar
  plan_id           INTEGER NOT NULL REFERENCES planes(id),
  precio_mensual    INTEGER NOT NULL,       -- precio personalizado (default = plan)
  dia_corte         INTEGER NOT NULL CHECK (dia_corte BETWEEN 1 AND 28),
  tipo_contratacion TEXT NOT NULL CHECK (tipo_contratacion IN
                      ('compra_equipo','equipo_propio','equipo_prestado')),
  fecha_alta        TEXT NOT NULL,
  estado            TEXT NOT NULL DEFAULT 'activo' CHECK (estado IN
                      ('activo','suspendido','cancelado')),
  notas             TEXT,
  creado_en         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE instalaciones (
  id              INTEGER PRIMARY KEY,
  cliente_id      INTEGER NOT NULL REFERENCES clientes(id),
  fecha           TEXT NOT NULL,
  costo           INTEGER NOT NULL DEFAULT 0,
  pagado          INTEGER NOT NULL DEFAULT 0,  -- 0/1
  tecnico         TEXT,
  notas           TEXT
);

CREATE TABLE equipos (
  id              INTEGER PRIMARY KEY,
  cliente_id      INTEGER REFERENCES clientes(id),   -- NULL = en bodega
  tipo            TEXT NOT NULL,              -- antena, router, cable...
  marca_modelo    TEXT,
  numero_serie    TEXT,
  propiedad       TEXT NOT NULL CHECK (propiedad IN ('cliente','netmax')),
  costo           INTEGER,
  fecha_entrega   TEXT,
  fecha_retiro    TEXT,
  notas           TEXT
);

-- Un renglón por cada mes de servicio de cada cliente ("vencimientos").
CREATE TABLE periodos (
  id                INTEGER PRIMARY KEY,
  cliente_id        INTEGER NOT NULL REFERENCES clientes(id),
  periodo           TEXT NOT NULL,          -- 'YYYY-MM' (mes que cubre)
  fecha_vencimiento TEXT NOT NULL,          -- calculada con dia_corte
  monto             INTEGER NOT NULL,       -- copia de precio_mensual al generarse
  es_cortesia       INTEGER NOT NULL DEFAULT 0,
  UNIQUE (cliente_id, periodo)
);

CREATE TABLE pagos (
  id              INTEGER PRIMARY KEY,
  cliente_id      INTEGER NOT NULL REFERENCES clientes(id),
  fecha_pago      TEXT NOT NULL,
  monto           INTEGER NOT NULL CHECK (monto > 0),
  metodo          TEXT NOT NULL DEFAULT 'efectivo' CHECK (metodo IN
                    ('efectivo','transferencia','deposito','otro')),
  folio           TEXT,                     -- número de recibo
  registrado_por  INTEGER REFERENCES usuarios(id),
  cancelado       INTEGER NOT NULL DEFAULT 0,
  notas           TEXT,
  creado_en       TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Qué parte de cada pago se aplicó a qué periodo (soporta adelantos y parciales).
CREATE TABLE pago_aplicaciones (
  pago_id     INTEGER NOT NULL REFERENCES pagos(id),
  periodo_id  INTEGER NOT NULL REFERENCES periodos(id),
  monto       INTEGER NOT NULL CHECK (monto > 0),
  PRIMARY KEY (pago_id, periodo_id)
);

CREATE TABLE historial_estados (
  id              INTEGER PRIMARY KEY,
  cliente_id      INTEGER NOT NULL REFERENCES clientes(id),
  estado_anterior TEXT,
  estado_nuevo    TEXT NOT NULL,
  motivo          TEXT,
  usuario_id      INTEGER REFERENCES usuarios(id),
  fecha           TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE gastos (
  id          INTEGER PRIMARY KEY,
  fecha       TEXT NOT NULL,
  concepto    TEXT NOT NULL,
  categoria   TEXT,                         -- proveedor internet, equipo, gasolina...
  monto       INTEGER NOT NULL CHECK (monto > 0),
  usuario_id  INTEGER REFERENCES usuarios(id),
  notas       TEXT
);

CREATE TABLE configuracion (
  clave TEXT PRIMARY KEY,
  valor TEXT NOT NULL
);

CREATE INDEX idx_periodos_cliente ON periodos(cliente_id, periodo);
CREATE INDEX idx_pagos_cliente    ON pagos(cliente_id, fecha_pago);

-- Saldo por periodo: cuánto falta pagar de cada mes.
CREATE VIEW v_periodos_saldo AS
SELECT p.*,
       COALESCE(SUM(CASE WHEN pg.cancelado = 0 THEN pa.monto END), 0) AS pagado,
       CASE WHEN p.es_cortesia = 1 THEN 0
            ELSE p.monto - COALESCE(SUM(CASE WHEN pg.cancelado = 0 THEN pa.monto END), 0)
       END AS saldo
FROM periodos p
LEFT JOIN pago_aplicaciones pa ON pa.periodo_id = p.id
LEFT JOIN pagos pg             ON pg.id = pa.pago_id
GROUP BY p.id;

-- Adeudo actual por cliente (solo periodos ya vencidos).
CREATE VIEW v_adeudos AS
SELECT c.id AS cliente_id, c.nombre, c.telefono, c.zona,
       COUNT(s.id)  AS meses_adeudo,
       SUM(s.saldo) AS total_adeudo,
       MIN(s.fecha_vencimiento) AS vencido_desde
FROM clientes c
JOIN v_periodos_saldo s ON s.cliente_id = c.id
WHERE s.saldo > 0 AND s.fecha_vencimiento < date('now') AND c.estado <> 'cancelado'
GROUP BY c.id;

-- Datos iniciales
INSERT INTO planes (nombre, velocidad_mbps, precio_base) VALUES ('10 Mbps', 10, 25000);
INSERT INTO configuracion VALUES ('negocio_nombre', 'NetMAX'),
                                 ('dias_gracia', '5'),
                                 ('meses_generar_adelante', '12');
