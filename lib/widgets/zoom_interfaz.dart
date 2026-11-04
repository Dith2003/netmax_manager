/// Zoom de toda la interfaz y sus atajos de teclado.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/zoom.dart';

/// Aplica el zoom a toda la interfaz (pantallas, diálogos y menús) y atiende
/// los atajos Ctrl + (acercar), Ctrl − (alejar) y Ctrl 0 (100 %).
///
/// La app se dibuja con el tamaño "virtual" (tamaño real ÷ zoom) y un
/// [FittedBox] la escala al tamaño real. A diferencia de un `Transform`, el
/// FittedBox también traduce los toques y clics: con zoom menor a 100 % los
/// botones de la derecha y de abajo siguen respondiendo.
class ZoomInterfaz extends ConsumerWidget {
  const ZoomInterfaz({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zoom = ref.watch(zoomProvider);
    final control = ref.read(zoomProvider.notifier);

    // Siempre la misma estructura (aunque el zoom sea 100 %) para no perder
    // la navegación al cambiarlo.
    final mq = MediaQuery.of(context);
    final tamano = mq.size / zoom;
    final contenido = MediaQuery(
      data: mq.copyWith(
        size: tamano,
        padding: mq.padding / zoom,
        viewPadding: mq.viewPadding / zoom,
        viewInsets: mq.viewInsets / zoom,
      ),
      child: FittedBox(
        fit: BoxFit.fill,
        alignment: Alignment.topLeft,
        child: SizedBox.fromSize(size: tamano, child: child),
      ),
    );

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.equal, control: true): control.acercar,
        const SingleActivator(LogicalKeyboardKey.add, control: true): control.acercar,
        const SingleActivator(LogicalKeyboardKey.numpadAdd, control: true): control.acercar,
        const SingleActivator(LogicalKeyboardKey.minus, control: true): control.alejar,
        const SingleActivator(LogicalKeyboardKey.numpadSubtract, control: true): control.alejar,
        const SingleActivator(LogicalKeyboardKey.digit0, control: true): control.restablecer,
        const SingleActivator(LogicalKeyboardKey.numpad0, control: true): control.restablecer,
      },
      child: Focus(autofocus: true, child: contenido),
    );
  }
}
