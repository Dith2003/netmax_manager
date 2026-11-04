import 'dart:io';

import 'package:file_selector/file_selector.dart' show XTypeGroup, getSaveLocation, openFile;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' show ShareParams, SharePlus, XFile;

import '../../core/fechas.dart';
import '../../data/respaldos/respaldo_service.dart';
import '../../providers/providers.dart';
import '../../widgets/comunes.dart';

const _tipoRespaldo = XTypeGroup(label: 'Respaldo de NetMAX', extensions: ['db']);

/// Crear y restaurar respaldos de toda la información de la app.
class RespaldosScreen extends ConsumerStatefulWidget {
  const RespaldosScreen({super.key});

  @override
  ConsumerState<RespaldosScreen> createState() => _RespaldosScreenState();
}

class _RespaldosScreenState extends ConsumerState<RespaldosScreen> {
  bool _trabajando = false;

  Future<void> _conIndicador(Future<void> Function() tarea) async {
    setState(() => _trabajando = true);
    try {
      await tarea();
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  // ----- Crear -----

  Future<void> _crearRespaldo() => _conIndicador(() async {
        final nombre = RespaldoService.nombreSugerido(DateTime.now());
        final temporal = '${(await getTemporaryDirectory()).path}${Platform.pathSeparator}$nombre';
        final servicio = ref.read(respaldoServiceProvider);

        try {
          if (Platform.isAndroid || Platform.isIOS) {
            // En el celular: se comparte el archivo (Drive, WhatsApp, correo…).
            await servicio.crearRespaldo(temporal);
            await SharePlus.instance.share(ShareParams(
              files: [XFile(temporal, mimeType: 'application/octet-stream')],
              fileNameOverrides: [nombre],
              subject: 'Respaldo NetMAX',
              text: 'Respaldo de NetMAX del ${formatoFecha(DateTime.now())}',
            ));
            if (mounted) mostrarMensaje(context, 'Respaldo creado: $nombre');
          } else {
            // En la computadora: se elige dónde guardarlo.
            final ubicacion = await getSaveLocation(
              suggestedName: nombre,
              acceptedTypeGroups: const [_tipoRespaldo],
              confirmButtonText: 'Guardar',
            );
            if (ubicacion == null) return;
            var ruta = ubicacion.path;
            if (!ruta.toLowerCase().endsWith('.db')) ruta = '$ruta.db';
            await servicio.crearRespaldo(ruta);
            if (mounted) mostrarMensaje(context, 'Respaldo guardado en $ruta');
          }
        } catch (e) {
          if (mounted) mostrarMensaje(context, 'No se pudo crear el respaldo: $e');
        }
      });

  // ----- Restaurar -----

  Future<void> _restaurar() async {
    // En Android no se filtra por extensión: los .db no tienen un tipo reconocido.
    final archivo = await openFile(
      acceptedTypeGroups: Platform.isAndroid ? const [] : const [_tipoRespaldo],
      confirmButtonText: 'Abrir',
    );
    if (archivo == null || !mounted) return;

    await _conIndicador(() async {
      // Se copia a la carpeta temporal para trabajar con un archivo local.
      final temporal =
          '${(await getTemporaryDirectory()).path}${Platform.pathSeparator}restaurar_netmax.db';
      await File(temporal).writeAsBytes(await archivo.readAsBytes(), flush: true);

      final InfoRespaldo info;
      try {
        info = RespaldoService.validar(temporal,
            versionApp: ref.read(databaseProvider).schemaVersion);
      } on RespaldoNoValido catch (e) {
        if (mounted) mostrarMensaje(context, e.mensaje);
        return;
      }
      if (!mounted) return;

      final ok = await confirmar(
        context,
        titulo: 'Restaurar respaldo',
        mensaje: 'Archivo: ${archivo.name}\n'
            '${info.clientes} clientes · ${info.pagos} pagos'
            '${info.ultimoPago == null ? '' : '\nÚltimo pago: ${formatoFecha(info.ultimoPago!)}'}\n\n'
            'Se reemplazará TODA la información actual de la app por la del respaldo. '
            'Antes se guarda una copia de seguridad de lo actual.',
        textoSi: 'Restaurar',
      );
      if (!ok) return;

      try {
        // Reinicia la app con la base restaurada (esta pantalla se cierra).
        await ref.read(restaurarRespaldoProvider)(temporal);
      } catch (e) {
        if (mounted) mostrarMensaje(context, 'No se pudo restaurar: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ultimo = ref.watch(ultimoRespaldoProvider);
    final scheme = Theme.of(context).colorScheme;

    final estado = ultimo.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => ErrorVista(e),
      data: (fecha) {
        final dias = diasDesdeRespaldo(fecha, DateTime.now());
        final atrasado = necesitaRespaldo(fecha, DateTime.now());
        return ListTile(
          leading: Icon(
            atrasado ? Icons.warning_amber : Icons.verified,
            color: atrasado ? scheme.error : Colors.green,
          ),
          title: Text(fecha == null
              ? 'Nunca has hecho un respaldo'
              : 'Último respaldo: ${formatoFechaCorta(fecha)}'),
          subtitle: Text(switch (dias) {
            null => 'Te recomendamos hacer uno ahora.',
            0 => 'Hoy',
            1 => 'Hace 1 día',
            _ => 'Hace $dias días${atrasado ? '. Te recomendamos hacer uno nuevo.' : ''}',
          }),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Respaldos')),
      body: AbsorbPointer(
        absorbing: _trabajando,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_trabajando) const LinearProgressIndicator(),
            Card(margin: EdgeInsets.zero, child: estado),
            const SizedBox(height: 16),
            const Text(
              'Un respaldo es una copia de toda la información: clientes, pagos, meses, '
              'cargos, instalaciones y equipos. Guárdalo fuera del equipo (Google Drive, '
              'correo, una memoria USB) para no perder nada si el equipo se daña o se cambia.',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _crearRespaldo,
              icon: const Icon(Icons.backup),
              label: Text(Platform.isAndroid ? 'Crear y compartir respaldo' : 'Crear respaldo'),
            ),
            const SizedBox(height: 32),
            Text('Restaurar', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              'Reemplaza la información actual por la de un archivo de respaldo (.db). '
              'Úsalo al cambiar de equipo o para recuperar información. Antes de reemplazar se '
              'guarda una copia de seguridad de lo actual.',
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _restaurar,
              icon: const Icon(Icons.restore),
              label: const Text('Restaurar desde un respaldo'),
            ),
          ],
        ),
      ),
    );
  }
}
