import 'package:flutter/material.dart';

import '../../core/dinero.dart';
import '../../data/db/database.dart';
import '../../domain/clientes.dart';
import '../../domain/planes.dart';

/// Captura un plan nuevo o los cambios de [plan]. Devuelve null si se cancela.
Future<DatosPlan?> mostrarDialogoPlan(BuildContext context, {Plan? plan}) {
  return showDialog<DatosPlan>(
    context: context,
    builder: (_) => _DialogoPlan(plan),
  );
}

class _DialogoPlan extends StatefulWidget {
  const _DialogoPlan(this.plan);

  final Plan? plan;

  @override
  State<_DialogoPlan> createState() => _DialogoPlanState();
}

class _DialogoPlanState extends State<_DialogoPlan> {
  final _formKey = GlobalKey<FormState>();
  late final _velocidad =
      TextEditingController(text: widget.plan == null ? '' : '${widget.plan!.velocidadMbps}');
  late final _nombre = TextEditingController(text: widget.plan?.nombre ?? '');
  late final _precio = TextEditingController(
      text: widget.plan == null ? '' : centavosATexto(widget.plan!.precioBase));

  /// Si el nombre se escribió a mano, ya no se llena con la velocidad.
  late bool _nombreEditado = widget.plan != null;

  @override
  void dispose() {
    _velocidad.dispose();
    _nombre.dispose();
    _precio.dispose();
    super.dispose();
  }

  void _aceptar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(DatosPlan(
      nombre: _nombre.text.trim(),
      velocidadMbps: int.parse(_velocidad.text.trim()),
      precioBase: textoACentavos(_precio.text),
    ));
  }

  @override
  Widget build(BuildContext context) {
    const espacio = SizedBox(height: 12);
    final edicion = widget.plan != null;
    return AlertDialog(
      title: Text(edicion ? 'Editar plan' : 'Nuevo plan'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _velocidad,
                  autofocus: !edicion,
                  decoration: const InputDecoration(
                    labelText: 'Velocidad *',
                    suffixText: 'Mbps',
                  ),
                  keyboardType: TextInputType.number,
                  validator: validarVelocidad,
                  onChanged: (v) {
                    final mbps = int.tryParse(v.trim());
                    if (!_nombreEditado && mbps != null) {
                      _nombre.text = nombreSugeridoPlan(mbps);
                    }
                  },
                ),
                espacio,
                TextFormField(
                  controller: _nombre,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del plan *',
                    helperText: 'Ej. 10 Mbps, 20 Mbps zona alejada, Negocio…',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: validarNombrePlan,
                  onChanged: (_) => _nombreEditado = true,
                ),
                espacio,
                TextFormField(
                  controller: _precio,
                  decoration: const InputDecoration(
                    labelText: 'Precio mensual sugerido *',
                    prefixText: '\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: validarMontoObligatorio,
                ),
                espacio,
                Text(
                  edicion
                      ? 'Si cambias el precio, solo se sugiere a los clientes nuevos: '
                          'los clientes que ya tienen este plan conservan su precio.'
                      : 'Es el precio que se propone al registrar un cliente con este plan; '
                          'se puede ajustar para cada cliente.',
                  style: Theme.of(context).textTheme.bodySmall,
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
        FilledButton(
          onPressed: _aceptar,
          child: Text(edicion ? 'Guardar cambios' : 'Crear plan'),
        ),
      ],
    );
  }
}
