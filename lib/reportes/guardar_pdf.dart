/// Botón "Guardar PDF" para la vista previa en la computadora.
///
/// En Windows el botón "compartir" de la vista previa solo abre el PDF desde
/// una carpeta temporal; para descargarlo se necesita elegir dónde guardarlo.
library;

import 'dart:io';

import 'package:file_selector/file_selector.dart' show XTypeGroup, getSaveLocation;
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';


const _tipoPdf = XTypeGroup(label: 'PDF', extensions: ['pdf']);

/// True en Windows, macOS y Linux (en el celular se usa "compartir").
bool get esComputadora => Platform.isWindows || Platform.isMacOS || Platform.isLinux;

/// Acciones extra de la vista previa: "Guardar PDF" en la computadora.
List<Widget> accionesPdf(String nombreArchivo) => [
      if (esComputadora)
        PdfPreviewAction(
          icon: const Tooltip(message: 'Guardar PDF en el equipo', child: Icon(Icons.save_alt)),
          onPressed: (context, build, formato) =>
              guardarPdf(context, nombreArchivo, () async => build(formato)),
        ),
    ];

/// Pide la ubicación y guarda el PDF. Avisa el resultado con un mensaje.
Future<void> guardarPdf(
  BuildContext context,
  String nombreArchivo,
  Future<List<int>> Function() generar,
) async {
  final mensajero = ScaffoldMessenger.maybeOf(context);
  try {
    final ubicacion = await getSaveLocation(
      suggestedName: nombreArchivo,
      acceptedTypeGroups: const [_tipoPdf],
      confirmButtonText: 'Guardar',
    );
    if (ubicacion == null) return;
    var ruta = ubicacion.path;
    if (!ruta.toLowerCase().endsWith('.pdf')) ruta = '$ruta.pdf';
    await File(ruta).writeAsBytes(await generar(), flush: true);
    _avisar(mensajero, 'PDF guardado en $ruta');
  } catch (e) {
    _avisar(mensajero, 'No se pudo guardar el PDF: $e');
  }
}

void _avisar(ScaffoldMessengerState? mensajero, String texto) {
  if (mensajero == null) return;
  mensajero
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texto)));
}

