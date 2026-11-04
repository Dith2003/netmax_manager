/// Panel lateral de navegación para escritorio (Windows).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/marca.dart';
import '../providers/sesion.dart';
import '../providers/zoom.dart';
import '../screens/sesion/acceso_screen.dart' show etiquetaRol;

/// Una sección del panel.
class DestinoPanel {
  const DestinoPanel({
    required this.ruta,
    required this.etiqueta,
    required this.icono,
    required this.iconoSeleccionado,
  });

  final String ruta;
  final String etiqueta;
  final IconData icono;
  final IconData iconoSeleccionado;
}

/// Panel azul con la marca arriba, las secciones y, abajo, respaldos y zoom.
/// [extendido] muestra los nombres al lado de los íconos (ventanas anchas);
/// si no, el panel es angosto con el nombre debajo del ícono.
class PanelLateral extends ConsumerWidget {
  const PanelLateral({
    super.key,
    required this.destinos,
    required this.seleccionado,
    required this.onSeleccionar,
    required this.extendido,
    this.destinosInferiores = const [],
    this.inferiorSeleccionado = -1,
    this.onInferior,
  });

  final List<DestinoPanel> destinos;
  final int seleccionado;
  final ValueChanged<int> onSeleccionar;
  final bool extendido;

  /// Destinos secundarios al final (Respaldos, Configuración).
  final List<DestinoPanel> destinosInferiores;

  /// Índice del destino inferior elegido (-1 = ninguno).
  final int inferiorSeleccionado;
  final ValueChanged<int>? onInferior;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zoom = ref.watch(zoomProvider);
    final control = ref.read(zoomProvider.notifier);

