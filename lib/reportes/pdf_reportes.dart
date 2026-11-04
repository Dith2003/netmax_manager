/// Generación de los reportes en PDF (tamaño carta).
library;

import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/dinero.dart';
import '../core/etiquetas.dart';
import '../core/fechas.dart';
import '../core/marca.dart';
import '../data/db/enums.dart';
import '../data/repositories/vencimientos_repository.dart';
import '../domain/reportes.dart';

/// Tipografía y logo de los reportes.
class EstiloPdf {
  const EstiloPdf({required this.tema, this.logo});

  final pw.ThemeData tema;
  final pw.ImageProvider? logo;
}

/// Carga la tipografía Outfit y el logo de NET_MAX (incluidos en la app).
Future<EstiloPdf> cargarEstiloPdf() async {
  final normal = pw.Font.ttf(await rootBundle.load('assets/fonts/Outfit-Regular.ttf'));
  final negrita = pw.Font.ttf(await rootBundle.load('assets/fonts/Outfit-SemiBold.ttf'));
  final logo = await rootBundle.load(ImagenesMarca.logo);
  return EstiloPdf(
    tema: pw.ThemeData.withFont(base: normal, bold: negrita),
    logo: pw.MemoryImage(logo.buffer.asUint8List()),
  );
}

const _azul = PdfColor.fromInt(0xFF13294B);
const _verde = PdfColor.fromInt(0xFF0B7A54);
const _crema = PdfColor.fromInt(0xFFF4EDE1);
const _gris = PdfColor.fromInt(0xFF5F6368);
const _lineas = PdfColor.fromInt(0xFFDDD5C8);
const _fondoTotales = PdfColor.fromInt(0xFFF4EDE1);

