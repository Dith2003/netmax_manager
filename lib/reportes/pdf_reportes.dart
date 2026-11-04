/// Generación de los reportes en PDF (tamaño carta).
library;

import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/dinero.dart';
import '../core/etiquetas.dart';
import '../core/fechas.dart';
import '../data/db/enums.dart';
import '../data/repositories/vencimientos_repository.dart';
import '../domain/reportes.dart';

/// Tipografía de los reportes (Open Sans, incluida en assets/fonts).
Future<pw.ThemeData> cargarTemaPdf() async {
  final normal = pw.Font.ttf(await rootBundle.load('assets/fonts/OpenSans-Regular.ttf'));
  final negrita = pw.Font.ttf(await rootBundle.load('assets/fonts/OpenSans-Bold.ttf'));
  return pw.ThemeData.withFont(base: normal, bold: negrita);
}

const _gris = PdfColor.fromInt(0xFF5F6368);
const _lineas = PdfColor.fromInt(0xFFDADCE0);
const _fondoEncabezado = PdfColor.fromInt(0xFFE8EAF6);

/// Documento base: encabezado con negocio, título y subtítulo; pie con página.
Future<Uint8List> _documento({
  required pw.ThemeData tema,
  required String titulo,
  required String subtitulo,
  required DateTime generado,
  required List<pw.Widget> contenido,
  PdfPageFormat formato = PdfPageFormat.letter,
}) {
  final doc = pw.Document(title: titulo, author: 'NetMAX', creator: 'NetMAX Manager');
  doc.addPage(pw.MultiPage(
    theme: tema,
    pageFormat: formato,
    margin: const pw.EdgeInsets.all(36),
    header: (context) => pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _lineas)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('NetMAX', style: const pw.TextStyle(fontSize: 10, color: _gris)),
                pw.Text(titulo,
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Text(subtitulo, style: const pw.TextStyle(fontSize: 10, color: _gris)),
              ],
            ),
          ),
          pw.Text('Generado el ${formatoFecha(generado)}',
              style: const pw.TextStyle(fontSize: 8, color: _gris)),
        ],
      ),
    ),
    footer: (context) => pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text('Página ${context.pageNumber} de ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 8, color: _gris)),
    ),
    build: (context) => contenido,
  ));
  return doc.save();
}

/// Tabla con encabezado sombreado; [numericas] son las columnas alineadas a la derecha.
pw.Widget _tabla({
  required List<String> encabezados,
  required List<List<String>> filas,
  Set<int> numericas = const {},
  List<String>? totales,
  Map<int, pw.TableColumnWidth>? anchos,
}) {
  pw.Alignment alinear(int i) =>
      numericas.contains(i) ? pw.Alignment.centerRight : pw.Alignment.centerLeft;
  return pw.TableHelper.fromTextArray(
    headers: encabezados,
    data: [...filas, ?totales],
    columnWidths: anchos,
    border: const pw.TableBorder(
      horizontalInside: pw.BorderSide(color: _lineas, width: 0.5),
      bottom: pw.BorderSide(color: _lineas, width: 0.5),
    ),
    headerDecoration: const pw.BoxDecoration(color: _fondoEncabezado),
    headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
    cellStyle: const pw.TextStyle(fontSize: 9),
    cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
    headerAlignments: {
      for (var i = 0; i < encabezados.length; i++) i: alinear(i),
    },
    cellAlignments: {
      for (var i = 0; i < encabezados.length; i++) i: alinear(i),
    },
    // Renglón de totales sombreado y en negritas (el encabezado es el renglón 0).
    cellDecoration: totales == null
        ? null
        : (index, data, rowNum) => rowNum == filas.length + 1
            ? const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF1F3F4))
            : const pw.BoxDecoration(),
    textStyleBuilder: totales == null
        ? null
        : (index, data, rowNum) => rowNum == filas.length + 1
            ? pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)
            : null,
  );
}

pw.Widget _resumen(List<(String, String)> datos) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Wrap(
        spacing: 24,
        runSpacing: 6,
        children: [
          for (final (etiqueta, valor) in datos)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(etiqueta, style: const pw.TextStyle(fontSize: 8, color: _gris)),
                pw.Text(valor, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
              ],
            ),
        ],
      ),
    );

pw.Widget _sinDatos(String texto) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 24),
      child: pw.Text(texto, style: const pw.TextStyle(color: _gris)),
    );

// ---------------------------------------------------------------------------
// Reportes
// ---------------------------------------------------------------------------

