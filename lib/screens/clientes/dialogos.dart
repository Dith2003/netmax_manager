import 'package:flutter/material.dart';

import '../../core/dinero.dart';
import '../../core/etiquetas.dart';
import '../../core/fechas.dart';
import '../../data/db/enums.dart';
import '../../data/repositories/clientes_repository.dart';
import '../../domain/clientes.dart';

/// Campo para elegir una fecha con el calendario.
class _CampoFecha extends StatelessWidget {
  const _CampoFecha({required this.etiqueta, required this.fecha, required this.onCambio});

  final String etiqueta;
  final DateTime fecha;
  final ValueChanged<DateTime> onCambio;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final f = await showDatePicker(
          context: context,
          initialDate: fecha,
          firstDate: DateTime(2015),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (f != null) onCambio(soloFecha(f));
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: etiqueta,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(formatoFecha(fecha)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Instalación
// ---------------------------------------------------------------------------

Future<DatosInstalacion?> mostrarDialogoInstalacion(BuildContext context) {
  return showDialog<DatosInstalacion>(
    context: context,
    builder: (_) => const _DialogoInstalacion(),
  );
}

class _DialogoInstalacion extends StatefulWidget {
  const _DialogoInstalacion();

  @override
  State<_DialogoInstalacion> createState() => _DialogoInstalacionState();
}

class _DialogoInstalacionState extends State<_DialogoInstalacion> {
  final _formKey = GlobalKey<FormState>();
  final _costo = TextEditingController();
  final _tecnico = TextEditingController();
  final _notas = TextEditingController();
  DateTime _fecha = soloFecha(DateTime.now());
  bool _pagado = false;

  @override
  void dispose() {
    _costo.dispose();
    _tecnico.dispose();
    _notas.dispose();
    super.dispose();
  }

  void _aceptar() {
    if (!_formKey.currentState!.validate()) return;
    final costoTexto = _costo.text.trim();
    Navigator.of(context).pop(DatosInstalacion(
      fecha: _fecha,
      costo: costoTexto.isEmpty ? 0 : textoACentavos(costoTexto),
      pagado: _pagado,
      tecnico: textoONull(_tecnico.text),
      notas: textoONull(_notas.text),
    ));
  }

  @override
  Widget build(BuildContext context) {
    const espacio = SizedBox(height: 12);
    return AlertDialog(
      title: const Text('Registrar instalación'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CampoFecha(
                  etiqueta: 'Fecha',
                  fecha: _fecha,
                  onCambio: (f) => setState(() => _fecha = f),
                ),
                espacio,
                TextFormField(
                  controller: _costo,
                  decoration: const InputDecoration(
                    labelText: 'Costo de instalación',
                    prefixText: '\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: validarMontoOpcional,
                ),
                CheckboxListTile(
                  value: _pagado,
                  onChanged: (v) => setState(() => _pagado = v ?? false),
                  title: const Text('Ya está pagada'),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                TextFormField(
                  controller: _tecnico,
                  decoration: const InputDecoration(
                    labelText: 'Técnico',
                  ),
                ),
                espacio,
                TextFormField(
                  controller: _notas,
                  decoration: const InputDecoration(
                    labelText: 'Notas',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _aceptar, child: const Text('Guardar')),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Equipo
// ---------------------------------------------------------------------------

/// [propiedadSugerida]: NetMAX si el cliente tiene equipo prestado.
Future<DatosEquipo?> mostrarDialogoEquipo(
  BuildContext context, {
  required PropiedadEquipo propiedadSugerida,
}) {
  return showDialog<DatosEquipo>(
    context: context,
    builder: (_) => _DialogoEquipo(propiedadSugerida),
  );
}

class _DialogoEquipo extends StatefulWidget {
  const _DialogoEquipo(this.propiedadSugerida);

  final PropiedadEquipo propiedadSugerida;

  @override
  State<_DialogoEquipo> createState() => _DialogoEquipoState();
}

class _DialogoEquipoState extends State<_DialogoEquipo> {
  final _formKey = GlobalKey<FormState>();
  final _tipo = TextEditingController(text: 'Antena');
  final _marcaModelo = TextEditingController();
  final _serie = TextEditingController();
  final _costo = TextEditingController();
  final _notas = TextEditingController();
  late PropiedadEquipo _propiedad = widget.propiedadSugerida;
  DateTime _fechaEntrega = soloFecha(DateTime.now());

  @override
  void dispose() {
    for (final c in [_tipo, _marcaModelo, _serie, _costo, _notas]) {
      c.dispose();
    }
    super.dispose();
  }

  void _aceptar() {
    if (!_formKey.currentState!.validate()) return;
    final costoTexto = _costo.text.trim();
    Navigator.of(context).pop(DatosEquipo(
      tipo: _tipo.text.trim(),
      marcaModelo: textoONull(_marcaModelo.text),
      numeroSerie: textoONull(_serie.text),
      propiedad: _propiedad,
      costo: costoTexto.isEmpty ? null : textoACentavos(costoTexto),
      fechaEntrega: _fechaEntrega,
      notas: textoONull(_notas.text),
    ));
  }

  @override
  Widget build(BuildContext context) {
    const espacio = SizedBox(height: 12);
    return AlertDialog(
      title: const Text('Registrar equipo'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _tipo,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de equipo *',
                    helperText: 'Antena, router, cable…',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Escribe el tipo de equipo' : null,
                ),
                espacio,
                DropdownButtonFormField<PropiedadEquipo>(
                  initialValue: _propiedad,
                  decoration: const InputDecoration(
                    labelText: '¿De quién es? *',
                  ),
                  items: [
                    for (final p in PropiedadEquipo.values)
                      DropdownMenuItem(value: p, child: Text(p.etiqueta)),
                  ],
                  onChanged: (p) {
                    if (p != null) setState(() => _propiedad = p);
                  },
                ),
                espacio,
                TextFormField(
                  controller: _marcaModelo,
                  decoration: const InputDecoration(
                    labelText: 'Marca y modelo',
                  ),
                ),
                espacio,
                TextFormField(
                  controller: _serie,
                  decoration: const InputDecoration(
                    labelText: 'Número de serie',
                  ),
                ),
                espacio,
                TextFormField(
                  controller: _costo,
                  decoration: const InputDecoration(
                    labelText: 'Costo',
                    prefixText: '\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: validarMontoOpcional,
                ),
                espacio,
                _CampoFecha(
                  etiqueta: 'Fecha de entrega',
                  fecha: _fechaEntrega,
                  onCambio: (f) => setState(() => _fechaEntrega = f),
                ),
                espacio,
                TextFormField(
                  controller: _notas,
                  decoration: const InputDecoration(
                    labelText: 'Notas',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _aceptar, child: const Text('Guardar')),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Cambio de estado
// ---------------------------------------------------------------------------

/// Pide confirmación (y un motivo opcional) para cambiar el estado del cliente.
/// Devuelve el motivo ('' si no escribió nada) o null si canceló.
Future<String?> confirmarCambioEstado(
  BuildContext context, {
  required String nombreCliente,
  required EstadoCliente nuevo,
}) {
  final motivo = TextEditingController();
  final accion = switch (nuevo) {
    EstadoCliente.activo => 'Reactivar',
    EstadoCliente.suspendido => 'Suspender',
    EstadoCliente.cancelado => 'Cancelar servicio de',
  };
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('$accion $nombreCliente'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('El estado cambiará a "${nuevo.etiqueta}". Queda registrado en el historial.'),
          const SizedBox(height: 12),
          TextField(
            controller: motivo,
            decoration: const InputDecoration(
              labelText: 'Motivo (opcional)',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Volver'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(motivo.text.trim()),
          child: const Text('Confirmar'),
        ),
      ],
    ),
  );
}

/// Pide confirmación para cancelar un pago capturado por error.
/// Devuelve el motivo ('' si no escribió nada) o null si no se canceló.
Future<String?> confirmarCancelarPago(BuildContext context, {required String monto}) {
  final motivo = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Cancelar pago de $monto'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'El pago no se borra: queda marcado como cancelado y los meses que '
            'cubría vuelven a quedar pendientes.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: motivo,
            decoration: const InputDecoration(
              labelText: 'Motivo (opcional)',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Volver'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(motivo.text.trim()),
          child: const Text('Cancelar pago'),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Cargo extra
// ---------------------------------------------------------------------------

typedef DatosCargo = ({String concepto, int monto, DateTime fecha, String? notas});

/// Captura un cargo extra (p. ej. equipo no devuelto). Devuelve null si se cancela.
Future<DatosCargo?> mostrarDialogoCargo(
  BuildContext context, {
  String conceptoInicial = '',
  int? montoInicial,
}) {
  return showDialog<DatosCargo>(
    context: context,
    builder: (_) => _DialogoCargo(conceptoInicial, montoInicial),
  );
}

class _DialogoCargo extends StatefulWidget {
  const _DialogoCargo(this.conceptoInicial, this.montoInicial);

  final String conceptoInicial;
  final int? montoInicial;

  @override
  State<_DialogoCargo> createState() => _DialogoCargoState();
}

class _DialogoCargoState extends State<_DialogoCargo> {
  final _formKey = GlobalKey<FormState>();
  late final _concepto = TextEditingController(text: widget.conceptoInicial);
  late final _monto = TextEditingController(
    text: widget.montoInicial == null
        ? ''
        : (widget.montoInicial! % 100 == 0
            ? '${widget.montoInicial! ~/ 100}'
            : '${widget.montoInicial! ~/ 100}.${(widget.montoInicial! % 100).toString().padLeft(2, '0')}'),
  );
  final _notas = TextEditingController();
  DateTime _fecha = soloFecha(DateTime.now());

  @override
  void dispose() {
    _concepto.dispose();
    _monto.dispose();
    _notas.dispose();
    super.dispose();
  }

  void _aceptar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop((
      concepto: _concepto.text.trim(),
      monto: textoACentavos(_monto.text),
      fecha: _fecha,
      notas: textoONull(_notas.text),
    ));
  }

  @override
  Widget build(BuildContext context) {
    const espacio = SizedBox(height: 12);
    return AlertDialog(
      title: const Text('Agregar cargo extra'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _concepto,
                  decoration: const InputDecoration(
                    labelText: 'Concepto *',
                    helperText: 'Ej. Antena no devuelta, reconexión…',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Escribe el concepto' : null,
                ),
                espacio,
                TextFormField(
                  controller: _monto,
                  decoration: const InputDecoration(
                    labelText: 'Monto *',
                    prefixText: '\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: validarMontoObligatorio,
                ),
                espacio,
                _CampoFecha(
                  etiqueta: 'Fecha del cargo',
                  fecha: _fecha,
                  onCambio: (f) => setState(() => _fecha = f),
                ),
                espacio,
                TextFormField(
                  controller: _notas,
                  decoration: const InputDecoration(
                    labelText: 'Notas',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _aceptar, child: const Text('Agregar')),
      ],
    );
  }
}
