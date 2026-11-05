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
                 # etiquetas.dart (textos en español de los enums),
                 # marca.dart (ColoresNetMax, DatosNegocio, ImagenesMarca, widget MarcaNetMax),
                 # tema.dart (temaNetMax(): tema Material 3 con la identidad)
  domain/        # reglas puras sin BD: cobranza.dart (aplicarPago, calcularAdeudo, pagadoHasta),
                 # clientes.dart (búsqueda sin acentos, validaciones de formulario,
                 #   agruparDetalles de contratación personalizada),
                 # planes.dart (DatosPlan, validaciones de plan),
                 # usuarios.dart (PIN protegido con sal + SHA-256 iterado, validaciones,
                 #   bloqueo tras 5 intentos, enum Permiso, PerfilBase como plantilla,
                 #   guardar/leerPermisos, nombrePerfil),
                 # vencimientos.dart (primer mes de cobro, mesesPorGenerar, estadoEnFecha),
                 # dashboard.dart (cobrado del mes, avance del mes, próximos vencimientos,
                 #   serieCobranza y serieActividad de 12 meses),
                 # reportes.dart (FilaPago, ingresosPorMes, FilaCliente, DatosComprobante)
  data/
    db/          # database.dart (tablas drift + AppDatabase), enums.dart
    repositories/  # clientes_repository.dart (clientes, estados, instalaciones, equipos,
                   #   contrataciones personalizadas usadas)
                   # planes_repository.dart (catálogo de planes con número de clientes)
                   # usuarios_repository.dart (crear, autenticar, editar/cambiar PIN, activar)
                   # pagos_repository.dart (saldos por mes, registrar/cancelar pago, historial)
                   # vencimientos_repository.dart (generar meses, cortesía, agregar/quitar mes,
                   #   cargos extra, adeudos)
                   # dashboard_repository.dart (resumen de inicio; se recalcula con consulta testigo)
                   # reportes_repository.dart (pagos de un periodo, ingresos, adeudos, clientes,
                   #   comprobante de un pago)
    respaldos/   # respaldo_service.dart (crear con VACUUM INTO, validar, reemplazar archivo)
  reportes/      # pdf_reportes.dart: PDFs carta con encabezado de marca y pie con datos del
                 # negocio; EstiloPdf (Outfit + logo) cargado con cargarEstiloPdf();
                 # pdfComprobante (tipo cheque: 1/3 de hoja carta, `formatoComprobante`, talón
                 # a la izquierda, sello si el pago está cancelado);
                 # guardar_pdf.dart (botón "Guardar PDF" en la computadora: en Windows el
                 #   "compartir" de printing solo abre el PDF desde una carpeta temporal)
  providers/     # providers.dart: databaseProvider (se inyecta en main) y StreamProviders;
                 # zoom.dart (zoomProvider, niveles 80–150 %, guardado en configuraciones.zoom);
                 # sesion.dart (sesionProvider, permisosProvider, usuariosProvider,
                 #   sesionInicialProvider para pruebas)
  screens/       # una carpeta por módulo: clientes/ (lista = tabla de gestión, formulario,
                 # ficha, diálogos, acciones_cliente.dart: editar/suspender/reactivar/cancelar,
                 # modales.dart: alta/edición/ficha en ventana modal con navegación propia),
                 # configuracion/ (planes, tipos de contratación, dialogo_plan.dart,
                 #   usuarios_seccion.dart: gestión de usuarios con permisos por casillas); sesion/acceso_screen.dart (PuertaSesion: primer
                 #   propietario o usuario + PIN),
                 # estado_cuenta_screen.dart; pagos/ (registrar pago, comprobante_screen);
                 # adeudos/ (lista de adeudos); inicio/ (dashboard: acciones rápidas, indicadores,
                 # graficas.dart con fl_chart, vencimientos, pagos recientes);
                 # reportes/ (lista, vista previa PdfPreview y comprobantes_screen por mes);
                 # respaldos/ (crear: Windows guardar como / Android compartir; restaurar)
  widgets/       # comunes.dart (EstadoChip, ErrorVista, SeccionTitulo, mostrarMensaje)
                 # disposicion.dart (esEscritorio, ContenidoCentrado, EncabezadoSeccion,
                 #   SeccionFormulario, FilaCampos); panel_lateral.dart (navegación de escritorio);
                 # zoom_interfaz.dart (ZoomInterfaz: FittedBox + atajos de teclado)
  routes/        # app_router.dart (go_router, ShellRoute: panel lateral si ancho ≥ 900, barra
                 # inferior si no; Inicio/Clientes/Adeudos/Reportes + Respaldos y Configuración
                 # abajo del panel; en el celular, íconos en la barra de Inicio):
                 # /inicio (arranque), /clientes, /clientes/nuevo, /clientes/:id,
                 # /clientes/:id/{editar,pago,estado-cuenta}, /adeudos, /reportes,
                 # /reportes/comprobantes, /reportes/:tipo,
                 # /respaldos, /configuracion (Inicio y panel lateral)
  main.dart      # AppRaiz: abre la BD y reconstruye toda la app (ProviderScope con key)
                 # al restaurar un respaldo (restaurarRespaldoProvider); ZoomInterfaz escala
                 # toda la interfaz (Ctrl + / Ctrl − / Ctrl 0); PuertaSesion muestra el acceso
                 # si no hay sesión; al cerrar sesión se regresa a /inicio
