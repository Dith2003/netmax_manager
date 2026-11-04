import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/marca.dart';
import '../../widgets/disposicion.dart';

/// Los reportes disponibles.
enum TipoReporte {
  ingresos(
    titulo: 'Ingresos por mes',
    descripcion: 'Lo cobrado cada mes del año, por método de pago',
    icono: Icons.bar_chart,
    detalles: ['Por año', 'Por método de pago', 'Totales'],
  ),
  pagos(
    titulo: 'Pagos recibidos',
    descripcion: 'Detalle de los pagos de un mes: cliente, método y qué cubrió',
    icono: Icons.receipt_long,
    detalles: ['Por mes', 'Folio', 'Meses y cargos cubiertos'],
  ),
  adeudos(
    titulo: 'Clientes con adeudo',
    descripcion: 'Lista para la ruta de cobro, del que más debe al que menos',
    icono: Icons.money_off,
    detalles: ['Al día de hoy', 'Zona y teléfono', 'Desde cuándo debe'],
  ),
  clientes(
    titulo: 'Clientes',
    descripcion: 'Todos los clientes con precio, día de corte, pagado hasta y adeudo',
    icono: Icons.people,
    detalles: ['Activos, suspendidos y cancelados', 'Pagado hasta'],
  );

  const TipoReporte({
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.detalles,
  });

  final String titulo;
  final String descripcion;
  final IconData icono;

  /// Qué incluye el reporte (se muestra como etiquetas).
  final List<String> detalles;
}

/// Un acceso de la pantalla de reportes.
class _Acceso {
  const _Acceso({
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.detalles,
    required this.ruta,
  });

  _Acceso.reporte(TipoReporte t)
      : titulo = t.titulo,
        descripcion = t.descripcion,
        icono = t.icono,
        detalles = t.detalles,
        ruta = '/reportes/${t.name}';

  final String titulo;
  final String descripcion;
  final IconData icono;
  final List<String> detalles;
  final String ruta;
}

/// Reportes en PDF agrupados por tema, en tarjetas. Cada uno se abre con vista
/// previa para imprimir o compartir.
class ReportesScreen extends StatelessWidget {
  const ReportesScreen({super.key});

  static final _cobranza = [
    _Acceso.reporte(TipoReporte.ingresos),
    _Acceso.reporte(TipoReporte.pagos),
    const _Acceso(
      titulo: 'Comprobantes de pago',
      descripcion: 'Descarga o comparte el comprobante de cada pago del mes',
      icono: Icons.receipt,
      detalles: ['Formato tipo cheque', '1/3 de hoja carta'],
      ruta: '/reportes/comprobantes',
    ),
  ];

  static final _clientes = [
    _Acceso.reporte(TipoReporte.adeudos),
    _Acceso.reporte(TipoReporte.clientes),
  ];

  @override
  Widget build(BuildContext context) {
    final escritorio = esEscritorio(context);
    return Scaffold(
      appBar: escritorio ? null : AppBar(title: const Text('Reportes')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          ContenidoCentrado(
            anchoMaximo: 1240,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (escritorio)
                  const EncabezadoSeccion(
                    titulo: 'Reportes',
                    descripcion: 'Genera documentos en PDF para imprimir o compartir',
                    icono: Icons.description,
                  ),
                _Grupo(
                  titulo: 'Cobranza',
                  icono: Icons.payments_outlined,
                  color: ColoresNetMax.verde,
                  accesos: _cobranza,
                ),
                _Grupo(
                  titulo: 'Clientes',
                  icono: Icons.people_outline,
                  color: ColoresNetMax.azul,
                  accesos: _clientes,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Card(
                    margin: EdgeInsets.zero,
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    child: const ListTile(
                      leading: Icon(Icons.lightbulb_outline),
                      title: Text('Imprimir o compartir'),
                      subtitle: Text(
                        'Desde la vista previa puedes imprimir el PDF o compartirlo por '
                        'WhatsApp, correo o guardarlo en el equipo.',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Grupo extends StatelessWidget {
  const _Grupo({
    required this.titulo,
    required this.icono,
    required this.color,
    required this.accesos,
  });

  final String titulo;
  final IconData icono;
  final Color color;
  final List<_Acceso> accesos;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 20, color: color),
              const SizedBox(width: 8),
              Text(titulo, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, limites) {
            const espacio = 16.0;
            final columnas = limites.maxWidth >= 1000 ? 3 : (limites.maxWidth >= 620 ? 2 : 1);
            final ancho = (limites.maxWidth - espacio * (columnas - 1)) / columnas;
            return Wrap(
              spacing: espacio,
              runSpacing: espacio,
              children: [
                for (final a in accesos)
                  SizedBox(width: ancho, child: _TarjetaReporte(acceso: a, color: color)),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _TarjetaReporte extends StatelessWidget {
  const _TarjetaReporte({required this.acceso, required this.color});

  final _Acceso acceso;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(acceso.ruta),
        hoverColor: color.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(acceso.icono, color: color),
                  ),
                  const Spacer(),
                  Icon(Icons.picture_as_pdf_outlined, size: 18, color: scheme.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 14),
              Text(acceso.titulo, style: texto.titleMedium),
              const SizedBox(height: 4),
              SizedBox(
                height: 40,
                child: Text(acceso.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: texto.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final d in acceso.detalles)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(d, style: texto.labelSmall),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Abrir',
                      style: texto.labelLarge?.copyWith(color: color, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