    return Container(
      width: extendido ? 248 : 96,
      color: ColoresNetMax.azul,
      child: SafeArea(
        // Si la ventana es baja, el panel se desplaza en vez de desbordarse.
        child: LayoutBuilder(
          builder: (context, limites) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: limites.maxHeight),
              child: IntrinsicHeight(
                child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(extendido ? 20 : 12, 22, 12, 26),
              child: extendido
                  ? const FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: MarcaNetMax(alto: 38, sobreOscuro: true, conLema: true),
                    )
                  : Image.asset(ImagenesMarca.logoClaro, height: 40),
            ),
            for (final (i, d) in destinos.indexed)
              _BotonPanel(
                destino: d,
                seleccionado: i == seleccionado,
                extendido: extendido,
                onTap: () => onSeleccionar(i),
              ),
            const Spacer(),
            for (final (i, d) in destinosInferiores.indexed)
              _BotonPanel(
                destino: d,
                seleccionado: i == inferiorSeleccionado,
                extendido: extendido,
                onTap: () => onInferior?.call(i),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Divider(color: ColoresNetMax.crema.withValues(alpha: 0.15), height: 1),
            ),
            _ControlZoom(
              zoom: zoom,
              extendido: extendido,
              onAlejar: control.alejar,
              onAcercar: control.acercar,
              onRestablecer: control.restablecer,
            ),
            _UsuarioSesion(extendido: extendido),
            const SizedBox(height: 12),
          ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BotonPanel extends StatelessWidget {
  const _BotonPanel({
    required this.destino,
    required this.seleccionado,
    required this.extendido,
    required this.onTap,
  });

  final DestinoPanel destino;
  final bool seleccionado;
  final bool extendido;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = seleccionado
        ? ColoresNetMax.verdeClaro
        : ColoresNetMax.crema.withValues(alpha: 0.82);
    final icono = Icon(seleccionado ? destino.iconoSeleccionado : destino.icono, color: color);
    final estilo = TextStyle(
      fontFamily: 'Outfit',
      color: color,
      fontSize: extendido ? 15.5 : 12,
      fontWeight: seleccionado ? FontWeight.w600 : FontWeight.w400,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: extendido ? 12 : 8, vertical: 3),
      child: Semantics(
        selected: seleccionado,
        button: true,
        child: Material(
          color: seleccionado
              ? ColoresNetMax.verdeClaro.withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            hoverColor: ColoresNetMax.crema.withValues(alpha: 0.08),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: extendido ? 14 : 4,
                vertical: extendido ? 12 : 10,
              ),
              child: extendido
                  ? Row(
                      children: [
                        icono,
                        const SizedBox(width: 14),
                        Expanded(child: Text(destino.etiqueta, style: estilo)),
                        if (seleccionado)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: ColoresNetMax.verdeClaro,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    )
                  : Column(
                      children: [
                        icono,
                        const SizedBox(height: 4),
                        Text(destino.etiqueta,
                            style: estilo, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// − 100 % + : zoom de la interfaz. Tocar el porcentaje lo regresa a 100 %.
class _ControlZoom extends StatelessWidget {
  const _ControlZoom({
    required this.zoom,
    required this.extendido,
    required this.onAlejar,
    required this.onAcercar,
    required this.onRestablecer,
  });

  final double zoom;
  final bool extendido;
  final VoidCallback onAlejar;
  final VoidCallback onAcercar;
  final VoidCallback onRestablecer;

  @override
  Widget build(BuildContext context) {
    const crema = ColoresNetMax.crema;
    final botonEstilo = IconButton.styleFrom(
      foregroundColor: crema,
      backgroundColor: crema.withValues(alpha: 0.08),
      minimumSize: const Size(32, 32),
      padding: EdgeInsets.zero,
    );
    final porcentaje = Tooltip(
      message: 'Restablecer al 100 % (Ctrl 0)',
      child: TextButton(
        onPressed: onRestablecer,
        style: TextButton.styleFrom(
          foregroundColor: crema,
          minimumSize: const Size(52, 32),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        child: Text(textoZoom(zoom),
            style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600)),
      ),
    );
    final alejar = IconButton(
      tooltip: 'Alejar (Ctrl −)',
      style: botonEstilo,
      iconSize: 18,
      onPressed: zoom <= nivelesZoom.first ? null : onAlejar,
      icon: const Icon(Icons.remove),
    );
    final acercar = IconButton(
      tooltip: 'Acercar (Ctrl +)',
      style: botonEstilo,
      iconSize: 18,
      onPressed: zoom >= nivelesZoom.last ? null : onAcercar,
      icon: const Icon(Icons.add),
    );

    if (!extendido) {
      return Column(children: [acercar, porcentaje, alejar]);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.zoom_in, size: 18, color: crema.withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Zoom',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: 'Outfit', color: crema.withValues(alpha: 0.8))),
          ),
          alejar,
          porcentaje,
          acercar,
        ],
      ),
    );
  }
}

/// Usuario de la sesión y botón para cerrarla.
class _UsuarioSesion extends ConsumerWidget {
  const _UsuarioSesion({required this.extendido});

  final bool extendido;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(sesionProvider);
    if (usuario == null) return const SizedBox.shrink();
    const crema = ColoresNetMax.crema;
    final salir = IconButton(
      tooltip: 'Cerrar sesión',
      color: crema,
      icon: const Icon(Icons.logout),
      onPressed: () => ref.read(sesionProvider.notifier).cerrar(),
    );
    final avatar = CircleAvatar(
      radius: 16,
      backgroundColor: ColoresNetMax.verdeClaro.withValues(alpha: 0.2),
      foregroundColor: ColoresNetMax.verdeClaro,
      child: Text(usuario.nombre.isEmpty ? '?' : usuario.nombre[0].toUpperCase(),
          style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600)),
    );
    if (!extendido) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(children: [Tooltip(message: usuario.nombre, child: avatar), salir]),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
      child: Row(
        children: [
          avatar,
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(usuario.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'Outfit', color: crema, fontWeight: FontWeight.w600)),
                Text(etiquetaRol(usuario.rol),
                    style: TextStyle(
                        fontFamily: 'Outfit', fontSize: 12, color: crema.withValues(alpha: 0.7))),
              ],
            ),
          ),
          salir,
        ],
      ),
    );
  }
}
