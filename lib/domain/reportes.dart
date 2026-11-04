/// Cálculos de los reportes (lógica pura, sin base de datos ni pantallas).
library;

import '../core/mes.dart';
import '../data/db/enums.dart';

/// Un pago vigente con lo que cubrió, para los reportes.
class FilaPago {
  const FilaPago({
    this.id,
    required this.fecha,
    required this.cliente,
    required this.monto,
    required this.metodo,
    this.folio,
    this.cubre = '',
  });

  /// Id del pago (para abrir su comprobante).
  final int? id;
  final DateTime fecha;
  final String cliente;
  final int monto;
  final MetodoPago metodo;
  final String? folio;

  /// Descripción de lo que cubrió: "oct 2026 – dic 2026, Antena no devuelta".
  final String cubre;
}

/// Ingresos de un mes: total, número de pagos y total por método.
class IngresoMes {
  const IngresoMes({
    required this.mes,
    required this.total,
    required this.pagos,
    required this.porMetodo,
  });

  final Mes mes;
  final int total;
  final int pagos;
  final Map<MetodoPago, int> porMetodo;
}

/// Agrupa los pagos por el mes en que se recibieron, de [desde] a [hasta]
/// (incluidos). Devuelve un renglón por mes aunque no haya pagos.
List<IngresoMes> ingresosPorMes(List<FilaPago> pagos, Mes desde, Mes hasta) {
  final resultado = <IngresoMes>[];
  for (var m = desde; m.compareTo(hasta) <= 0; m = m.siguiente()) {
    var total = 0;
    var cuantos = 0;
    final porMetodo = {for (final metodo in MetodoPago.values) metodo: 0};
    for (final p in pagos) {
      if (Mes.deFecha(p.fecha) != m) continue;
      total += p.monto;
      cuantos++;
      porMetodo[p.metodo] = porMetodo[p.metodo]! + p.monto;
    }
    resultado.add(IngresoMes(mes: m, total: total, pagos: cuantos, porMetodo: porMetodo));
  }
  return resultado;
}

/// Suma de una lista de ingresos (para el renglón de totales).
IngresoMes totalIngresos(List<IngresoMes> meses) {
  final porMetodo = {for (final metodo in MetodoPago.values) metodo: 0};
  var total = 0;
  var pagos = 0;
  for (final m in meses) {
    total += m.total;
    pagos += m.pagos;
    for (final metodo in MetodoPago.values) {
      porMetodo[metodo] = porMetodo[metodo]! + (m.porMetodo[metodo] ?? 0);
    }
  }
  return IngresoMes(
    mes: meses.isEmpty ? Mes.deFecha(DateTime.now()) : meses.first.mes,
    total: total,
    pagos: pagos,
    porMetodo: porMetodo,
  );
}

/// Un cliente en el reporte de clientes.
class FilaCliente {
  const FilaCliente({
    required this.nombre,
    this.zona,
    this.telefono,
    required this.precioMensual,
    required this.diaCorte,
    required this.estado,
    this.pagadoHasta,
    required this.adeudo,
  });

  final String nombre;
  final String? zona;
  final String? telefono;
  final int precioMensual;
  final int diaCorte;
  final EstadoCliente estado;
  final Mes? pagadoHasta;
  final int adeudo;
}

/// Datos de un comprobante de pago.
class DatosComprobante {
  const DatosComprobante({
    required this.pagoId,
    this.folio,
    required this.fecha,
    required this.monto,
    required this.metodo,
    required this.cancelado,
    required this.cliente,
    this.telefono,
    this.direccion,
    this.zona,
    required this.conceptos,
    this.mesesCubiertos = const [],
    this.cargosCubiertos = const [],
    this.pagadoHasta,
    required this.saldoPendiente,
    this.notas,
  });

  final int pagoId;

  /// Folio o referencia capturada (p. ej. de una transferencia).
  final String? folio;
  final DateTime fecha;
  final int monto;
  final MetodoPago metodo;
  final bool cancelado;
  final String cliente;
  final String? telefono;
  final String? direccion;
  final String? zona;

  /// Qué cubrió el pago: "Mensualidad noviembre 2026" o el concepto del cargo.
  final List<({String concepto, int monto})> conceptos;

  /// Detalle de meses y cargos cubiertos (para agrupar meses seguidos en el comprobante).
  final List<({Mes mes, int monto})> mesesCubiertos;
  final List<({String concepto, int monto})> cargosCubiertos;
  final Mes? pagadoHasta;

  /// Adeudo vencido del cliente a la fecha en que se genera el comprobante.
  final int saldoPendiente;
  final String? notas;

  /// Número del comprobante: "000123".
  String get numero => numeroComprobante(pagoId);
}

/// Conceptos del comprobante en pocas líneas (para el formato tipo cheque):
/// los meses seguidos se agrupan ("Mensualidades oct 2026 – dic 2026 (3)") y,
/// si aun así son más de [maximo], los últimos se suman en "Otros N conceptos".
List<({String concepto, int monto})> conceptosCompactos(DatosComprobante d, {int maximo = 4}) {
  final lineas = <({String concepto, int monto})>[];
  if (d.mesesCubiertos.isEmpty && d.cargosCubiertos.isEmpty) {
    lineas.addAll(d.conceptos);
  } else {
    final meses = [...d.mesesCubiertos]..sort((a, b) => a.mes.compareTo(b.mes));
    var i = 0;
    while (i < meses.length) {
      var j = i;
      var suma = meses[i].monto;
      while (j + 1 < meses.length && meses[j].mes.siguiente() == meses[j + 1].mes) {
        j++;
        suma += meses[j].monto;
      }
      lineas.add(j == i
          ? (concepto: 'Mensualidad ${meses[i].mes.nombre}', monto: suma)
          : (
              concepto: 'Mensualidades ${meses[i].mes.nombreCorto} – '
                  '${meses[j].mes.nombreCorto} (${j - i + 1})',
              monto: suma,
            ));
      i = j + 1;
    }
    lineas.addAll(d.cargosCubiertos);
  }
  if (lineas.length <= maximo) return lineas;
  final resto = lineas.sublist(maximo - 1);
  return [
    ...lineas.take(maximo - 1),
    (
      concepto: 'Otros ${resto.length} conceptos',
      monto: resto.fold<int>(0, (s, c) => s + c.monto),
    ),
  ];
}

/// Número de comprobante a partir del id del pago: 123 -> "000123".
String numeroComprobante(int pagoId) => pagoId.toString().padLeft(6, '0');