assets/
  fonts/         # Outfit (Regular/Medium/SemiBold/Bold, OFL) para la app y los PDF
  marca/         # logo.svg/png (fondo claro) y logo_claro.svg/png (fondo azul)
test/
  capturas_test.dart  # capturas de pantalla con datos simulados (solo con CAPTURAS=1)
docs/
  schema.sql     # referencia original; la fuente de verdad es lib/data/db/database.dart
  INSTALACION.md # cómo instalar (también es el texto de cada versión publicada)
  PRUEBAS_v1.md  # lista de pruebas de la versión instalable
windows/instalador/netmax.iss  # instalador Inno Setup (AppId fijo: no cambiarlo)
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
6. Tipos de contratación: `compraEquipo`, `equipoPropio`, `equipoPrestado` y `otro`
   (personalizado: descripción libre obligatoria en `clientes.tipo_contratacion_detalle`; se
   sugieren las ya usadas). Si el equipo es prestado, debe quedar registrado en `equipos`.
7. Los montos se guardan en **centavos (enteros)**, nunca en `double`.
8. Nada se borra físicamente: clientes y pagos se cancelan/desactivan (auditoría).
9. Cada cliente tiene un **primer mes de cobro** (`clientes.primer_mes_cobro`): el mes del alta,
   el siguiente (sugerido) u otro. Un pago crea los meses adelantados que necesite (máximo 24
   por pago). Los pagos cancelados no cuentan en saldos; sus meses vuelven a quedar pendientes.
   No se registran pagos a clientes cancelados.
10. **Generación de meses**: desde el primer mes de cobro hasta el mes actual, solo los meses
   en que el cliente estaba **activo** en la fecha de vencimiento (según `historial_estados`;
   sin historial previo = activo). Suspendidos/cancelados no generan meses, pero siguen debiendo
   lo vencido. Se genera al abrir la app, al abrir Adeudos, al crear/editar/cambiar estado y
   antes de registrar un pago. Los repositorios reciben `ahora` para fijar la fecha en pruebas.
11. **Cortesía** se marca a mano por mes (no si el mes tiene pagos vigentes). Se puede **agregar
   un mes a mano** (cobro manual, p. ej. a un suspendido) y **quitar un mes** que nunca tuvo pagos.
   Si el primer mes de cobro se mueve a después, se quitan los meses anteriores sin pagos.
