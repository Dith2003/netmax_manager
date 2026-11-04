import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart';
import '../data/repositories/clientes_repository.dart';
import '../data/repositories/pagos_repository.dart';
import '../data/repositories/vencimientos_repository.dart';
import '../domain/cobranza.dart';

/// La base de datos se crea en main() y se inyecta con overrideWithValue.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider se configura en main()'),
);

final clientesRepositoryProvider = Provider<ClientesRepository>(
  (ref) => ClientesRepository(ref.watch(databaseProvider)),
);

final planesProvider = StreamProvider<List<Plan>>(
  (ref) => ref.watch(clientesRepositoryProvider).vigilarPlanes(),
);

final clientesProvider =
    StreamProvider.autoDispose.family<List<Cliente>, FiltroClientes>(
  (ref, filtro) => ref.watch(clientesRepositoryProvider).vigilarClientes(filtro),
);

final clienteProvider = StreamProvider.autoDispose.family<Cliente?, int>(
  (ref, id) => ref.watch(clientesRepositoryProvider).vigilarCliente(id),
);

final instalacionesProvider =
    StreamProvider.autoDispose.family<List<Instalacion>, int>(
  (ref, clienteId) =>
      ref.watch(clientesRepositoryProvider).vigilarInstalaciones(clienteId),
);

final equiposProvider = StreamProvider.autoDispose.family<List<Equipo>, int>(
  (ref, clienteId) => ref.watch(clientesRepositoryProvider).vigilarEquipos(clienteId),
);

final historialProvider =
    StreamProvider.autoDispose.family<List<HistorialEstado>, int>(
  (ref, clienteId) => ref.watch(clientesRepositoryProvider).vigilarHistorial(clienteId),
);

// ----- Pagos -----

final pagosRepositoryProvider = Provider<PagosRepository>(
  (ref) => PagosRepository(ref.watch(databaseProvider)),
);

/// Meses del cliente con lo pagado de cada uno.
final periodosProvider = StreamProvider.autoDispose.family<List<PeriodoSaldo>, int>(
  (ref, clienteId) => ref.watch(pagosRepositoryProvider).vigilarPeriodos(clienteId),
);

/// Pagos del cliente con los meses que cubrió cada uno.
final pagosProvider = StreamProvider.autoDispose.family<List<PagoConDetalle>, int>(
  (ref, clienteId) => ref.watch(pagosRepositoryProvider).vigilarPagos(clienteId),
);

// ----- Vencimientos y adeudos -----

final vencimientosRepositoryProvider = Provider<VencimientosRepository>(
  (ref) => VencimientosRepository(ref.watch(databaseProvider)),
);

/// Clientes con adeudo a la fecha de hoy.
final adeudosProvider = StreamProvider.autoDispose<List<AdeudoCliente>>(
  (ref) => ref.watch(vencimientosRepositoryProvider).vigilarAdeudos(DateTime.now()),
);
