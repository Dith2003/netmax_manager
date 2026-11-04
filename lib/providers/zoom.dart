/// Zoom de toda la interfaz (útil en monitores grandes o para leer mejor).
///
/// Se cambia con los botones del panel lateral o con Ctrl + / Ctrl − / Ctrl 0,
/// y se guarda en `configuraciones` (clave `zoom`).
library;

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart';
import 'providers.dart';

/// Niveles de zoom disponibles (1.0 = 100 %).
const nivelesZoom = [0.8, 0.9, 1.0, 1.1, 1.25, 1.5];

/// Siguiente nivel en la dirección [direccion] (+1 acercar, −1 alejar).
double siguienteZoom(double actual, int direccion) {
  if (direccion > 0) {
    return nivelesZoom.firstWhere((z) => z > actual + 0.001, orElse: () => nivelesZoom.last);
  }
  return nivelesZoom.lastWhere((z) => z < actual - 0.001, orElse: () => nivelesZoom.first);
}

/// "100 %"
String textoZoom(double zoom) => '${(zoom * 100).round()} %';

const _claveZoom = 'zoom';

/// Lee el zoom guardado (1.0 si no hay o si no se puede leer).
Future<double> leerZoom(AppDatabase db) async {
  try {
    final fila = await (db.select(db.configuraciones)..where((c) => c.clave.equals(_claveZoom)))
        .getSingleOrNull();
    final valor = double.tryParse(fila?.valor ?? '');
    return valor != null && nivelesZoom.contains(valor) ? valor : 1.0;
  } catch (_) {
    return 1.0;
  }
}

Future<void> guardarZoom(AppDatabase db, double zoom) async {
  await db.into(db.configuraciones).insertOnConflictUpdate(
      ConfiguracionesCompanion(clave: const Value(_claveZoom), valor: Value('$zoom')));
}

/// Zoom con el que arranca la app (se lee de la base en main()).
final zoomInicialProvider = Provider<double>((ref) => 1.0);

class ZoomNotifier extends Notifier<double> {
  @override
  double build() => ref.read(zoomInicialProvider);

  void fijar(double zoom) {
    if (zoom == state) return;
    state = zoom;
    try {
      guardarZoom(ref.read(databaseProvider), zoom).catchError((_) {});
    } catch (_) {
      // Sin base de datos (pruebas): solo se cambia en pantalla.
    }
  }

  void acercar() => fijar(siguienteZoom(state, 1));
  void alejar() => fijar(siguienteZoom(state, -1));
  void restablecer() => fijar(1.0);
}

final zoomProvider = NotifierProvider<ZoomNotifier, double>(ZoomNotifier.new);
