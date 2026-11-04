import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/sesion.dart';
import '../screens/adeudos/adeudos_screen.dart';
import '../screens/clientes/cliente_detalle_screen.dart';
import '../screens/clientes/cliente_form_screen.dart';
import '../screens/clientes/clientes_screen.dart';
import '../screens/clientes/estado_cuenta_screen.dart';
import '../screens/configuracion/configuracion_screen.dart';
import '../screens/inicio/inicio_screen.dart';
import '../screens/pagos/registrar_pago_screen.dart';
import '../screens/reportes/comprobantes_screen.dart';
import '../screens/reportes/reporte_screen.dart';
import '../screens/reportes/reportes_screen.dart';
import '../screens/respaldos/respaldos_screen.dart';
import '../widgets/disposicion.dart';
import '../widgets/panel_lateral.dart';

/// Rutas de la app. La pantalla inicial es el resumen (Inicio).
GoRouter crearRouter() {
  int idDe(GoRouterState state) => int.parse(state.pathParameters['id']!);

  return GoRouter(
    initialLocation: '/inicio',
    routes: [
      GoRoute(path: '/', redirect: (_, _) => '/inicio'),
      ShellRoute(
        builder: (_, state, child) => _ConNavegacion(ubicacion: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/inicio',
            builder: (_, _) => const InicioScreen(),
          ),
          GoRoute(
            path: '/clientes',
            builder: (_, _) => const ClientesScreen(),
            routes: [
              GoRoute(
                path: 'nuevo',
                builder: (_, _) => const ClienteFormScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, state) => ClienteDetalleScreen(clienteId: idDe(state)),
                routes: [
                  GoRoute(
                    path: 'editar',
                    builder: (_, state) => ClienteFormScreen(clienteId: idDe(state)),
                  ),
                  GoRoute(
                    path: 'pago',
                    builder: (_, state) => RegistrarPagoScreen(clienteId: idDe(state)),
                  ),
                  GoRoute(
                    path: 'estado-cuenta',
                    builder: (_, state) => EstadoCuentaScreen(clienteId: idDe(state)),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/adeudos',
            builder: (_, _) => const AdeudosScreen(),
          ),
          GoRoute(
            path: '/configuracion',
            builder: (_, _) => const ConfiguracionScreen(),
          ),
          GoRoute(
            path: '/respaldos',
            builder: (_, _) => const RespaldosScreen(),
          ),
          GoRoute(
            path: '/reportes',
            builder: (_, _) => const ReportesScreen(),
            routes: [
              GoRoute(
                path: 'comprobantes',
                builder: (_, _) => const ComprobantesScreen(),
              ),
              GoRoute(
                path: ':tipo',
                builder: (_, state) => ReporteScreen(
                  tipo: TipoReporte.values.byName(state.pathParameters['tipo']!),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Navegación principal: panel lateral en escritorio y barra inferior en el celular.
class _ConNavegacion extends ConsumerWidget {
  const _ConNavegacion({required this.ubicacion, required this.child});

  final String ubicacion;
  final Widget child;

  static const _destinos = [
    DestinoPanel(
        ruta: '/inicio', etiqueta: 'Inicio', icono: Icons.home_outlined, iconoSeleccionado: Icons.home),
    DestinoPanel(
        ruta: '/clientes',
        etiqueta: 'Clientes',
        icono: Icons.people_outline,
        iconoSeleccionado: Icons.people),
    DestinoPanel(
        ruta: '/adeudos',
        etiqueta: 'Adeudos',
        icono: Icons.money_off_outlined,
        iconoSeleccionado: Icons.money_off),
    DestinoPanel(
        ruta: '/reportes',
        etiqueta: 'Reportes',
        icono: Icons.description_outlined,
        iconoSeleccionado: Icons.description),
  ];

  static const _inferiores = [
    DestinoPanel(
        ruta: '/respaldos',
        etiqueta: 'Respaldos',
        icono: Icons.backup_outlined,
        iconoSeleccionado: Icons.backup),
    DestinoPanel(
        ruta: '/configuracion',
        etiqueta: 'Configuración',
        icono: Icons.settings_outlined,
        iconoSeleccionado: Icons.settings),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Configuración solo para quien tiene permiso (el propietario).
    final permisos = ref.watch(permisosProvider);
    final inferiores = [
      for (final d in _inferiores)
        if (d.ruta != '/configuracion' || permisos.configurar) d,
    ];
    final encontrado = _destinos.indexWhere((d) => ubicacion.startsWith(d.ruta));
    final inferior = inferiores.indexWhere((d) => ubicacion.startsWith(d.ruta));
    final indice = encontrado < 0 ? (inferior >= 0 ? -1 : 0) : encontrado;
    final ancho = MediaQuery.sizeOf(context).width;

    if (ancho >= anchoEscritorio) {
      return Scaffold(
        body: Row(
          children: [
            PanelLateral(
              destinos: _destinos,
              seleccionado: indice,
              extendido: ancho >= 1180,
              onSeleccionar: (i) => context.go(_destinos[i].ruta),
              destinosInferiores: inferiores,
              inferiorSeleccionado: inferior,
              onInferior: (i) => context.go(inferiores[i].ruta),
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: indice < 0 ? 0 : indice,
        onDestinationSelected: (i) => context.go(_destinos[i].ruta),
        destinations: [
          for (final d in _destinos)
            NavigationDestination(
              icon: Icon(d.icono),
              selectedIcon: Icon(d.iconoSeleccionado),
              label: d.etiqueta,
            ),
        ],
      ),
    );
  }
}
