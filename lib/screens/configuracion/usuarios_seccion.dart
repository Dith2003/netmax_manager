import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../data/repositories/usuarios_repository.dart';
import '../../data/repositories/vencimientos_repository.dart' show OperacionNoPermitida;
import '../../domain/usuarios.dart';
import '../../providers/sesion.dart';
import '../../widgets/comunes.dart';
import '../sesion/acceso_screen.dart' show etiquetaPerfil;

/// Gestión de usuarios en Configuración: quién entra y qué puede hacer cada uno.
class TarjetaUsuarios extends ConsumerWidget {
  const TarjetaUsuarios({super.key});

  Future<void> _guardar(BuildContext context, WidgetRef ref, {Usuario? usuario}) async {
    final datos = await showDialog<DatosUsuario>(
      context: context,
      builder: (_) => DialogoUsuario(usuario: usuario),
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
                            Text('Gestión de usuarios', style: texto.titleMedium),
                            const SizedBox(height: 2),
                            Text(
                              'Quién puede entrar a la app con su PIN y qué puede hacer. Al crear '
                              'un usuario parte de un perfil (Propietario o Administrador) y '
                              'ajusta sus permisos uno por uno.',
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
                    isThreeLine: true,
                    leading: CircleAvatar(
                      backgroundColor:
                          u.activo ? scheme.secondaryContainer : scheme.surfaceContainerHighest,
                      child: Text(u.nombre.isEmpty ? '?' : u.nombre[0].toUpperCase()),
                    ),
                    title: Text(u.id == yo?.id ? '${u.nombre} (tú)' : u.nombre),
                    subtitle: Text(
                      '${[
                        u.usuario,
                        etiquetaPerfil(u),
                        if (!u.activo) 'desactivado',
                      ].join(' · ')}\n${_resumenPermisos(permisosDeUsuario(u))}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Editar permisos o cambiar PIN',
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

/// "8 de 10 permisos · sin: Cancelar pagos, Restaurar respaldos".
String _resumenPermisos(Set<Permiso> permisos) {
  final total = Permiso.values.length;
  if (permisos.length == total) return 'Todos los permisos';
  final faltan = Permiso.values.where((p) => !permisos.contains(p)).map((p) => p.etiqueta);
  return '${permisos.length} de $total permisos · sin: ${faltan.join(', ')}';
}

/// Formulario de usuario: datos, PIN, perfil base y permisos uno por uno.
class DialogoUsuario extends StatefulWidget {
  const DialogoUsuario({super.key, this.usuario});

  final Usuario? usuario;

  @override
  State<DialogoUsuario> createState() => _DialogoUsuarioState();
}

class _DialogoUsuarioState extends State<DialogoUsuario> {
  final _formKey = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.usuario?.nombre ?? '');
  late final _usuario = TextEditingController(text: widget.usuario?.usuario ?? '');
  final _pin = TextEditingController();
  final _pin2 = TextEditingController();
  late Set<Permiso> _permisos = widget.usuario == null
      ? PerfilBase.administrador.permisos.toSet()
      : permisosDeUsuario(widget.usuario!).toSet();

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
      permisos: _permisos,
      pin: pin.isEmpty ? null : pin,
    ));
  }

  @override
  Widget build(BuildContext context) {
    const espacio = SizedBox(height: 12);
    final texto = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final soloNumeros = [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(6),
    ];
    final perfilActual = nombrePerfil(_permisos);
    final grupos = <String, List<Permiso>>{};
    for (final p in Permiso.values) {
      grupos.putIfAbsent(p.grupo, () => []).add(p);
    }

    return AlertDialog(
      title: Text(_edicion ? 'Editar usuario' : 'Nuevo usuario'),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    helperText:
                        _edicion ? 'El usuario no se puede cambiar' : 'Sin acentos ni espacios',
                  ),
                  validator: _edicion ? null : validarNombreUsuario,
                ),
                espacio,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _pin,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: soloNumeros,
                        decoration: InputDecoration(
                          labelText: _edicion ? 'PIN nuevo' : 'PIN (4 a 6 números) *',
                          helperText: _edicion ? 'Vacío = no cambia' : null,
                        ),
                        validator: (v) => _edicion && (v ?? '').isEmpty ? null : validarPin(v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _pin2,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: soloNumeros,
                        decoration: const InputDecoration(labelText: 'Repite el PIN'),
                        validator: (v) => v != _pin.text ? 'Los PIN no coinciden' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Perfil base', style: texto.titleSmall),
                const SizedBox(height: 4),
                Text('Marca los permisos de un perfil; después puedes ajustarlos uno por uno.',
                    style: texto.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final perfil in PerfilBase.values)
                      Tooltip(
                        message: perfil.descripcion,
                        child: ChoiceChip(
                          label: Text(perfil.nombre),
                          selected: perfilActual == perfil.nombre,
                          onSelected: (_) =>
                              setState(() => _permisos = perfil.permisos.toSet()),
                        ),
                      ),
                    if (perfilActual == 'Personalizado')
                      const Chip(
                        avatar: Icon(Icons.tune, size: 18),
                        label: Text('Personalizado'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Permisos', style: texto.titleSmall),
                for (final MapEntry(key: grupo, value: lista) in grupos.entries) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 2),
                    child: Text(grupo.toUpperCase(),
                        style: texto.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                  ),
                  for (final p in lista)
                    CheckboxListTile(
                      value: _permisos.contains(p),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(p.etiqueta),
                      subtitle: Text(p.descripcion),
                      onChanged: (v) => setState(() {
                        _permisos = {..._permisos};
                        if (v ?? false) {
                          _permisos.add(p);
                        } else {
                          _permisos.remove(p);
                        }
                      }),
                    ),
                ],
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
