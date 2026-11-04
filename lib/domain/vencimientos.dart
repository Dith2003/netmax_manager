/// Reglas de vencimientos (lógica pura, sin base de datos ni pantallas).
///
/// - Cada cliente tiene un primer mes de cobro (el mes del alta, el siguiente u otro).
/// - Se generan los meses desde ese primer mes hasta el mes actual.
/// - Solo se generan los meses en los que el cliente estaba ACTIVO en la fecha de
///   vencimiento: mientras está suspendido o cancelado no se le cobra.
///   Lo que ya debía antes de suspenderse lo sigue debiendo.
/// - Los meses se pueden agregar a mano (cobro manual) o marcar como cortesía.
library;

import '../core/mes.dart';
import '../data/db/enums.dart';

/// Un cambio de estado del cliente (del historial).
typedef CambioEstado = ({DateTime fecha, EstadoCliente estado});

/// Primer mes de cobro sugerido para un cliente nuevo: el mes siguiente al alta.
Mes primerMesSugerido(DateTime fechaAlta) => Mes.deFecha(fechaAlta).siguiente();

/// Primer mes de cobro de un cliente. Si no está guardado, el mes de la fecha de alta.
Mes primerMesDeCobro({required String? primerMesCobro, required DateTime fechaAlta}) =>
    primerMesCobro != null ? Mes.parse(primerMesCobro) : Mes.deFecha(fechaAlta);

/// Meses que se pueden elegir como primer mes de cobro: desde el mes del alta
/// hasta 3 meses después del mes actual (o del alta, si es posterior).
List<Mes> opcionesPrimerMes(DateTime fechaAlta, DateTime hoy) {
  final desde = Mes.deFecha(fechaAlta);
  var hasta = Mes.deFecha(hoy);
  if (hasta.compareTo(desde) < 0) hasta = desde;
  for (var i = 0; i < 3; i++) {
    hasta = hasta.siguiente();
  }
  final meses = <Mes>[];
  for (var m = desde; m.compareTo(hasta) <= 0; m = m.siguiente()) {
    meses.add(m);
  }
  return meses;
}

/// Estado del cliente al final del día [fecha], según su historial.
/// Si no hay cambios registrados hasta esa fecha, se considera activo
/// (clientes dados de alta con fecha anterior a su registro en el sistema).
///
/// [historial] debe venir en el orden en que se registró: si dos cambios tienen
/// la misma fecha y hora, cuenta el último de la lista.
EstadoCliente estadoEnFecha(List<CambioEstado> historial, DateTime fecha) {
  final finDelDia = DateTime(fecha.year, fecha.month, fecha.day + 1);
  EstadoCliente? estado;
  DateTime? fechaEstado;
  for (final c in historial) {
    if (!c.fecha.isBefore(finDelDia)) continue;
    if (fechaEstado == null || !c.fecha.isBefore(fechaEstado)) {
      estado = c.estado;
      fechaEstado = c.fecha;
    }
  }
  return estado ?? EstadoCliente.activo;
}

/// Meses que faltan por generar para un cliente, del más antiguo al más reciente.
///
/// Recorre desde [primerMes] hasta el mes de [hoy]; omite los que ya existen y
/// los que vencen mientras el cliente no estaba activo.
List<Mes> mesesPorGenerar({
  required Mes primerMes,
  required Set<Mes> existentes,
  required int diaCorte,
  required List<CambioEstado> historial,
  required DateTime hoy,
}) {
  final ultimo = Mes.deFecha(hoy);
  final resultado = <Mes>[];
  for (var m = primerMes; m.compareTo(ultimo) <= 0; m = m.siguiente()) {
    if (existentes.contains(m)) continue;
    final vence = m.fechaVencimiento(diaCorte);
    if (estadoEnFecha(historial, vence) == EstadoCliente.activo) {
      resultado.add(m);
    }
  }
  return resultado;
}

/// Situación de un mes para mostrar en el estado de cuenta.
enum SituacionMes { pagado, cortesia, abonado, pendiente, vencido }

SituacionMes situacionMes({
  required bool esCortesia,
  required int saldo,
  required int pagado,
  required DateTime vencimiento,
  required DateTime hoy,
}) {
  if (esCortesia) return SituacionMes.cortesia;
  if (saldo == 0) return SituacionMes.pagado;
  final hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);
  if (vencimiento.isBefore(hoySinHora)) return SituacionMes.vencido;
  return pagado > 0 ? SituacionMes.abonado : SituacionMes.pendiente;
}
