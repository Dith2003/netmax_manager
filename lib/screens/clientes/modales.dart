/// Ventanas modales del cliente: alta, edición y ficha.
///
/// En pantallas anchas (Windows) se abren como un diálogo centrado; en el celular,
/// como un diálogo a pantalla completa. Cada modal tiene su propia navegación
/// interna: desde la ficha se abren el estado de cuenta, el registro de pago y los
/// comprobantes sin salir del modal.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../pagos/comprobante_screen.dart';
import '../pagos/registrar_pago_screen.dart';
import 'cliente_detalle_screen.dart';
import 'cliente_form_screen.dart';

/// Ancho a partir del cual el modal se muestra como diálogo flotante.
const anchoModalFlotante = 720.0;

/// Abre [contenido] en un modal con navegación propia y devuelve el valor con
/// que se cierre (`cerrarModal(context, valor)`).
Future<T?> mostrarModal<T>(BuildContext context, WidgetBuilder contenido) {
  final tamano = MediaQuery.sizeOf(context);
  final flotante = tamano.width >= anchoModalFlotante;

  return showDialog<T>(
    context: context,
    barrierDismissible: false,
    builder: (contextoDialogo) {
      // Navegación y mensajes propios del modal.
      final cuerpo = ScaffoldMessenger(
        child: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute<void>(builder: contenido),
        ),
      );
      if (!flotante) return Dialog.fullscreen(child: cuerpo);
      return Dialog(
        insetPadding: const EdgeInsets.all(24),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: math.min(tamano.width * 0.92, 920),
          height: math.min(tamano.height * 0.92, 940),
          child: cuerpo,
        ),
      );
    },
  );
}

/// Cierra el modal que contiene a [context] (desde cualquier pantalla interna).
void cerrarModal<T>(BuildContext context, [T? valor]) {
  Navigator.of(context, rootNavigator: true).pop(valor);
}

/// Muestra un mensaje en la pantalla de abajo (sigue visible al cerrar el modal).
void mensajeFueraDelModal(BuildContext context, String texto) {
  final raiz = Navigator.of(context, rootNavigator: true).context;
  ScaffoldMessenger.of(raiz)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texto)));
}

/// Abre la ficha del cliente en un modal.
Future<void> abrirFichaCliente(BuildContext context, int clienteId) {
  return mostrarModal<void>(
    context,
    (_) => ClienteDetalleScreen(clienteId: clienteId, enModal: true),
  );
}

/// Abre el formulario de cliente en un modal (nuevo si [clienteId] es null).
/// Devuelve el id del cliente guardado, o null si se canceló.
Future<int?> abrirFormularioCliente(BuildContext context, {int? clienteId}) {
  return mostrarModal<int>(
    context,
    (_) => ClienteFormScreen(clienteId: clienteId, enModal: true),
  );
}

/// Alta de cliente: formulario en modal y, al guardar, su ficha.
Future<void> nuevoCliente(BuildContext context) async {
  final id = await abrirFormularioCliente(context);
  if (id != null && context.mounted) await abrirFichaCliente(context, id);
}

/// Registra un pago del cliente y, si se guardó, muestra su comprobante.
/// Se abre encima de la pantalla actual (dentro del modal si se llama desde uno).
Future<void> registrarPagoConComprobante(BuildContext context, int clienteId) async {
  final pagoId = await Navigator.of(context).push<int>(MaterialPageRoute(
    builder: (_) => RegistrarPagoScreen(clienteId: clienteId),
  ));
  if (pagoId != null && context.mounted) await abrirComprobante(context, pagoId);
}
