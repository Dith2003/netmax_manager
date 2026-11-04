import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart';
import '../data/repositories/clientes_repository.dart';
import '../data/repositories/dashboard_repository.dart';
import '../data/repositories/pagos_repository.dart';
import '../data/repositories/planes_repository.dart';
import '../data/repositories/reportes_repository.dart';
import '../data/repositories/vencimientos_repository.dart';
import '../data/respaldos/respaldo_service.dart';
import '../domain/cobranza.dart';
import '../domain/dashboard.dart';
import '../reportes/pdf_reportes.dart';

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

// ----- Planes y contratación (Configuración) -----

final planesRepositoryProvider = Provider<PlanesRepository>(
  (ref) => PlanesRepository(ref.watch(databaseProvider)),
);

/// Todos los planes, activos o no (p. ej. para mostrar el plan de un cliente).
final todosLosPlanesProvider = StreamProvider<List<Plan>>(
  (ref) => ref.watch(planesRepositoryProvider).vigilarTodos(),
);

/// Planes con cuántos clientes los tienen (pantalla de Configuración).
final planesConUsoProvider = StreamProvider.autoDispose<List<PlanConUso>>(
  (ref) => ref.watch(planesRepositoryProvider).vigilarPlanesConUso(),
);

/// Contrataciones personalizadas ya usadas, para sugerirlas.
final contratacionesPersonalizadasProvider =
    StreamProvider.autoDispose<List<({String detalle, int clientes})>>(
  (ref) => ref.watch(clientesRepositoryProvider).vigilarContratacionesPersonalizadas(),
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

/// Cargos extra vigentes del cliente con lo pagado de cada uno.
final cargosProvider = StreamProvider.autoDispose.family<List<CargoSaldo>, int>(
  (ref, clienteId) => ref.watch(vencimientosRepositoryProvider).vigilarCargos(clienteId),
);

// ----- Inicio -----

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepository(ref.watch(databaseProvider)),
);

/// Resumen de la pantalla de inicio a la fecha de hoy.
final resumenProvider = StreamProvider.autoDispose<ResumenDashboard>(
  (ref) => ref.watch(dashboardRepositoryProvider).vigilarResumen(DateTime.now()),
);

// ----- Reportes -----

final reportesRepositoryProvider = Provider<ReportesRepository>(
  (ref) => ReportesRepository(ref.watch(databaseProvider)),
);

/// Tipografía y logo de los PDF (se cargan una vez).
final estiloPdfProvider = FutureProvider<EstiloPdf>((ref) => cargarEstiloPdf());

// ----- Respaldos -----

final respaldoServiceProvider = Provider<RespaldoService>(
  (ref) => RespaldoService(ref.watch(databaseProvider)),
);

/// Fecha del último respaldo (null si nunca).
final ultimoRespaldoProvider = StreamProvider.autoDispose<DateTime?>(
  (ref) => ref.watch(respaldoServiceProvider).vigilarUltimoRespaldo(),
);

/// Restaura un respaldo: cierra la base de datos, reemplaza el archivo y
/// reinicia la app. Lo configura `AppRaiz` en main.dart.
final restaurarRespaldoProvider = Provider<Future<void> Function(String rutaRespaldo)>(
  (ref) => throw UnimplementedError('restaurarRespaldoProvider se configura en AppRaiz'),
);
