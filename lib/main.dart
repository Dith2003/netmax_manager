import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/tema.dart';
import 'data/db/database.dart';
import 'data/repositories/vencimientos_repository.dart';
import 'data/respaldos/respaldo_service.dart';
import 'providers/providers.dart';
import 'providers/zoom.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await abrirBaseDeDatos();
  runApp(AppRaiz(db: db, zoom: await leerZoom(db)));
}

/// Abre la base de datos y genera los meses de cobro que ya correspondan.
Future<AppDatabase> abrirBaseDeDatos() async {
  final db = AppDatabase();
  try {
    await VencimientosRepository(db).generarTodos(DateTime.now());
  } catch (e, st) {
    debugPrint('No se pudieron generar los vencimientos: $e\n$st');
  }
  return db;
}

/// Raíz de la app: tiene la base de datos y permite reiniciar todo al
/// restaurar un respaldo (se reemplaza la base de datos y se reconstruye la app).
class AppRaiz extends StatefulWidget {
  const AppRaiz({super.key, required this.db, this.zoom = 1.0});

  final AppDatabase db;

  /// Zoom guardado de la interfaz.
  final double zoom;

  @override
  State<AppRaiz> createState() => _AppRaizState();
}

class _AppRaizState extends State<AppRaiz> {
  late AppDatabase _db = widget.db;
  late double _zoom = widget.zoom;
  int _generacion = 0;
  final _mensajero = GlobalKey<ScaffoldMessengerState>();

  Future<void> _restaurar(String rutaRespaldo) async {
    final destino = await AppDatabase.rutaArchivo();

    // Copia de seguridad del estado actual, por si hay que regresar.
    final seguridad = '$destino.antes_de_restaurar';
    await RespaldoService(_db).crearRespaldo(seguridad, registrar: false);

    await _db.close();
    try {
      await RespaldoService.reemplazarArchivo(respaldo: rutaRespaldo, destino: destino);
    } catch (e) {
      // Si falla el reemplazo, se vuelve a poner el archivo anterior.
      if (await File(seguridad).exists()) {
        await RespaldoService.reemplazarArchivo(respaldo: seguridad, destino: destino);
      }
      final anterior = await abrirBaseDeDatos();
      setState(() {
        _db = anterior;
        _generacion++;
      });
      rethrow;
    }

    final nueva = await abrirBaseDeDatos();
    final zoom = await leerZoom(nueva);
    setState(() {
      _db = nueva;
      _zoom = zoom;
      _generacion++;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mensajero.currentState?.showSnackBar(
        const SnackBar(content: Text('Respaldo restaurado correctamente')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      // Al cambiar la generación se reconstruye toda la app con la base nueva.
      key: ValueKey(_generacion),
      overrides: [
        databaseProvider.overrideWithValue(_db),
        restaurarRespaldoProvider.overrideWithValue(_restaurar),
        zoomInicialProvider.overrideWithValue(_zoom),
      ],
      child: NetMaxApp(mensajero: _mensajero),
    );
  }
}

class NetMaxApp extends ConsumerStatefulWidget {
  const NetMaxApp({super.key, this.mensajero});

  /// Para mostrar mensajes desde fuera de las pantallas (p. ej. al restaurar).
  final GlobalKey<ScaffoldMessengerState>? mensajero;

  @override
  ConsumerState<NetMaxApp> createState() => _NetMaxAppState();
}

class _NetMaxAppState extends ConsumerState<NetMaxApp> {
  late final GoRouter _router = crearRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NET_MAX',
      debugShowCheckedModeBanner: false,
      theme: temaNetMax(),
      routerConfig: _router,
      scaffoldMessengerKey: widget.mensajero,
      // Calendario, botones y textos del sistema en español.
      locale: const Locale('es', 'MX'),
      supportedLocales: const [Locale('es', 'MX'), Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => _ConZoom(child: child ?? const SizedBox.shrink()),
    );
  }
}

/// Aplica el zoom a toda la interfaz (pantallas, diálogos y menús) y atiende
/// los atajos Ctrl + (acercar), Ctrl − (alejar) y Ctrl 0 (100 %).
class _ConZoom extends ConsumerWidget {
  const _ConZoom({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zoom = ref.watch(zoomProvider);
    final control = ref.read(zoomProvider.notifier);

    // Siempre la misma estructura (aunque el zoom sea 100 %) para no perder
    // la navegación al cambiarlo.
    final mq = MediaQuery.of(context);
    final tamano = mq.size / zoom;
    final contenido = MediaQuery(
      data: mq.copyWith(
        size: tamano,
        padding: mq.padding / zoom,
        viewPadding: mq.viewPadding / zoom,
        viewInsets: mq.viewInsets / zoom,
      ),
      child: ClipRect(
        child: Transform.scale(
          scale: zoom,
          alignment: Alignment.topLeft,
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: tamano.width,
            maxWidth: tamano.width,
            minHeight: tamano.height,
            maxHeight: tamano.height,
            child: child,
          ),
        ),
      ),
    );

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.equal, control: true): control.acercar,
        const SingleActivator(LogicalKeyboardKey.add, control: true): control.acercar,
        const SingleActivator(LogicalKeyboardKey.numpadAdd, control: true): control.acercar,
        const SingleActivator(LogicalKeyboardKey.minus, control: true): control.alejar,
        const SingleActivator(LogicalKeyboardKey.numpadSubtract, control: true): control.alejar,
        const SingleActivator(LogicalKeyboardKey.digit0, control: true): control.restablecer,
        const SingleActivator(LogicalKeyboardKey.numpad0, control: true): control.restablecer,
      },
      child: Focus(autofocus: true, child: contenido),
    );
  }
}
