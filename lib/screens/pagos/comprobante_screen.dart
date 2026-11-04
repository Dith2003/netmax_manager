import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../domain/reportes.dart';
import '../../providers/providers.dart';
import '../../reportes/pdf_reportes.dart';
import '../../widgets/comunes.dart';

/// Abre el comprobante de un pago (vista previa con imprimir y compartir).
Future<void> abrirComprobante(BuildContext context, int pagoId) {
  return Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => ComprobanteScreen(pagoId: pagoId),
  ));
}

/// Vista previa del comprobante de un pago.
class ComprobanteScreen extends ConsumerWidget {
  const ComprobanteScreen({super.key, required this.pagoId});

  final int pagoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<Uint8List> generar(PdfPageFormat _) async {
      final estilo = await ref.read(estiloPdfProvider.future);
      final ahora = DateTime.now();
      final datos = await ref.read(reportesRepositoryProvider).comprobante(pagoId, ahora);
      if (datos == null) throw StateError('No se encontró el pago.');
      return pdfComprobante(estilo: estilo, datos: datos, generado: ahora);
    }

    return Scaffold(
      appBar: AppBar(title: Text('Comprobante N° ${numeroComprobante(pagoId)}')),
      body: PdfPreview(
        build: generar,
        initialPageFormat: const PdfPageFormat(5.5 * PdfPageFormat.inch, 8.5 * PdfPageFormat.inch),
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        pdfFileName: 'netmax_comprobante_${numeroComprobante(pagoId)}.pdf',
        onError: (context, error) => ErrorVista(error),
      ),
    );
  }
}
