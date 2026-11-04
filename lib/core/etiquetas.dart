/// Textos en español para mostrar los valores fijos en pantalla.
library;

import '../data/db/enums.dart';
import '../domain/vencimientos.dart';

extension EtiquetaTipoContratacion on TipoContratacion {
  String get etiqueta => switch (this) {
        TipoContratacion.compraEquipo => 'Compra de equipo + instalación',
        TipoContratacion.equipoPropio => 'Equipo propio (solo conexión)',
        TipoContratacion.equipoPrestado => 'Equipo prestado por NetMAX',
      };

  String get etiquetaCorta => switch (this) {
        TipoContratacion.compraEquipo => 'Compró equipo',
        TipoContratacion.equipoPropio => 'Equipo propio',
        TipoContratacion.equipoPrestado => 'Equipo prestado',
      };
}

extension EtiquetaEstadoCliente on EstadoCliente {
  String get etiqueta => switch (this) {
        EstadoCliente.activo => 'Activo',
        EstadoCliente.suspendido => 'Suspendido',
        EstadoCliente.cancelado => 'Cancelado',
      };
}

extension EtiquetaPropiedadEquipo on PropiedadEquipo {
  String get etiqueta => switch (this) {
        PropiedadEquipo.cliente => 'Del cliente',
        PropiedadEquipo.netmax => 'De NetMAX',
      };
}

extension EtiquetaMetodoPago on MetodoPago {
  String get etiqueta => switch (this) {
        MetodoPago.efectivo => 'Efectivo',
        MetodoPago.transferencia => 'Transferencia',
        MetodoPago.deposito => 'Depósito',
        MetodoPago.otro => 'Otro',
      };
}

extension EtiquetaSituacionMes on SituacionMes {
  String get etiqueta => switch (this) {
        SituacionMes.pagado => 'Pagado',
        SituacionMes.cortesia => 'Cortesía',
        SituacionMes.abonado => 'Con abono',
        SituacionMes.pendiente => 'Por vencer',
        SituacionMes.vencido => 'Vencido',
      };
}
