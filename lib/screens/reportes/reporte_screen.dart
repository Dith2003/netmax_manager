import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../core/mes.dart';
import '../../providers/providers.dart';
import '../../reportes/pdf_reportes.dart';
import '../../widgets/comunes.dart';
import 'reportes_screen.dart';

/// Vista previa de un reporte en PDF, con opciones de periodo, imprimir y compartir.
class ReporteScreen extends ConsumerStatefulWidget {
  const ReporteScreen({super.key, required this.tipo});

  final TipoReporte tipo;

  @override
  ConsumerState<ReporteScreen> createState() => _ReporteScreenState();
}

class _ReporteScreenState extends ConsumerState<ReporteScreen> {
  late final DateTime _hoy = DateTime.now();
  late int _anio = _hoy.year;
  late Mes _mes = Mes.deFecha(_hoy);

  /// Clave que cambia con el periodo elegido, para regenerar la vista previa.
  String get _clave => switch (widget.tipo) {
        TipoReporte.ingresos => 'ingresos-$_anio',
        TipoReporte.pagos => 'pagos-$_mes',
        TipoReporte.adeudos => 'adeudos',
        TipoReporte.clientes => 'clientes',
      };

  String get _nombreArchivo => switch (widget.tipo) {
        TipoReporte.ingresos => 'netmax_ingresos_$_anio.pdf',
        TipoReporte.pagos => 'netmax_pagos_$_mes.pdf',
        TipoReporte.adeudos => 'netmax_adeudos_${Mes.deFecha(_hoy)}.pdf',
        TipoReporte.clientes => 'netmax_clientes_${Mes.deFecha(_hoy)}.pdf',
      };

  Future<Uint8List> _generar(PdfPageFormat _) async {
    final tema = await ref.read(temaPdfProvider.future);
    final repo = ref.read(reportesRepositoryProvider);
    switch (widget.tipo) {
      case TipoReporte.ingresos:
        final hasta = _anio == _hoy.year ? Mes.deFecha(_hoy) : Mes(_anio, 12);
        return pdfIngresos(
          tema: tema,
          meses: await repo.ingresos(Mes(_anio, 1), hasta),
          periodo: _anio == _hoy.year
              ? 'Enero a ${hasta.nombre}'
              : 'Año $_anio',
          generado: _hoy,
        );
      case TipoReporte.pagos:
        return pdfPagos(
          tema: tema,
          pagos: await repo.pagosEntre(
            DateTime(_mes.anio, _mes.mes, 1),
            DateTime(_mes.anio, _mes.mes + 1, 0),
          ),
          periodo: _mes.nombre[0].toUpperCase() + _mes.nombre.substring(1),
          generado: _hoy,
        );
      case TipoReporte.adeudos:
        return pdfAdeudos(tema: tema, adeudos: await repo.adeudos(_hoy), generado: _hoy);
      case TipoReporte.clientes:
        return pdfClientes(tema: tema, clientes: await repo.clientes(_hoy), generado: _hoy);
    }
  }

  Widget? _selectorPeriodo() {
    switch (widget.tipo) {
      case TipoReporte.ingresos:
        return DropdownButtonFormField<int>(
          initialValue: _anio,
          decoration: const InputDecoration(labelText: 'Año', border: OutlineInputBorder()),
          items: [
            for (var a = _hoy.year; a >= _hoy.year - 4; a--)
              DropdownMenuItem(value: a, child: Text('$a')),
          ],
          onChanged: (a) {
            if (a != null) setState(() => _anio = a);
          },
        );
      case TipoReporte.pagos:
        final meses = <Mes>[];
        var m = Mes.deFecha(_hoy);
        for (var i = 0; i < 24; i++, m = m.anterior()) {
          meses.add(m);
        }
        return DropdownButtonFormField<Mes>(
          initialValue: _mes,
          decoration: const InputDecoration(labelText: 'Mes', border: OutlineInputBorder()),
          items: [
            for (final m in meses) DropdownMenuItem(value: m, child: Text(m.nombre)),
          ],
          onChanged: (m) {
            if (m != null) setState(() => _mes = m);
          },
        );
      case TipoReporte.adeudos:
      case TipoReporte.clientes:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selector = _selectorPeriodo();
    return Scaffold(
      appBar: AppBar(title: Text(widget.tipo.titulo)),
      body: Column(
        children: [
          if (selector != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: selector,
            ),
          Expanded(
            child: PdfPreview(
              key: ValueKey(_clave),
              build: _generar,
              initialPageFormat: PdfPageFormat.letter,
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
              pdfFileName: _nombreArchivo,
              onError: (context, error) => ErrorVista(error),
            ),
          ),
        ],
      ),
    );
  }
}