/// Ingresos por mes, con el desglose por método de pago.
Future<Uint8List> pdfIngresos({
  required pw.ThemeData tema,
  required List<IngresoMes> meses,
  required String periodo,
  required DateTime generado,
}) {
  final total = totalIngresos(meses);
  final metodos = MetodoPago.values;
  return _documento(
    tema: tema,
    titulo: 'Ingresos por mes',
    subtitulo: periodo,
    generado: generado,
    contenido: [
      _resumen([
        ('Total cobrado', formatoDinero(total.total)),
        ('Pagos recibidos', '${total.pagos}'),
      ]),
      _tabla(
        encabezados: ['Mes', 'Pagos', for (final m in metodos) m.etiqueta, 'Total'],
        filas: [
          for (final m in meses)
            [
              m.mes.nombre,
              '${m.pagos}',
              for (final metodo in metodos) formatoDinero(m.porMetodo[metodo] ?? 0),
              formatoDinero(m.total),
            ],
        ],
        totales: [
          'Total',
          '${total.pagos}',
          for (final metodo in metodos) formatoDinero(total.porMetodo[metodo] ?? 0),
          formatoDinero(total.total),
        ],
        numericas: {for (var i = 1; i < metodos.length + 3; i++) i},
      ),
    ],
  );
}

/// Detalle de los pagos recibidos en un periodo.
Future<Uint8List> pdfPagos({
  required pw.ThemeData tema,
  required List<FilaPago> pagos,
  required String periodo,
  required DateTime generado,
}) {
  final total = pagos.fold<int>(0, (s, p) => s + p.monto);
  return _documento(
    tema: tema,
    titulo: 'Pagos recibidos',
    subtitulo: periodo,
    generado: generado,
    formato: PdfPageFormat.letter.landscape,
    contenido: [
      _resumen([
        ('Total cobrado', formatoDinero(total)),
        ('Pagos', '${pagos.length}'),
      ]),
      if (pagos.isEmpty)
        _sinDatos('No hay pagos en este periodo.')
      else
        _tabla(
          encabezados: ['Fecha', 'Cliente', 'Método', 'Folio', 'Cubre', 'Monto'],
          filas: [
            for (final p in pagos)
              [
                formatoFecha(p.fecha),
                p.cliente,
                p.metodo.etiqueta,
                p.folio ?? '',
                p.cubre,
                formatoDinero(p.monto),
              ],
          ],
          totales: ['', 'Total', '', '', '', formatoDinero(total)],
          numericas: {5},
          anchos: const {
            0: pw.FixedColumnWidth(60),
            1: pw.FlexColumnWidth(3),
            2: pw.FixedColumnWidth(70),
            3: pw.FixedColumnWidth(60),
            4: pw.FlexColumnWidth(4),
            5: pw.FixedColumnWidth(70),
          },
        ),
    ],
  );
}

/// Clientes con adeudo (para la ruta de cobro).
Future<Uint8List> pdfAdeudos({
  required pw.ThemeData tema,
  required List<AdeudoCliente> adeudos,
  required DateTime generado,
}) {
  final total = adeudos.fold<int>(0, (s, a) => s + a.adeudo.total);
  return _documento(
    tema: tema,
    titulo: 'Clientes con adeudo',
    subtitulo: 'Al ${formatoFecha(generado)}',
    generado: generado,
    contenido: [
      _resumen([
        ('Total por cobrar', formatoDinero(total)),
        ('Clientes con adeudo', '${adeudos.length}'),
      ]),
      if (adeudos.isEmpty)
        _sinDatos('Ningún cliente tiene adeudos.')
      else
        _tabla(
          encabezados: ['Cliente', 'Zona', 'Teléfono', 'Debe', 'Desde', 'Estado', 'Total'],
          filas: [
            for (final a in adeudos)
              [
                a.nombre,
                a.zona ?? '',
                a.telefono ?? '',
                a.adeudo.descripcion,
                formatoFecha(a.adeudo.vencidoDesde!),
                a.estado.etiqueta,
                formatoDinero(a.adeudo.total),
              ],
          ],
          totales: ['Total', '', '', '', '', '', formatoDinero(total)],
          numericas: {6},
        ),
    ],
  );
}

/// Lista de clientes con su situación de pago.
Future<Uint8List> pdfClientes({
  required pw.ThemeData tema,
  required List<FilaCliente> clientes,
  required DateTime generado,
}) {
  int cuantos(EstadoCliente e) => clientes.where((c) => c.estado == e).length;
  return _documento(
    tema: tema,
    titulo: 'Clientes',
    subtitulo: 'Al ${formatoFecha(generado)}',
    generado: generado,
    formato: PdfPageFormat.letter.landscape,
    contenido: [
      _resumen([
        ('Activos', '${cuantos(EstadoCliente.activo)}'),
        ('Suspendidos', '${cuantos(EstadoCliente.suspendido)}'),
        ('Cancelados', '${cuantos(EstadoCliente.cancelado)}'),
      ]),
      if (clientes.isEmpty)
        _sinDatos('No hay clientes registrados.')
      else
        _tabla(
          encabezados: [
            'Cliente', 'Zona', 'Teléfono', 'Precio', 'Corte', 'Estado', 'Pagado hasta', 'Adeudo',
          ],
          filas: [
            for (final c in clientes)
              [
                c.nombre,
                c.zona ?? '',
                c.telefono ?? '',
                formatoDinero(c.precioMensual),
                'Día ${c.diaCorte}',
                c.estado.etiqueta,
                c.pagadoHasta?.nombreCorto ?? '—',
                c.adeudo == 0 ? '—' : formatoDinero(c.adeudo),
              ],
          ],
          numericas: {3, 7},
        ),
    ],
  );
}
