import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dinero.dart';
import '../../data/db/database.dart';
import '../../data/repositories/clientes_repository.dart';
import '../../providers/providers.dart';
import '../../widgets/comunes.dart';
import '../../widgets/disposicion.dart';
import 'acciones_cliente.dart';
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
                return LayoutBuilder(builder: (context, limites) {
                  final modo = modoTabla(limites.maxWidth);
                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: lista.length + 1,
                    separatorBuilder: (_, i) =>
                        i == 0 && modo != ModoTabla.lista ? const SizedBox.shrink() : const Divider(height: 1),
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                              child: Text(
                                '${lista.length} cliente${lista.length == 1 ? '' : 's'}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            if (modo != ModoTabla.lista) _EncabezadoTabla(modo: modo),
                          ],
                        );
                      }
                      return _FilaCliente(lista[i - 1], modo: modo);
                    },
                  );
                });
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

/// Cómo se acomoda la lista según el ancho disponible.
enum ModoTabla {
  /// Celular: renglón con los botones de gestión (solo íconos) abajo.
  lista,

  /// Tabla con columnas; botones solo con ícono.
  tablaCompacta,

  /// Tabla con columnas; botones con ícono y texto.
  tabla,
}

ModoTabla modoTabla(double ancho) => ancho >= 1100
    ? ModoTabla.tabla
    : (ancho >= 760 ? ModoTabla.tablaCompacta : ModoTabla.lista);

const _anchoMensualidad = 130.0;
const _anchoEstado = 120.0;
double _anchoAcciones(ModoTabla modo) => modo == ModoTabla.tabla ? 400 : 150;

class _EncabezadoTabla extends StatelessWidget {
  const _EncabezadoTabla({required this.modo});

  final ModoTabla modo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final estilo = Theme.of(context)
        .textTheme
        .labelMedium
        ?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: scheme.outlineVariant),
          bottom: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 56),
          Expanded(child: Text('CLIENTE', style: estilo)),
          SizedBox(width: _anchoMensualidad, child: Text('MENSUALIDAD', style: estilo)),
          SizedBox(width: _anchoEstado, child: Text('ESTADO', style: estilo)),
          SizedBox(width: _anchoAcciones(modo), child: Text('ACCIONES', style: estilo)),
        ],
      ),
    );
  }
}

/// Renglón de la tabla de gestión: datos del cliente y botones visibles para
/// editar, suspender/reactivar y cancelar. Tocar el renglón abre la ficha.
class _FilaCliente extends StatelessWidget {
  const _FilaCliente(this.cliente, {required this.modo});

  final Cliente cliente;
  final ModoTabla modo;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final detalle = [
      if (cliente.zona != null) cliente.zona!,
      if (cliente.telefono != null) cliente.telefono!,
    ].join(' · ');
    final avatar = CircleAvatar(
      child: Text(cliente.nombre.isEmpty ? '?' : cliente.nombre[0].toUpperCase()),
    );
    final nombre = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(cliente.nombre, style: texto.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(
          detalle.isEmpty ? 'Corte día ${cliente.diaCorte}' : '$detalle · Corte día ${cliente.diaCorte}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: texto.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );

    if (modo == ModoTabla.lista) {
      return InkWell(
        onTap: () => abrirFichaCliente(context, cliente.id),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  avatar,
                  const SizedBox(width: 16),
                  Expanded(child: nombre),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(formatoDinero(cliente.precioMensual)),
                        const SizedBox(height: 4),
                        EstadoChip(cliente.estado),
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: BotonesCliente(cliente: cliente, compacto: true),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => abrirFichaCliente(context, cliente.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            avatar,
            const SizedBox(width: 16),
            Expanded(child: nombre),
            SizedBox(
              width: _anchoMensualidad,
              child: Text(formatoDinero(cliente.precioMensual), style: texto.bodyLarge),
            ),
            SizedBox(
              width: _anchoEstado,
              child: Align(alignment: Alignment.centerLeft, child: EstadoChip(cliente.estado)),
            ),
            SizedBox(
              width: _anchoAcciones(modo),
              child: BotonesCliente(cliente: cliente, compacto: modo != ModoTabla.tabla),
            ),
          ],
        ),
      ),
    );
  }
}
