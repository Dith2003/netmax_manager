import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../core/mes.dart';
import '../../providers/providers.dart';
import '../../reportes/guardar_pdf.dart';
import '../../reportes/pdf_reportes.dart';
import '../../widgets/comunes.dart';
import '../../widgets/disposicion.dart';
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
    final estilo = await ref.read(estiloPdfProvider.future);
    final repo = ref.read(reportesRepositoryProvider);
    switch (widget.tipo) {
      case TipoReporte.ingresos:
        final hasta = _anio == _hoy.year ? Mes.deFecha(_hoy) : Mes(_anio, 12);
        return pdfIngresos(
          estilo: estilo,
          meses: await repo.ingresos(Mes(_anio, 1), hasta),
          periodo: _anio == _hoy.year
              ? 'Enero a ${hasta.nombre}'
              : 'Año $_anio',
          generado: _hoy,
        );
      case TipoReporte.pagos:
        return pdfPagos(
          estilo: estilo,
          pagos: await repo.pagosEntre(
            DateTime(_mes.anio, _mes.mes, 1),
            DateTime(_mes.anio, _mes.mes + 1, 0),
          ),
          periodo: _mes.nombre[0].toUpperCase() + _mes.nombre.substring(1),
          generado: _hoy,
        );
      case TipoReporte.adeudos:
        return pdfAdeudos(estilo: estilo, adeudos: await repo.adeudos(_hoy), generado: _hoy);
      case TipoReporte.clientes:
        return pdfClientes(estilo: estilo, clientes: await repo.clientes(_hoy), generado: _hoy);
    }
  }

  Widget? _selectorPeriodo() {
    switch (widget.tipo) {
      case TipoReporte.ingresos:
        return DropdownButtonFormField<int>(
          initialValue: _anio,
          decoration: const InputDecoration(labelText: 'Año'),
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
          decoration: const InputDecoration(labelText: 'Mes'),
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
    final vista = PdfPreview(
      key: ValueKey(_clave),
      build: _generar,
      initialPageFormat: PdfPageFormat.letter,
      canChangePageFormat: false,
      canChangeOrientation: false,
      canDebug: false,
      pdfFileName: _nombreArchivo,
      onError: (context, error) => ErrorVista(error),
      actions: accionesPdf(_nombreArchivo),
    );

    // Escritorio: opciones a la izquierda y la vista previa a la derecha.
    if (esEscritorio(context)) {
      final texto = Theme.of(context).textTheme;
      final scheme = Theme.of(context).colorScheme;
      return Scaffold(
        appBar: AppBar(title: Text(widget.tipo.titulo)),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 320,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                border: Border(right: BorderSide(color: scheme.outlineVariant)),
              ),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: scheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(widget.tipo.icono, color: scheme.secondary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(widget.tipo.titulo, style: texto.titleMedium)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(widget.tipo.descripcion,
                      style: texto.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                  const SizedBox(height: 20),
                  if (selector != null) ...[
                    Text('Periodo', style: texto.labelLarge),
                    const SizedBox(height: 8),
                    selector,
                    const SizedBox(height: 20),
                  ],
                  Text('Incluye', style: texto.labelLarge),
                  const SizedBox(height: 8),
                  for (final d in widget.tipo.detalles)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(Icons.check, size: 16, color: scheme.secondary),
                          const SizedBox(width: 8),
                          Expanded(child: Text(d)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (esComputadora) ...[
                    FilledButton.icon(
                      onPressed: () => guardarPdf(
                          context, _nombreArchivo, () => _generar(PdfPageFormat.letter)),
                      icon: const Icon(Icons.save_alt),
                      label: const Text('Guardar PDF'),
                    ),
                    const SizedBox(height: 8),
                  ],
                  OutlinedButton.icon(
                    onPressed: () => Printing.layoutPdf(
                      onLayout: _generar,
                      name: _nombreArchivo,
                      format: PdfPageFormat.letter,
                    ),
                    icon: const Icon(Icons.print_outlined),
                    label: const Text('Imprimir'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'También puedes usar los botones de la barra de la vista previa.',
                    style: texto.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Expanded(child: vista),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.tipo.titulo)),
      body: Column(
        children: [
          if (selector != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: selector,
            ),
          Expanded(child: vista),
        ],
      ),
    );
  }
}