12. **Cargos extra** (tabla `cargos`, aplicados en `cargo_aplicaciones`): concepto + monto libre
   (p. ej. equipo de NetMAX no devuelto, reconexión). Se deben desde su fecha y forman parte del
   adeudo. Los pagos cubren meses y cargos juntos en orden de fecha (vencimiento del mes o fecha
   del cargo; con la misma fecha va primero el mes). Un cargo se cancela (no se borra) y solo si
   no tiene pagos vigentes.
13. **Inicio (dashboard)**: *cobrado en el mes* = pagos vigentes con fecha en el mes (dinero
   recibido); *mensualidades del mes* = meses del mes actual sin cortesía vs lo pagado de ellos;
   *por cobrar* = adeudo vencido total (meses + cargos); *próximos vencimientos* = meses con saldo
   de clientes activos que vencen de hoy a 7 días.
14. **Reportes (PDF)**: ingresos por mes de un año (por fecha de pago, desglose por método),
   pagos recibidos en un mes (con lo que cubrió cada uno), clientes con adeudo y lista de
   clientes. Solo cuentan pagos vigentes. Las fechas se filtran en Dart (se guardan con zona).
15. **Respaldos**: copia completa del archivo SQLite (`.db`). Archivo de la app:
   `getApplicationDocumentsDirectory()/netmax.sqlite` (`AppDatabase.rutaArchivo`; no cambiarla o se
   pierde el acceso a los datos existentes). Restaurar: validar (integridad, tablas, `user_version`
   ≤ `schemaVersion`), confirmar con resumen, copia de seguridad `netmax.sqlite.antes_de_restaurar`,
   cerrar BD, reemplazar (borrando -wal/-shm/-journal) y reabrir (las migraciones actualizan
   respaldos viejos). La fecha del último respaldo se guarda en `configuraciones.ultimo_respaldo`;
   Inicio recuerda respaldar si pasan más de 7 días.
16. **Evolución en Inicio**: *cobranza por mes* = pagos vigentes por mes de pago (12 meses; el mes
   actual en azul, los anteriores en verde); *actividad de clientes* = altas (por `fecha_alta`),
   suspensiones y cancelaciones (por fecha del cambio en `historial_estados`, sin contar el registro
   del alta). No se compara el mes en curso contra un mes completo con porcentajes.
17. **Comprobante de pago**: N° = id del pago con 6 dígitos; conceptos = mensualidades y cargos que
   cubrió; incluye "pagado hasta" y saldo pendiente a la fecha en que se genera. Se abre desde la
   ficha (menú del pago), al registrar un pago y en Reportes > Comprobantes de pago.
18. **Planes** (Configuración): se crean, editan y desactivan (no se borran). Desactivado = ya no
   se ofrece a clientes nuevos; quien lo tiene lo conserva. Debe quedar al menos uno activo. El
   precio del plan es solo el sugerido: cambiarlo no cambia el precio de clientes existentes.
   Desde el alta de cliente se puede "Crear plan nuevo…" (queda en el catálogo).
19. **Gestión en la lista de clientes**: cada renglón tiene Editar, Suspender/Reactivar y Cancelar
   servicio visibles (activo → suspender/cancelar; suspendido → reactivar/cancelar; cancelado →
   reactivar). La ficha muestra los mismos botones. Siempre se pide confirmación con motivo.
