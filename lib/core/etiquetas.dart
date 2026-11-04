/// Textos en español para mostrar los valores fijos en pantalla.
library;

import '../data/db/enums.dart';
import '../domain/vencimientos.dart';

extension EtiquetaTipoContratacion on TipoContratacion {
  String get etiqueta => switch (this) {
        TipoContratacion.compraEquipo => 'Compra de equipo + instalación',
        TipoContratacion.equipoPropio => 'Equipo propio (solo conexión)',
        TipoContratacion.equipoPrestado => 'Equipo prestado por NET_MAX',
        TipoContratacion.otro => 'Otro (personalizado)',
      };

  String get etiquetaCorta => switch (this) {
        TipoContratacion.compraEquipo => 'Compró equipo',
        TipoContratacion.equipoPropio => 'Equipo propio',
        TipoContratacion.equipoPrestado => 'Equipo prestado',
        TipoContratacion.otro => 'Otro',
      };

  /// Qué incluye cada tipo (ayuda en el formulario y en Configuración).
  String get descripcion => switch (this) {
        TipoContratacion.compraEquipo =>
          'El cliente compró la antena y pagó la instalación; el equipo es suyo.',
        TipoContratacion.equipoPropio =>
          'El cliente ya tenía su equipo; NET_MAX solo le da la conexión.',
        TipoContratacion.equipoPrestado =>
          'NET_MAX presta el equipo: se registra en Equipos para recuperarlo si cancela.',
        TipoContratacion.otro =>
          'Cualquier otro acuerdo: escribe en qué consiste al registrar al cliente.',
      };
}

/// Texto de la contratación de un cliente: si es "otro", su descripción libre.
String textoContratacion(TipoContratacion tipo, String? detalle) =>
    tipo == TipoContratacion.otro && (detalle?.trim().isNotEmpty ?? false)
        ? detalle!.trim()
        : tipo.etiqueta;

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
        PropiedadEquipo.netmax => 'De NET_MAX',
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
