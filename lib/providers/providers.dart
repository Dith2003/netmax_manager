import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart';
import '../data/repositories/clientes_repository.dart';

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
