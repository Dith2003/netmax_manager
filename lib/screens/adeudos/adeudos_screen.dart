import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/dinero.dart';
import '../../core/fechas.dart';
import '../../data/db/enums.dart';
import '../../providers/providers.dart';
import '../../widgets/comunes.dart';

/// Clientes con meses vencidos sin pagar, del que más debe al que menos.
class AdeudosScreen extends ConsumerStatefulWidget {
  const AdeudosScreen({super.key});

  @override
  ConsumerState<AdeudosScreen> createState() => _AdeudosScreenState();
}

class _AdeudosScreenState extends ConsumerState<AdeudosScreen> {
  @override
  void initState() {
    super.initState();
    // Por si la app lleva días abierta: genera los meses que ya correspondan.
    Future.microtask(() async {
      await ref.read(vencimientosRepositoryProvider).generarTodos(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final adeudos = ref.watch(adeudosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Adeudos')),
      body: adeudos.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorVista(e),
        data: (lista) {
          if (lista.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Ningún cliente tiene meses vencidos. 🎉',
                    textAlign: TextAlign.center),
              ),
            );
          }
          final total = lista.fold<int>(0, (s, a) => s + a.adeudo.total);
          return ListView.separated(
            itemCount: lista.length + 1,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              if (i == 0) {
                return ListTile(
                  title: Text(
                    'Total por cobrar: ${formatoDinero(total)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                      '${lista.length} cliente${lista.length == 1 ? '' : 's'} con adeudo'),
                );
              }
              final a = lista[i - 1];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  child: Text('${a.adeudo.meses}'),
                ),
                title: Text(a.nombre),
                subtitle: Text([
                  '${a.adeudo.meses} ${a.adeudo.meses == 1 ? 'mes' : 'meses'}'
                      ' desde ${formatoFechaCorta(a.adeudo.vencidoDesde!)}',
                  if (a.zona != null) a.zona!,
                  if (a.telefono != null) a.telefono!,
                ].join(' · ')),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatoDinero(a.adeudo.total),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (a.estado != EstadoCliente.activo) ...[
                      const SizedBox(height: 4),
                      EstadoChip(a.estado),
                    ],
                  ],
                ),
                onTap: () => context.push('/clientes/${a.clienteId}'),
              );
            },
          );
        },
      ),
    );
  }
}