/// Documento base: encabezado con la marca, título y periodo; pie con datos
/// del negocio y número de página.
Future<Uint8List> _documento({
  required EstiloPdf estilo,
  required String titulo,
  required String subtitulo,
  required DateTime generado,
  required List<pw.Widget> contenido,
  PdfPageFormat formato = PdfPageFormat.letter,
}) {
  final doc = pw.Document(
      title: titulo, author: DatosNegocio.nombre, creator: '${DatosNegocio.nombre} Manager');
  doc.addPage(pw.MultiPage(
    theme: estilo.tema,
    pageFormat: formato,
    margin: const pw.EdgeInsets.fromLTRB(36, 30, 36, 30),
    header: (context) => pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _verde, width: 1.5)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (estilo.logo != null) ...[
            pw.Image(estilo.logo!, height: 34),
            pw.SizedBox(width: 8),
          ],
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.RichText(
                text: pw.TextSpan(
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  children: const [
                    pw.TextSpan(text: 'NET_', style: pw.TextStyle(color: _azul)),
                    pw.TextSpan(text: 'MAX', style: pw.TextStyle(color: _verde)),
                  ],
                ),
              ),
              pw.Text(DatosNegocio.lema, style: const pw.TextStyle(fontSize: 7.5, color: _azul)),
            ],
          ),
          pw.Spacer(),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(titulo,
                  style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: _azul)),
              pw.Text(subtitulo, style: const pw.TextStyle(fontSize: 9.5, color: _gris)),
              pw.Text('Generado el ${formatoFecha(generado)}',
                  style: const pw.TextStyle(fontSize: 7.5, color: _gris)),
            ],
          ),
        ],
      ),
    ),
    footer: (context) => pw.Container(
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _lineas, width: 0.5)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              'Tel. ${DatosNegocio.telefono}  ·  ${DatosNegocio.correo}  ·  ${DatosNegocio.direccion}',
              style: const pw.TextStyle(fontSize: 7.5, color: _gris),
            ),
          ),
          pw.Text('Página ${context.pageNumber} de ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 7.5, color: _gris)),
        ],
      ),
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
    headerDecoration: const pw.BoxDecoration(color: _azul),
    headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _crema),
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
            ? const pw.BoxDecoration(color: _fondoTotales)
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
                pw.Text(valor,
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _azul)),
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
  required EstiloPdf estilo,
  required List<IngresoMes> meses,
  required String periodo,
  required DateTime generado,
}) {
  final total = totalIngresos(meses);
  final metodos = MetodoPago.values;
  return _documento(
    estilo: estilo,
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
  required EstiloPdf estilo,
  required List<FilaPago> pagos,
  required String periodo,
  required DateTime generado,
}) {
  final total = pagos.fold<int>(0, (s, p) => s + p.monto);
  return _documento(
    estilo: estilo,
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
  required EstiloPdf estilo,
  required List<AdeudoCliente> adeudos,
  required DateTime generado,
}) {
  final total = adeudos.fold<int>(0, (s, a) => s + a.adeudo.total);
  return _documento(
    estilo: estilo,
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
  required EstiloPdf estilo,
  required List<FilaCliente> clientes,
  required DateTime generado,
}) {
  int cuantos(EstadoCliente e) => clientes.where((c) => c.estado == e).length;
  return _documento(
    estilo: estilo,
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

// ---------------------------------------------------------------------------
// Comprobante de pago (tipo cheque: un tercio de hoja carta)
// ---------------------------------------------------------------------------

/// Tamaño del comprobante: ancho de hoja carta y un tercio de su alto
/// (8.5 × 3.67 in), como un cheque. Caben 3 por hoja si se imprimen juntos.
const formatoComprobante = PdfPageFormat(
  8.5 * PdfPageFormat.inch,
  11 / 3 * PdfPageFormat.inch,
  marginAll: 16,
);

/// Comprobante de un pago en formato tipo cheque: talón a la izquierda (para
/// el archivo de NET_MAX) y el comprobante del cliente a la derecha.
Future<Uint8List> pdfComprobante({
  required EstiloPdf estilo,
  required DatosComprobante datos,
  required DateTime generado,
}) {
  final doc = pw.Document(
    title: 'Comprobante ${datos.numero}',
    author: DatosNegocio.nombre,
    creator: '${DatosNegocio.nombre} Manager',
  );
  final conceptos = conceptosCompactos(datos);
  final saldo = datos.saldoPendiente == 0
      ? 'Al corriente'
      : '${formatoDinero(datos.saldoPendiente)} (al ${formatoFecha(generado)})';

  pw.Widget etiqueta(String texto) =>
      pw.Text(texto, style: const pw.TextStyle(fontSize: 6.5, color: _gris));
  pw.Widget valor(String texto, {double tamano = 8.5, bool negrita = false}) => pw.Text(
        texto,
        maxLines: 1,
        style: pw.TextStyle(
          fontSize: tamano,
          color: _azul,
          fontWeight: negrita ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      );
  pw.Widget dato(String e, String v, {double tamano = 8.5, bool negrita = false}) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [etiqueta(e), valor(v, tamano: tamano, negrita: negrita)],
        ),
      );

  pw.Widget marca(double alto, double texto) => pw.Row(
        children: [
          if (estilo.logo != null) ...[
            pw.Image(estilo.logo!, height: alto),
            pw.SizedBox(width: 5),
          ],
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.RichText(
                text: pw.TextSpan(
                  style: pw.TextStyle(fontSize: texto, fontWeight: pw.FontWeight.bold),
                  children: const [
                    pw.TextSpan(text: 'NET_', style: pw.TextStyle(color: _azul)),
                    pw.TextSpan(text: 'MAX', style: pw.TextStyle(color: _verde)),
                  ],
                ),
              ),
              if (texto > 12)
                pw.Text(DatosNegocio.lema, style: const pw.TextStyle(fontSize: 6.5, color: _azul)),
            ],
          ),
        ],
      );

  // ----- Talón (se queda en NET_MAX) -----
  final talon = pw.Container(
    width: 128,
    padding: const pw.EdgeInsets.only(right: 10),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        marca(18, 11),
        pw.SizedBox(height: 8),
        dato('Comprobante', 'N° ${datos.numero}', negrita: true),
        dato('Fecha', formatoFecha(datos.fecha)),
        dato('Cliente', datos.cliente),
        dato('Forma de pago', datos.metodo.etiqueta),
        dato('Total', formatoDinero(datos.monto), tamano: 11, negrita: true),
        pw.Spacer(),
        pw.Text('Talón · copia NET_MAX', style: const pw.TextStyle(fontSize: 6, color: _gris)),
      ],
    ),
  );

  // Línea punteada para cortar el talón.
  final corte = pw.Container(
    width: 1,
    margin: const pw.EdgeInsets.only(right: 12),
    decoration: const pw.BoxDecoration(
      border: pw.Border(
        left: pw.BorderSide(color: _gris, width: 0.6, style: pw.BorderStyle.dashed),
      ),
    ),
  );

  // ----- Comprobante del cliente -----
  final cuerpo = pw.Expanded(
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // Encabezado: marca y número
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            marca(26, 15),
            pw.Spacer(),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const pw.BoxDecoration(
                color: _azul,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('COMPROBANTE DE PAGO',
                      style: pw.TextStyle(
                          fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: _crema)),
                  pw.Text('N° ${datos.numero}  ·  ${formatoFecha(datos.fecha)}',
                      style: const pw.TextStyle(fontSize: 8, color: _crema)),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        // Recibimos de...
        pw.RichText(
          maxLines: 1,
          text: pw.TextSpan(
            style: const pw.TextStyle(fontSize: 9, color: _gris),
            children: [
              const pw.TextSpan(text: 'Recibimos de  '),
              pw.TextSpan(
                text: datos.cliente,
                style: pw.TextStyle(
                    fontSize: 10.5, color: _azul, fontWeight: pw.FontWeight.bold),
              ),
              if (datos.direccion != null || datos.zona != null)
                pw.TextSpan(text: '   ${[?datos.direccion, ?datos.zona].join(', ')}'),
            ],
          ),
        ),
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 3, bottom: 6),
          height: 0.6,
          color: _lineas,
        ),
        // Conceptos y total
        pw.Expanded(
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    pw.Row(children: [
                      pw.Expanded(child: etiqueta('CONCEPTO')),
                      etiqueta('IMPORTE'),
                    ]),
                    pw.SizedBox(height: 2),
                    for (final c in conceptos)
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(vertical: 2),
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide(color: _lineas, width: 0.4)),
                        ),
                        child: pw.Row(children: [
                          pw.Expanded(
                            child: pw.Text(c.concepto,
                                maxLines: 1, style: const pw.TextStyle(fontSize: 8.5)),
                          ),
                          pw.Text(formatoDinero(c.monto), style: const pw.TextStyle(fontSize: 8.5)),
                        ]),
                      ),
                  ],
                ),
              ),
              pw.SizedBox(width: 14),
              pw.Container(
                width: 120,
                padding: const pw.EdgeInsets.all(8),
                decoration: const pw.BoxDecoration(
                  color: _fondoTotales,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    etiqueta('TOTAL PAGADO'),
                    pw.Text(formatoDinero(datos.monto),
                        style: pw.TextStyle(
                            fontSize: 17, fontWeight: pw.FontWeight.bold, color: _verde)),
                    pw.SizedBox(height: 4),
                    etiqueta(datos.metodo.etiqueta +
                        (datos.folio == null ? '' : ' · Ref. ${datos.folio}')),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Situación de la cuenta
        pw.Row(
          children: [
            etiqueta('Pagado hasta  '),
            valor(datos.pagadoHasta == null ? '—' : datos.pagadoHasta!.nombre, tamano: 8),
            pw.SizedBox(width: 16),
            etiqueta('Saldo pendiente  '),
            valor(saldo, tamano: 8),
            pw.Spacer(),
            pw.Text('¡Gracias por su pago!',
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _azul)),
          ],
        ),
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 4),
          padding: const pw.EdgeInsets.only(top: 3),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: _verde, width: 0.8)),
          ),
          child: pw.Text(
            'Tel. ${DatosNegocio.telefono}  ·  ${DatosNegocio.correo}  ·  ${DatosNegocio.direccion}',
            style: const pw.TextStyle(fontSize: 6.5, color: _gris),
          ),
        ),
      ],
    ),
  );

  doc.addPage(pw.Page(
    theme: estilo.tema,
    pageFormat: formatoComprobante,
    build: (context) => pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _lineas, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Stack(
        fit: pw.StackFit.expand,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [talon, corte, cuerpo],
          ),
          if (datos.cancelado)
            pw.Center(
              child: pw.Transform.rotateBox(
                angle: 0.18,
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.red, width: 2.5),
                  ),
                  child: pw.Text('PAGO CANCELADO',
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
                ),
              ),
            ),
        ],
      ),
    ),
  ));
  return doc.save();
}
