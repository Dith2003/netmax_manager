import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dinero.dart';
import '../../data/db/database.dart';
import '../../data/repositories/clientes_repository.dart';
import '../../providers/providers.dart';
import '../../widgets/comunes.dart';
import '../../widgets/disposicion.dart';
import 'modales.dart';

/// Lista de clientes con búsqueda y filtro por estado.
class ClientesScreen extends ConsumerStatefulWidget {
  const ClientesScreen({super.key});

  @override
  ConsumerState<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends ConsumerState<ClientesScreen> {
  final _busquedaCtrl = TextEditingController();
  String _busqueda = '';

  /// Por defecto se muestran los activos.
  EstadoCliente? _estado = EstadoCliente.activo;

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtro = FiltroClientes(busqueda: _busqueda, estado: _estado);
    final clientes = ref.watch(clientesProvider(filtro));

    final escritorio = esEscritorio(context);

    return Scaffold(
      appBar: escritorio ? null : AppBar(title: const Text('Clientes')),
      floatingActionButton: escritorio
          ? null
          : FloatingActionButton.extended(
              onPressed: () => nuevoCliente(context),
              icon: const Icon(Icons.person_add),
              label: const Text('Nuevo cliente'),
            ),
      body: ContenidoCentrado(
        anchoMaximo: 1240,
        child: Column(
        children: [
          if (escritorio)
            EncabezadoSeccion(
              titulo: 'Clientes',
              descripcion: 'Busca, registra y consulta la información de tus clientes',
              icono: Icons.people,
              acciones: [
                FilledButton.icon(
                  onPressed: () => nuevoCliente(context),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Nuevo cliente'),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _busquedaCtrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar por nombre, teléfono, zona o dirección',
                suffixIcon: _busqueda.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpiar',
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _busquedaCtrl.clear();
                          setState(() => _busqueda = '');
                        },
                      ),
              ),
              onChanged: (v) => setState(() => _busqueda = v),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _filtroChip('Activos', EstadoCliente.activo),
                _filtroChip('Suspendidos', EstadoCliente.suspendido),
                _filtroChip('Cancelados', EstadoCliente.cancelado),
                _filtroChip('Todos', null),
              ],
            ),
          ),
          Expanded(
            child: clientes.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorVista(e),
              data: (lista) {
                if (lista.isEmpty) {
                  return Center(
                    child: Text(
                      _busqueda.isEmpty && _estado == EstadoCliente.activo
                          ? 'Aún no hay clientes.\nUsa "Nuevo cliente" para agregar el primero.'
                          : 'No se encontraron clientes.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: lista.length + 1,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                        child: Text(
                          '${lista.length} cliente${lista.length == 1 ? '' : 's'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    }
                    return _ClienteTile(lista[i - 1]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _filtroChip(String texto, EstadoCliente? estado) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(texto),
        selected: _estado == estado,
        onSelected: (_) => setState(() => _estado = estado),
      ),
    );
  }
}

class _ClienteTile extends StatelessWidget {
  const _ClienteTile(this.cliente);

  final Cliente cliente;

  @override
  Widget build(BuildContext context) {
    final detalle = [
      if (cliente.zona != null) cliente.zona!,
      if (cliente.telefono != null) cliente.telefono!,
    ].join(' · ');

    return ListTile(
      leading: CircleAvatar(
        child: Text(cliente.nombre.isEmpty ? '?' : cliente.nombre[0].toUpperCase()),
      ),
      title: Text(cliente.nombre),
      subtitle: Text(
        detalle.isEmpty ? 'Corte día ${cliente.diaCorte}' : '$detalle · Corte día ${cliente.diaCorte}',
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(formatoDinero(cliente.precioMensual)),
          const SizedBox(height: 4),
          EstadoChip(cliente.estado),
        ],
      ),
      onTap: () => abrirFichaCliente(context, cliente.id),
    );
  }
}
