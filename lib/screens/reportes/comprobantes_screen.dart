import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dinero.dart';
import '../../core/etiquetas.dart';
import '../../core/fechas.dart';
import '../../core/mes.dart';
import '../../domain/reportes.dart';
import '../../providers/providers.dart';
import '../../widgets/comunes.dart';
import '../pagos/comprobante_screen.dart';

/// Pagos de un mes con acceso al comprobante de cada uno.
class ComprobantesScreen extends ConsumerStatefulWidget {
  const ComprobantesScreen({super.key});

  @override
  ConsumerState<ComprobantesScreen> createState() => _ComprobantesScreenState();
}

class _ComprobantesScreenState extends ConsumerState<ComprobantesScreen> {
  Mes _mes = Mes.deFecha(DateTime.now());
  late Future<List<FilaPago>> _pagos = _cargar();

  Future<List<FilaPago>> _cargar() async {
    final lista = await ref.read(reportesRepositoryProvider).pagosEntre(
          DateTime(_mes.anio, _mes.mes, 1),
          DateTime(_mes.anio, _mes.mes + 1, 0),
        );
    return lista.reversed.toList(); // el más reciente primero
  }

  @override
  Widget build(BuildContext context) {
    final meses = <Mes>[];
    var m = Mes.deFecha(DateTime.now());
    for (var i = 0; i < 24; i++, m = m.anterior()) {
      meses.add(m);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Comprobantes de pago')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: DropdownButtonFormField<Mes>(
              initialValue: _mes,
              decoration: const InputDecoration(labelText: 'Mes'),
              items: [for (final m in meses) DropdownMenuItem(value: m, child: Text(m.nombre))],
              onChanged: (m) {
                if (m == null) return;
                setState(() {
                  _mes = m;
                  _pagos = _cargar();
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<FilaPago>>(
              future: _pagos,
              builder: (context, snap) {
                if (snap.hasError) return ErrorVista(snap.error!);
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final pagos = snap.data!;
                if (pagos.isEmpty) {
                  return const Center(child: Text('No hay pagos en este mes.'));
                }
                return ListView.separated(
                  itemCount: pagos.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final p = pagos[i];
                    return ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text(p.cliente),
                      subtitle: Text([
                        formatoFechaCorta(p.fecha),
                        p.metodo.etiqueta,
                        if (p.cubre.isNotEmpty) p.cubre,
                      ].join(' · ')),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(formatoDinero(p.monto)),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Ver comprobante',
                            icon: const Icon(Icons.download),
                            onPressed: p.id == null ? null : () => abrirComprobante(context, p.id!),
                          ),
                        ],
                      ),
                      onTap: p.id == null ? null : () => abrirComprobante(context, p.id!),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
