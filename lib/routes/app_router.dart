import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/adeudos/adeudos_screen.dart';
import '../screens/clientes/cliente_detalle_screen.dart';
import '../screens/clientes/cliente_form_screen.dart';
import '../screens/clientes/clientes_screen.dart';
import '../screens/clientes/estado_cuenta_screen.dart';
import '../screens/inicio/inicio_screen.dart';
import '../screens/pagos/registrar_pago_screen.dart';

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
        ],
      ),
    ],
  );
}

/// Barra de navegación inferior con las secciones principales.
class _ConNavegacion extends StatelessWidget {
  const _ConNavegacion({required this.ubicacion, required this.child});

  final String ubicacion;
  final Widget child;

  static const _secciones = ['/inicio', '/clientes', '/adeudos'];

  @override
  Widget build(BuildContext context) {
    final indice = ubicacion.startsWith('/adeudos')
        ? 2
        : ubicacion.startsWith('/clientes')
            ? 1
            : 0;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: indice,
        onDestinationSelected: (i) => context.go(_secciones[i]),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Clientes'),
          NavigationDestination(icon: Icon(Icons.money_off), label: 'Adeudos'),
        ],
      ),
    );
  }
}
