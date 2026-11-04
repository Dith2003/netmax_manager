import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../data/repositories/usuarios_repository.dart';
import '../../data/repositories/vencimientos_repository.dart' show OperacionNoPermitida;
import '../../domain/usuarios.dart';
import '../../providers/sesion.dart';
import '../../widgets/comunes.dart';
import '../sesion/acceso_screen.dart' show etiquetaRol;

/// Tarjeta de usuarios en Configuración (solo el propietario la ve).
class TarjetaUsuarios extends ConsumerWidget {
  const TarjetaUsuarios({super.key});

  Future<void> _guardar(BuildContext context, WidgetRef ref, {Usuario? usuario}) async {
    final datos = await showDialog<DatosUsuario>(
      context: context,
      builder: (_) => _DialogoUsuario(usuario),
    );
    if (datos == null) return;
    final repo = ref.read(usuariosRepositoryProvider);
    try {
      if (usuario == null) {
        await repo.crear(datos);
      } else {
        await repo.actualizar(usuario.id, datos);
      }
      if (context.mounted) {
        mostrarMensaje(context, usuario == null ? 'Usuario creado' : 'Usuario actualizado');
      }
    } on OperacionNoPermitida catch (e) {
      if (context.mounted) mostrarMensaje(context, e.mensaje);
    }
  }

  Future<void> _cambiarActivo(BuildContext context, WidgetRef ref, Usuario u, bool activo) async {
    try {
      await ref.read(usuariosRepositoryProvider).cambiarActivo(u.id, activo);
    } on OperacionNoPermitida catch (e) {
      if (context.mounted) mostrarMensaje(context, e.mensaje);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuarios = ref.watch(usuariosProvider);
    final yo = ref.watch(sesionProvider);
    final texto = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.manage_accounts_outlined, color: scheme.secondary),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Usuarios', style: texto.titleMedium),
                            const SizedBox(height: 2),
                            Text(
                              'Quién puede entrar a la app con su PIN. El administrador registra '
                              'clientes y pagos, pero no cambia la configuración, no restaura '
                              'respaldos ni cancela pagos.',
                              style: texto.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _guardar(context, ref),
                  icon: const Icon(Icons.person_add_alt),
                  label: const Text('Nuevo usuario'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          usuarios.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
            ),
            error: (e, _) => ErrorVista(e),
            data: (lista) => Column(
              children: [
                for (final u in lista)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          u.activo ? scheme.secondaryContainer : scheme.surfaceContainerHighest,
                      child: Text(u.nombre.isEmpty ? '?' : u.nombre[0].toUpperCase()),
                    ),
                    title: Text(u.id == yo?.id ? '${u.nombre} (tú)' : u.nombre),
                    subtitle: Text([
                      u.usuario,
                      etiquetaRol(u.rol),
                      if (!u.activo) 'desactivado',
                    ].join(' · ')),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Editar o cambiar PIN',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _guardar(context, ref, usuario: u),
                        ),
                        Tooltip(
                          message: u.activo ? 'Desactivar usuario' : 'Activar usuario',
                          child: Switch(
                            value: u.activo,
                            // No se puede desactivar a uno mismo.
                            onChanged: u.id == yo?.id
                                ? null
                                : (v) => _cambiarActivo(context, ref, u, v),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DialogoUsuario extends StatefulWidget {
  const _DialogoUsuario(this.usuario);

  final Usuario? usuario;

  @override
  State<_DialogoUsuario> createState() => _DialogoUsuarioState();
}

class _DialogoUsuarioState extends State<_DialogoUsuario> {
  final _formKey = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.usuario?.nombre ?? '');
  late final _usuario = TextEditingController(text: widget.usuario?.usuario ?? '');
  final _pin = TextEditingController();
  final _pin2 = TextEditingController();
  late RolUsuario _rol = widget.usuario?.rol ?? RolUsuario.admin;

  bool get _edicion => widget.usuario != null;

  @override
  void dispose() {
    for (final c in [_nombre, _usuario, _pin, _pin2]) {
      c.dispose();
    }
    super.dispose();
  }

  void _aceptar() {
    if (!_formKey.currentState!.validate()) return;
    final pin = _pin.text.trim();
    Navigator.of(context).pop(DatosUsuario(
      nombre: _nombre.text,
      usuario: _usuario.text,
      rol: _rol,
      pin: pin.isEmpty ? null : pin,
    ));
  }

  @override
  Widget build(BuildContext context) {
    const espacio = SizedBox(height: 12);
    final soloNumeros = [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(6),
    ];
    return AlertDialog(
      title: Text(_edicion ? 'Editar usuario' : 'Nuevo usuario'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nombre,
                  autofocus: !_edicion,
                  decoration: const InputDecoration(labelText: 'Nombre *'),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v ?? '').trim().length < 2 ? 'Escribe el nombre' : null,
                ),
                espacio,
                TextFormField(
                  controller: _usuario,
                  enabled: !_edicion,
                  decoration: InputDecoration(
                    labelText: 'Usuario *',
                    helperText: _edicion ? 'El usuario no se puede cambiar' : 'Sin acentos ni espacios',
                  ),
                  validator: _edicion ? null : validarNombreUsuario,
                ),
                espacio,
                DropdownButtonFormField<RolUsuario>(
                  initialValue: _rol,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Rol *'),
                  items: [
                    for (final r in RolUsuario.values)
                      DropdownMenuItem(value: r, child: Text(etiquetaRol(r))),
                  ],
                  onChanged: (r) {
                    if (r != null) setState(() => _rol = r);
                  },
                ),
                espacio,
                TextFormField(
                  controller: _pin,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: soloNumeros,
                  decoration: InputDecoration(
                    labelText: _edicion ? 'PIN nuevo' : 'PIN (4 a 6 números) *',
                    helperText: _edicion ? 'Déjalo vacío para no cambiarlo' : null,
                  ),
                  validator: (v) => _edicion && (v ?? '').isEmpty ? null : validarPin(v),
                ),
                espacio,
                TextFormField(
                  controller: _pin2,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: soloNumeros,
                  decoration: const InputDecoration(labelText: 'Repite el PIN'),
                  validator: (v) => v != _pin.text ? 'Los PIN no coinciden' : null,
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
          child: Text(_edicion ? 'Guardar cambios' : 'Crear usuario'),
        ),
      ],
    );
  }
}