20. **Acceso (login)**: usuario + PIN (4–6 números) al abrir la app; la sesión dura hasta cerrar
   la app o "Cerrar sesión" (panel lateral / barra de Inicio en el celular). Sin usuarios, se crea
   el primero con todos los permisos. **Permisos individuales** (no roles) guardados en
   `usuarios.permisos` (v5): registrar/cancelar pagos, ajustar estados de cuenta, registrar/editar
   clientes, cambiar su estado, ver reportes, crear/restaurar respaldos, configurar, administrar
   usuarios. **Perfiles base** (plantillas): Propietario (todo) y Administrador (sin cancelar pagos,
   restaurar, configurar ni administrar usuarios); se elige uno y se ajusta casilla por casilla; si
   no coincide con ninguno se muestra "Personalizado". `usuarios.rol` queda solo como referencia;
   usuarios sin `permisos` (antes de v5) usan los de su rol. Las pantallas ocultan o desactivan lo
   que el usuario no puede hacer (`permisosProvider`). Configuración › Gestión de usuarios: no se
   borran, se desactivan; siempre debe quedar un usuario activo con "Administrar usuarios"; nadie
   se desactiva a sí mismo. 5 PIN incorrectos = 30 s de espera. Se guarda quién registró cada pago (`pagos.registrado_por`) y cada cambio de estado
   (`historial_estados.usuario_id`) y se muestra "por <nombre>" en la ficha.
21. **Folio del pago**: es el número del comprobante (id del pago, 6 dígitos) y lo asigna el
   sistema; al registrar se muestra el siguiente (no editable). La columna `pagos.folio` guarda
   solo la referencia bancaria (se pide con transferencia o depósito).

## Convenciones
- Código y nombres de tablas en español sin acentos (`clientes`, `fecha_pago`).
- Fechas: `DateTimeColumn` guardadas como texto ISO-8601 (build.yaml:
  `store_date_time_values_as_text`). El mes de servicio es texto `YYYY-MM` (columna `periodos.mes`).
- Valores fijos (rol, tipo de contratación, estado, método de pago) son enums de Dart
  guardados con `textEnum` (nombre camelCase: `equipoPrestado`).
- Clase de datos de `periodos` = `PeriodoRow` (para no chocar con la clase de dominio).
- Tras cambiar tablas: `dart run build_runner build --delete-conflicting-outputs`
  y subir `schemaVersion` con su migración (+ prueba en `test/migracion_test.dart`).
  Versión actual del esquema: **5**. Como Claude no puede correr build_runner, el CI imprime
  `database.g.dart` regenerado (gzip+base64, entre `INICIO_BASE64`/`FIN_BASE64`) si está
  desactualizado: se decodifica del log y se sube.
- Toda lógica de cálculo (vencimientos, adeudos) va en repositorios/servicios con
  pruebas unitarias, nunca en los widgets.
- Antes de dar algo por terminado: `flutter analyze` y `flutter test` sin errores.
  `flutter analyze` falla también con avisos "info": deben quedar en cero.
- Pruebas: lógica pura en `test/*_test.dart`; repositorios con `AppDatabase(NativeDatabase.memory())`;
  pantallas con providers simulados (`overrideWith`), **sin BD real** (drift + reloj simulado se cuelga).
- Usar APIs actuales de Flutter: `DropdownButtonFormField(initialValue:)` (no `value:`), sin `RadioListTile`
  con `groupValue` (obsoleto). Interfaz en español; fechas con `core/fechas.dart` (no se usa intl).
- Indicadores y medidores: etiqueta en minúsculas sin dos puntos, valor grande, texto en colores
  de texto (no de serie); estados con ícono + texto, nunca solo color; medidor con la pista en un
  tono claro del mismo color (`primary` sobre `primaryContainer`).
- Historial y fechas automáticas: guardar `DateTime.now()` explícito (no `currentDateAndTime`, que es UTC).
- PDF: `pdf` + `printing` (`PdfPreview` no se puede probar en widget tests: probar la generación
  de bytes con `cargarEstiloPdf()` tras `TestWidgetsFlutterBinding.ensureInitialized()`).

- Cliente en **modales** (`screens/clientes/modales.dart`): `abrirFichaCliente`, `abrirFormularioCliente`,
  `nuevoCliente`, `registrarPagoConComprobante`. Diálogo flotante si el ancho ≥ 720, pantalla completa
  si no. Dentro del modal se navega con `Navigator.of(context).push(MaterialPageRoute)` (no go_router)
  y se cierra con `cerrarModal(context, valor)`; los mensajes que deben verse al cerrar, con
  `mensajeFueraDelModal`. Las rutas `/clientes/:id/...` siguen existiendo como páginas.
