/// Piezas de diseño que cambian entre escritorio (Windows) y celular.
library;

import 'package:flutter/material.dart';

/// Ancho a partir del cual se usa el diseño de escritorio (panel lateral,
/// encabezados de sección, formularios en columnas).
const anchoEscritorio = 900.0;

/// True si la ventana es lo bastante ancha para el diseño de escritorio.
bool esEscritorio(BuildContext context) => MediaQuery.sizeOf(context).width >= anchoEscritorio;

/// Ancho máximo de los formularios: no ocupan toda la pantalla.
const anchoFormulario = 680.0;

/// Centra [child] y limita su ancho a [anchoMaximo].
class ContenidoCentrado extends StatelessWidget {
  const ContenidoCentrado({super.key, this.anchoMaximo = anchoFormulario, required this.child});

  final double anchoMaximo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // heightFactor: 1 -> solo ocupa el alto del contenido (sirve también en
    // barras inferiores, donde un Align normal llenaría toda la pantalla).
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: anchoMaximo),
        child: child,
      ),
    );
  }
}

/// Encabezado de una sección en escritorio: título grande, descripción y acciones.
class EncabezadoSeccion extends StatelessWidget {
  const EncabezadoSeccion({
    super.key,
    required this.titulo,
    this.descripcion,
    this.icono,
    this.acciones = const [],
  });

  final String titulo;
  final String? descripcion;
  final IconData? icono;
  final List<Widget> acciones;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      // Ancho completo: así el título queda a la izquierda y las acciones a la derecha.
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icono != null) ...[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icono, color: scheme.secondary, size: 26),
                ),
                const SizedBox(width: 14),
              ],
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo,
                        style: texto.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                    if (descripcion != null)
                      Text(descripcion!,
                          style: texto.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          if (acciones.isNotEmpty)
            Wrap(spacing: 12, runSpacing: 8, children: acciones),
        ],
        ),
      ),
    );
  }
}

/// Tarjeta de sección de un formulario: título con ícono y campos dentro.
class SeccionFormulario extends StatelessWidget {
  const SeccionFormulario({
    super.key,
    required this.titulo,
    required this.icono,
    required this.children,
  });

  final String titulo;
  final IconData icono;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icono, size: 20, color: scheme.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(titulo, style: Theme.of(context).textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ..._conEspacios(children),
          ],
        ),
      ),
    );
  }

  static List<Widget> _conEspacios(List<Widget> hijos) => [
        for (var i = 0; i < hijos.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          hijos[i],
        ],
      ];
}

/// Dos campos lado a lado si hay espacio (≥ 520 px); uno debajo del otro si no.
class FilaCampos extends StatelessWidget {
  const FilaCampos({super.key, required this.izquierda, required this.derecha});

  final Widget izquierda;
  final Widget derecha;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth < 520) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [izquierda, const SizedBox(height: 14), derecha],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: izquierda),
          const SizedBox(width: 12),
          Expanded(child: derecha),
        ],
      );
    });
  }
}
