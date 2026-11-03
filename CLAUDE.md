# NetMAX Manager — Contexto del proyecto para Claude

Este archivo le da a Claude (Claude Code) el contexto del proyecto. Mantenlo actualizado:
cada decisión importante que tomemos se anota aquí.

## Qué es
Aplicación para administrar NetMAX, un negocio familiar de servicio de internet
(30–50 clientes, cobro mensual). Reemplaza hojas impresas y Excel.

- Plataformas: **Android y Windows**, una sola base de código.
- **Funciona 100% sin internet** (offline-first). Sincronización = mejora futura.
- Usuarios: el propietario y, ocasionalmente, otro administrador.
- Idioma de la interfaz: español (México). Moneda: MXN.

## Stack
- Flutter (Dart 3), Material 3
- SQLite vía **drift** (consultas tipadas, migraciones)
- Estado: **Riverpod**
- Navegación: **go_router**
- PDF/reportes: `pdf` + `printing`

## Estructura
```
lib/
  core/          # dinero.dart (centavos), mes.dart (clase Mes 'YYYY-MM'), fechas.dart,
                 # etiquetas.dart (textos en español de los enums)
  domain/        # reglas puras sin BD: cobranza.dart (aplicarPago, calcularAdeudo, pagadoHasta),
                 # clientes.dart (búsqueda sin acentos, validaciones de formulario)
  data/
    db/          # database.dart (tablas drift + AppDatabase), enums.dart
    repositories/  # clientes_repository.dart (clientes, estados, instalaciones, equipos)
  providers/     # providers.dart: databaseProvider (se inyecta en main) y StreamProviders
  screens/       # una carpeta por módulo: clientes/ (lista, formulario, ficha, diálogos)
  widgets/       # comunes.dart (EstadoChip, ErrorVista, SeccionTitulo, mostrarMensaje)
  routes/        # app_router.dart (go_router): /clientes, /clientes/nuevo, /clientes/:id, /clientes/:id/editar
docs/
  schema.sql     # referencia original; la fuente de verdad es lib/data/db/database.dart
```

## Reglas de negocio (fuente de verdad)
1. Cada cliente tiene un **día de corte** propio (1–28) y un **precio mensual** propio
   (por defecto el del plan: 10 Mbps = $250; zonas alejadas hasta $300).
2. Cada mes de servicio es un **periodo** (tabla `periodos`). El precio se copia al
   periodo cuando se genera: si el precio cambia después, los meses ya generados no cambian.
3. Un **pago** puede cubrir uno o varios periodos (hasta un año adelantado).
   Se aplica siempre al periodo pendiente **más antiguo** primero.
   La relación vive en `pago_aplicaciones` (permite pagos parciales).
4. Un periodo puede marcarse como **cortesía** (monto $0, no genera adeudo).
5. **Adeudo** = suma de periodos vencidos no pagados por completo.
6. Tipos de contratación: `compraEquipo`, `equipoPropio`, `equipoPrestado`.
   Si el equipo es prestado, debe quedar registrado en `equipos` para su recuperación.
7. Los montos se guardan en **centavos (enteros)**, nunca en `double`.
8. Nada se borra físicamente: clientes y pagos se cancelan/desactivan (auditoría).

## Convenciones
- Código y nombres de tablas en español sin acentos (`clientes`, `fecha_pago`).
- Fechas: `DateTimeColumn` guardadas como texto ISO-8601 (build.yaml:
  `store_date_time_values_as_text`). El mes de servicio es texto `YYYY-MM` (columna `periodos.mes`).
- Valores fijos (rol, tipo de contratación, estado, método de pago) son enums de Dart
  guardados con `textEnum` (nombre camelCase: `equipoPrestado`).
- Clase de datos de `periodos` = `PeriodoRow` (para no chocar con la clase de dominio).
- Tras cambiar tablas: `dart run build_runner build --delete-conflicting-outputs`
  y subir `schemaVersion` con su migración.
- Toda lógica de cálculo (vencimientos, adeudos) va en repositorios/servicios con
  pruebas unitarias, nunca en los widgets.
- Antes de dar algo por terminado: `flutter analyze` y `flutter test` sin errores.
  `flutter analyze` falla también con avisos "info": deben quedar en cero.
- Pruebas: lógica pura en `test/*_test.dart`; repositorios con `AppDatabase(NativeDatabase.memory())`;
  pantallas con providers simulados (`overrideWith`), **sin BD real** (drift + reloj simulado se cuelga).
- Usar APIs actuales de Flutter: `DropdownButtonFormField(initialValue:)` (no `value:`), sin `RadioListTile`
  con `groupValue` (obsoleto). Interfaz en español; fechas con `core/fechas.dart` (no se usa intl).
- Historial y fechas automáticas: guardar `DateTime.now()` explícito (no `currentDateAndTime`, que es UTC).

## Flujo de trabajo
- Cada sprint en una rama (`sprint-N/nombre`) con Pull Request hacia `main`. La dueña revisa,
  prueba en su equipo (`git fetch` + `git checkout <rama>` + `flutter pub get` + `flutter run -d windows`) y hace merge.
- GitHub Actions (`.github/workflows/ci.yml`) corre build_runner, `flutter analyze` y `flutter test`
  con Flutter 3.47.9 en cada PR. Claude no puede ejecutar Flutter en su entorno: el CI es la verificación.

## Roadmap v1.0
- [x] Sprint 1: proyecto Flutter + base de datos drift + lógica de cobranza con pruebas
- [x] Sprint 2: Clientes (+ instalaciones y equipos, historial de estados)
- [ ] Sprint 3: Pagos
- [ ] Sprint 4: Vencimientos y adeudos
- [ ] Sprint 5: Dashboard
- [ ] Sprint 6: Reportes
- [ ] Sprint 7: Respaldos (exportar/importar archivo .db)

## Futuro (no hacer todavía)
Sincronización entre dispositivos, recordatorios por WhatsApp, mapa/GPS de clientes,
historial de soporte técnico, notificaciones.

## Alcance
Solo lo definido en el Documento de Análisis Inicial (junio 2026). Sin sitio web por ahora.

## Entorno de desarrollo
- Windows 10/11 64-bit, Git, Flutter SDK (canal stable), Visual Studio 2022
  ("Desarrollo para el escritorio con C++"), Android Studio (SDK, cmdline-tools,
  emulador), VS Code con extensiones Flutter y Dart.
- Verificación: `flutter doctor -v` sin errores en Flutter, Windows Version,
  Android toolchain y Visual Studio.
- Entorno verificado (31-oct-2026, "No issues found"): Flutter 3.47.9 stable,
  Dart 3.13.7, Windows 10 Home 22H2, Visual Studio Community 2026 (18.11),
  Windows SDK 10.0.26100, Android SDK 36 / platform android-37, JDK 25 de Android Studio.
  Flutter en C:\src\flutter.