- **Escritorio** (ancho ≥ 900, `esEscritorio`): panel lateral azul (extendido ≥ 1180, compacto
  si no) con zoom abajo; las pantallas principales no usan AppBar, sino `EncabezadoSeccion`
  (título, descripción, ícono y acciones). Contenido con ancho máximo (`ContenidoCentrado`:
  listas 1240, formularios 760, ficha 960); formularios en tarjetas `SeccionFormulario` con
  `FilaCampos` (dos columnas si caben) y barra de acciones fija abajo. Registrar pago: dos
  columnas (datos | vista previa) si hay ≥ 900 de ancho.
- **Zoom**: `ZoomInterfaz` dibuja la app al tamaño real ÷ zoom y la escala con `FittedBox` (no usar
  `Transform.scale` + `OverflowBox`: con zoom < 100 % los clics de la derecha/abajo no llegaban).
  Se guarda por equipo en `configuraciones` (clave `zoom`).
- Modales: el botón "atrás" de Android regresa dentro del modal (`NavigatorPopHandler`).
- **Ficha del cliente**: resumen arriba y pestañas Pagos / Instalaciones / Equipos / Historial
  (con número de registros) para no mezclar la información.
- **Comprobante tipo cheque**: `conceptosCompactos` agrupa meses consecutivos ("Mensualidades
  sep 2026 – abr 2027 (8)") y junta lo que pase de 4 líneas en "Otros N conceptos".
- **Reportes**: tarjetas agrupadas (Cobranza; Clientes y cartera); en escritorio la vista previa
  tiene panel de opciones a la izquierda.
- Gráficas: `fl_chart`. Colores de serie validados con la skill de visualización (incluido
  daltonismo): altas `#0B7A54`, suspensiones `#C97A00`, cancelaciones `#7A5BD6`; leyenda con
  totales, tooltip al pasar el mouse, una sola escala por gráfica.

## Identidad visual (NET_MAX)
- Nombre visible: **NET_MAX** (nunca "NetMAX"). Lema: "Contigo más lejos, siempre con **Fe**".
- Colores (`ColoresNetMax`): azul `#13294B` (NET, textos, barras), verde `#0B7A54` (MAX, botones,
  acentos sobre claro), verde claro `#3FC48D` (acentos sobre azul), crema `#F4EDE1` (fondo),
  arena `#DCD5C8`, línea `#C7C6C3`, tarjeta `#FFFBF5`.
- Tipografía: **Outfit** en toda la app (`fontFamily: 'Outfit'`) y en los PDF.
- Tema (`temaNetMax()`): barra superior y de navegación azules con texto crema y selección verde
  claro; FAB y botones principales verdes; tarjetas planas redondeadas (16) con borde suave;
  campos blancos redondeados (12). No fijar `border:` en `InputDecoration` (lo da el tema).
- Logo: torre con señal sobre colina (`assets/marca`). Los íconos de la app (Android adaptable,
  Windows .ico) y la pantalla de arranque de Android se generaron desde `logo_claro.svg` sobre azul.
- Datos del negocio (`DatosNegocio`): tel. 771 196 3767, net_max@gmail.com,
  Santa Cruz, Nicolás Flores, Hgo. C.P. 42364 (pie de los PDF).
- Revisión visual: el CI genera capturas (`test/capturas_test.dart`) y PDFs de ejemplo y los
  imprime en el log entre `INICIO_CAPTURAS`/`FIN_CAPTURAS`, una línea `ARCHIVO <ruta> <base64>`
  por imagen (un solo base64 grande se corrompía: GitHub enmascara fragmentos con `***`).
  También se suben como artefacto `capturas` (para descargarlas desde GitHub).

## Versión instalable
- Versión en `pubspec.yaml` (`version: X.Y.Z+N`) y en `lib/core/version.dart` (`versionApp`, se
  muestra en el acceso, el panel y Respaldos; `test/version_test.dart` verifica que coincidan).
  Para una versión nueva: subir ambas (y el `+N`, que Android usa para actualizar).
- `.github/workflows/release.yml` corre al subir una etiqueta `v*` (con "-" = versión de prueba):
  compila en Windows (`flutter build windows`, copia `msvcp140/vcruntime140/vcruntime140_1.dll`,
  instalador Inno Setup `NET_MAX_Instalador_X.Y.Z.exe` + zip portátil) y en Android
  (`NET_MAX_X.Y.Z.apk`) y los publica en GitHub Releases con `docs/INSTALACION.md` como texto.
  `workflow_dispatch` solo sirve cuando el flujo ya está en `main`.
- Windows: se instala por usuario en `%LOCALAPPDATA%\Programs\NET_MAX` sin pedir administrador;
  los datos están en `Documentos\netmax.sqlite` (no se borran al actualizar/desinstalar). Sin
  firma digital: SmartScreen avisa ("Más información → Ejecutar de todas formas").
- Android: `applicationId com.netmax.netmax_manager` (no cambiar). Firma desde
  `android/key.properties` o secretos `NETMAX_KEYSTORE_BASE64/_PASSWORD`, `NETMAX_KEY_ALIAS`,
  `NETMAX_KEY_PASSWORD`; sin llave se firma con la de depuración (solo pruebas: cambiar de llave
  obliga a desinstalar y se pierden los datos del celular → respaldar antes).

## Flujo de trabajo
- Cada sprint en una rama (`sprint-N/nombre`) con Pull Request hacia `main`. La dueña revisa,
  prueba en su equipo (`git fetch` + `git checkout <rama>` + `flutter pub get` + `flutter run -d windows`) y hace merge.
- GitHub Actions (`.github/workflows/ci.yml`) corre build_runner, `flutter analyze` y `flutter test`
  con Flutter 3.47.9 en cada PR. Claude no puede ejecutar Flutter en su entorno: el CI es la verificación.

## Roadmap v1.0
- [x] Sprint 1: proyecto Flutter + base de datos drift + lógica de cobranza con pruebas
- [x] Sprint 2: Clientes (+ instalaciones y equipos, historial de estados)
- [x] Sprint 3: Pagos (reparto automático con vista previa, abonos, adelantos, cancelación)
- [x] Sprint 4: Vencimientos y adeudos (primer mes configurable, generación, cortesía, estado de cuenta)
- [x] Sprint 4b: Cargos extra (equipo no devuelto, reconexión, etc.)
- [x] Sprint 5: Dashboard (pantalla de inicio)
- [x] Sprint 6: Reportes (PDF: ingresos, pagos, adeudos, clientes)
- [x] Sprint 7: Respaldos (crear, compartir/guardar, restaurar, recordatorio)

**Versión 1.0 completa.**

## Transformación (antes de la versión instalable)
- [x] Identidad visual NET_MAX (colores, tipografía, logo, íconos, PDF)
- [x] Inicio interactivo con gráficas (cobranza y actividad de clientes), comprobantes de pago,
      cliente en ventanas modales
- [x] Escritorio: panel lateral, zoom, formularios con ancho limitado, comprobante tipo cheque
      (1/3 de hoja), encabezados de sección y nueva pantalla de Reportes
- [x] Revisión de botones (zoom < 100 %, "atrás" en modales, Guardar PDF en Windows),
      Configuración de planes y contratación personalizada, descripciones de Instalaciones y
      Equipos, botones de gestión visibles en la tabla de clientes
- [x] Ficha en pestañas, folio automático del pago, login con usuario + PIN y gestión de
      usuarios con permisos individuales (perfiles Propietario/Administrador como plantillas)

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
