import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/dinero.dart';
import '../../core/etiquetas.dart';
import '../../core/fechas.dart';
import '../../core/mes.dart';
import '../../data/db/database.dart';
import '../../data/repositories/clientes_repository.dart';
import '../../domain/clientes.dart';
import '../../domain/vencimientos.dart';
import '../../providers/providers.dart';
import '../../widgets/comunes.dart';

/// Alta (clienteId == null) o edición de un cliente.
class ClienteFormScreen extends ConsumerStatefulWidget {
  const ClienteFormScreen({super.key, this.clienteId});

  final int? clienteId;

  bool get esEdicion => clienteId != null;

  @override
  ConsumerState<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends ConsumerState<ClienteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _telefono = TextEditingController();
  final _direccion = TextEditingController();
  final _zona = TextEditingController();
  final _referencia = TextEditingController();
  final _precio = TextEditingController();
  final _notas = TextEditingController();

  int? _planId;
  late int _diaCorte;
  TipoContratacion _tipo = TipoContratacion.equipoPropio;
  late DateTime _fechaAlta;
  late Mes _primerMes;

  /// Si el usuario eligió el primer mes a mano, ya no se cambia al mover la fecha de alta.
  bool _primerMesElegido = false;

  /// Si el usuario escribió el precio a mano, ya no se reemplaza al cambiar de plan.
  bool _precioEditado = false;
  bool _cargando = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _fechaAlta = soloFecha(DateTime.now());
    _diaCorte = diaCorteSugerido(_fechaAlta);
    _primerMes = primerMesSugerido(_fechaAlta);
    if (widget.esEdicion) {
      _cargando = true;
      _cargarCliente();
    }
  }

  Future<void> _cargarCliente() async {
    final c = await ref.read(clientesRepositoryProvider).obtenerCliente(widget.clienteId!);
    if (!mounted) return;
    if (c != null) {
      _nombre.text = c.nombre;
      _telefono.text = c.telefono ?? '';
      _direccion.text = c.direccion ?? '';
      _zona.text = c.zona ?? '';
      _referencia.text = c.referencia ?? '';
      _precio.text = _centavosATexto(c.precioMensual);
      _notas.text = c.notas ?? '';
      _planId = c.planId;
      _diaCorte = c.diaCorte;
      _tipo = c.tipoContratacion;
      _fechaAlta = c.fechaAlta;
      _primerMes = primerMesDeCobro(primerMesCobro: c.primerMesCobro, fechaAlta: c.fechaAlta);
      _primerMesElegido = true;
      _precioEditado = true;
    }
    setState(() => _cargando = false);
  }

  @override
  void dispose() {
    for (final c in [_nombre, _telefono, _direccion, _zona, _referencia, _precio, _notas]) {
      c.dispose();
    }
    super.dispose();
  }

  /// 25000 -> "250", 25050 -> "250.50" (para escribir en el campo de texto).
  static String _centavosATexto(int centavos) {
    final pesos = centavos ~/ 100;
    final cent = centavos % 100;
    return cent == 0 ? '$pesos' : '$pesos.${cent.toString().padLeft(2, '0')}';
  }

  void _seleccionarPlan(Plan plan) {
    setState(() {
      _planId = plan.id;
      if (!_precioEditado) _precio.text = _centavosATexto(plan.precioBase);
    });
  }

  Future<void> _elegirFechaAlta() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaAlta,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha == null) return;
    setState(() {
      _fechaAlta = soloFecha(fecha);
      final opciones = opcionesPrimerMes(_fechaAlta, DateTime.now());
      if (!_primerMesElegido || !opciones.contains(_primerMes)) {
        _primerMes = primerMesSugerido(_fechaAlta);
      }
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_planId == null) {
      mostrarMensaje(context, 'Selecciona un plan');
      return;
    }
    setState(() => _guardando = true);

    final datos = DatosCliente(
      nombre: _nombre.text.trim(),
      telefono: limpiarTelefono(_telefono.text),
      direccion: textoONull(_direccion.text),
      zona: textoONull(_zona.text),
      referencia: textoONull(_referencia.text),
      planId: _planId!,
      precioMensual: textoACentavos(_precio.text),
      diaCorte: _diaCorte,
      tipoContratacion: _tipo,
      fechaAlta: _fechaAlta,
      primerMesCobro: _primerMes,
      notas: textoONull(_notas.text),
    );
    final repo = ref.read(clientesRepositoryProvider);

    try {
      if (widget.esEdicion) {
        await repo.actualizarCliente(widget.clienteId!, datos);
        if (!mounted) return;
        mostrarMensaje(context, 'Cambios guardados');
        context.pop();
      } else {
        final id = await repo.crearCliente(datos);
        if (!mounted) return;
        mostrarMensaje(context, 'Cliente registrado');
        context.pushReplacement('/clientes/$id');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      mostrarMensaje(context, 'No se pudo guardar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final planes = ref.watch(planesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.esEdicion ? 'Editar cliente' : 'Nuevo cliente'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : planes.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorVista(e),
              data: _formulario,
            ),
    );
  }

  Widget _campoPrimerMes() {
    final opciones = opcionesPrimerMes(_fechaAlta, DateTime.now());
    if (!opciones.contains(_primerMes)) opciones.add(_primerMes);
    opciones.sort();
    final alta = Mes.deFecha(_fechaAlta);
    String etiqueta(Mes m) {
      if (m == alta) return '${m.nombre} (mes del alta)';
      if (m == alta.siguiente()) return '${m.nombre} (mes siguiente)';
      return m.nombre;
    }

    return DropdownButtonFormField<Mes>(
      // La clave fuerza a reconstruir el campo cuando cambia la fecha de alta.
      key: ValueKey('primer-mes-$alta-$_primerMes'),
      initialValue: _primerMes,
      decoration: const InputDecoration(
        labelText: 'Primer mes de cobro *',
        helperText: 'Desde este mes se generan los cobros mensuales',
      ),
      items: [
        for (final m in opciones) DropdownMenuItem(value: m, child: Text(etiqueta(m))),
      ],
      onChanged: (m) {
        if (m != null) {
          setState(() {
            _primerMes = m;
            _primerMesElegido = true;
          });
        }
      },
    );
  }

  Widget _formulario(List<Plan> planes) {
    // Plan por defecto para un cliente nuevo: el primero (el más barato).
    if (_planId == null && planes.isNotEmpty) {
      _planId = planes.first.id;
      if (!_precioEditado && _precio.text.isEmpty) {
        _precio.text = _centavosATexto(planes.first.precioBase);
      }
    }

    const espacio = SizedBox(height: 16);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Datos de contacto', style: Theme.of(context).textTheme.titleMedium),
          espacio,
          TextFormField(
            controller: _nombre,
            decoration: const InputDecoration(
              labelText: 'Nombre completo *',
            ),
            textCapitalization: TextCapitalization.words,
            validator: validarNombre,
          ),
          espacio,
          TextFormField(
            controller: _telefono,
            decoration: const InputDecoration(
              labelText: 'Teléfono (10 dígitos)',
            ),
            keyboardType: TextInputType.phone,
            validator: validarTelefono,
          ),
          espacio,
          TextFormField(
            controller: _direccion,
            decoration: const InputDecoration(
              labelText: 'Dirección',
            ),
          ),
          espacio,
          TextFormField(
            controller: _zona,
            decoration: const InputDecoration(
              labelText: 'Zona / comunidad',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          espacio,
          TextFormField(
            controller: _referencia,
            decoration: const InputDecoration(
              labelText: 'Referencia (cómo llegar)',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          Text('Servicio', style: Theme.of(context).textTheme.titleMedium),
          espacio,
          DropdownButtonFormField<int>(
            initialValue: _planId,
            decoration: const InputDecoration(
              labelText: 'Plan *',
            ),
            items: [
              for (final p in planes)
                DropdownMenuItem(
                  value: p.id,
                  child: Text('${p.nombre} · ${formatoDinero(p.precioBase)}'),
                ),
            ],
            onChanged: (id) {
              if (id == null) return;
              _seleccionarPlan(planes.firstWhere((p) => p.id == id));
            },
          ),
          espacio,
          TextFormField(
            controller: _precio,
            decoration: const InputDecoration(
              labelText: 'Precio mensual *',
              prefixText: '\$ ',
              helperText: 'Puede ser distinto al del plan (p. ej. zonas alejadas)',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: validarMontoObligatorio,
            onChanged: (_) => _precioEditado = true,
          ),
          if (widget.esEdicion)
            const Padding(
              padding: EdgeInsets.only(top: 4, left: 12),
              child: Text(
                'Si cambias el precio, solo aplica a los meses que se generen después.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          espacio,
          DropdownButtonFormField<int>(
            initialValue: _diaCorte,
            decoration: const InputDecoration(
              labelText: 'Día de corte (vencimiento) *',
            ),
            items: [
              for (var d = 1; d <= 28; d++)
                DropdownMenuItem(value: d, child: Text('Día $d de cada mes')),
            ],
            onChanged: (d) {
              if (d != null) setState(() => _diaCorte = d);
            },
          ),
          espacio,
          DropdownButtonFormField<TipoContratacion>(
            initialValue: _tipo,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Tipo de contratación *',
            ),
            items: [
              for (final t in TipoContratacion.values)
                DropdownMenuItem(value: t, child: Text(t.etiqueta)),
            ],
            onChanged: (t) {
              if (t != null) setState(() => _tipo = t);
            },
          ),
          espacio,
          InkWell(
            onTap: _elegirFechaAlta,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Fecha de alta',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(formatoFecha(_fechaAlta)),
            ),
          ),
          espacio,
          _campoPrimerMes(),
          espacio,
          TextFormField(
            controller: _notas,
            decoration: const InputDecoration(
              labelText: 'Notas',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _guardando ? null : _guardar,
            icon: _guardando
                ? const SizedBox.square(
                    dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save),
            label: Text(widget.esEdicion ? 'Guardar cambios' : 'Registrar cliente'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
