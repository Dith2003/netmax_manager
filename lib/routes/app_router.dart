import 'package:go_router/go_router.dart';

import '../screens/clientes/cliente_detalle_screen.dart';
import '../screens/clientes/cliente_form_screen.dart';
import '../screens/clientes/clientes_screen.dart';
import '../screens/pagos/registrar_pago_screen.dart';

/// Rutas de la app. La pantalla inicial será el Dashboard (Sprint 5);
/// por ahora se abre la lista de clientes.
GoRouter crearRouter() {
  return GoRouter(
    initialLocation: '/clientes',
    routes: [
      GoRoute(path: '/', redirect: (_, _) => '/clientes'),
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
            builder: (_, state) => ClienteDetalleScreen(
              clienteId: int.parse(state.pathParameters['id']!),
            ),
            routes: [
              GoRoute(
                path: 'editar',
                builder: (_, state) => ClienteFormScreen(
                  clienteId: int.parse(state.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: 'pago',
                builder: (_, state) => RegistrarPagoScreen(
                  clienteId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
