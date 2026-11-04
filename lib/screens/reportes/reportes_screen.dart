import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Los reportes disponibles.
enum TipoReporte {
  ingresos(
    titulo: 'Ingresos por mes',
    descripcion: 'Lo cobrado cada mes del año, por método de pago',
    icono: Icons.bar_chart,
  ),
  pagos(
    titulo: 'Pagos recibidos',
    descripcion: 'Detalle de los pagos de un mes: cliente, método y qué cubrió',
    icono: Icons.receipt_long,
  ),
  adeudos(
    titulo: 'Clientes con adeudo',
    descripcion: 'Lista para la ruta de cobro, del que más debe al que menos',
    icono: Icons.money_off,
  ),
  clientes(
    titulo: 'Clientes',
    descripcion: 'Todos los clientes con precio, día de corte, pagado hasta y adeudo',
    icono: Icons.people,
  );

  const TipoReporte({required this.titulo, required this.descripcion, required this.icono});

  final String titulo;
  final String descripcion;
  final IconData icono;
}

/// Lista de reportes. Cada uno se abre con vista previa para imprimir o compartir.
class ReportesScreen extends StatelessWidget {
  const ReportesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: ListView(
        children: [
          for (final t in TipoReporte.values)
            ListTile(
              leading: Icon(t.icono),
              title: Text(t.titulo),
              subtitle: Text(t.descripcion),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/reportes/${t.name}'),
            ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Los reportes se generan en PDF. Desde la vista previa puedes imprimirlos '
              'o compartirlos (WhatsApp, correo, guardar en el equipo).',
            ),
          ),
        ],
      ),
    );
  }
}
