import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/marca.dart';
import '../../data/db/database.dart';
import '../../data/repositories/usuarios_repository.dart';
import '../../data/repositories/vencimientos_repository.dart' show OperacionNoPermitida;
import '../../domain/usuarios.dart';
import '../../providers/sesion.dart';
import '../../widgets/comunes.dart';

/// Muestra la app solo si hay sesión; si no, la pantalla de acceso.
///
/// Va dentro de `MaterialApp.builder`, por eso la pantalla de acceso lleva su
/// propio Navigator (para sus diálogos y mensajes).
class PuertaSesion extends ConsumerWidget {
  const PuertaSesion({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(sesionProvider) != null) return child;
    return ScaffoldMessenger(
      child: Navigator(
        onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => const AccesoScreen()),
      ),
    );
  }
}

/// Pantalla de acceso: crea el primer usuario (propietario) o pide usuario y PIN.
class AccesoScreen extends ConsumerWidget {
  const AccesoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuarios = ref.watch(usuariosProvider);
    return Scaffold(
      backgroundColor: ColoresNetMax.azul,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: MarcaNetMax(alto: 56, sobreOscuro: true, conLema: true),
                  ),
                  const SizedBox(height: 28),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: usuarios.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, _) => ErrorVista(e),
                        data: (lista) {
                          final activos = lista.where((u) => u.activo).toList();
                          return activos.isEmpty
                              ? const _PrimerUsuario()
                              : _IniciarSesion(usuarios: activos);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Iniciar sesión
// ---------------------------------------------------------------------------

class _IniciarSesion extends ConsumerStatefulWidget {
  const _IniciarSesion({required this.usuarios});

  final List<Usuario> usuarios;

  @override
  ConsumerState<_IniciarSesion> createState() => _IniciarSesionState();
}

class _IniciarSesionState extends ConsumerState<_IniciarSesion> {
  final _pin = TextEditingController();
  final _focoPin = FocusNode();
  late Usuario _elegido = widget.usuarios.first;
  String? _error;
  bool _revisando = false;
  int _fallidos = 0;
  DateTime? _bloqueado;

  @override
  void dispose() {
    _pin.dispose();
    _focoPin.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    final ahora = DateTime.now();
    if (_bloqueado != null && ahora.isBefore(_bloqueado!)) {
      final s = _bloqueado!.difference(ahora).inSeconds + 1;
      setState(() => _error = 'Demasiados intentos. Espera $s segundos.');
      return;
    }
    final pin = _pin.text.trim();
    if (pin.isEmpty) {
      setState(() => _error = 'Escribe tu PIN');
      return;
    }
    setState(() {
      _revisando = true;
      _error = null;
    });
    final usuario =
        await ref.read(usuariosRepositoryProvider).autenticar(_elegido.usuario, pin);
    if (!mounted) return;
    if (usuario != null) {
      ref.read(sesionProvider.notifier).iniciar(usuario);
      return;
    }
    _fallidos++;
    _bloqueado = bloqueadoHasta(fallidos: _fallidos, ultimoFallo: DateTime.now());
    if (_bloqueado != null) _fallidos = 0;
    _pin.clear();
    setState(() {
      _revisando = false;
      _error = _bloqueado != null
          ? 'Demasiados intentos. Espera ${espera.inSeconds} segundos.'
          : 'PIN incorrecto';
    });
    _focoPin.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Iniciar sesión', style: texto.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Elige tu usuario y escribe tu PIN',
            style: texto.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 20),
        for (final u in widget.usuarios)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _OpcionUsuario(
              usuario: u,
              elegido: u.id == _elegido.id,
              onTap: () {
                setState(() {
                  _elegido = u;
                  _error = null;
                });
                _pin.clear();
                _focoPin.requestFocus();
              },
            ),
          ),
        const SizedBox(height: 12),
        TextField(
          controller: _pin,
          focusNode: _focoPin,
          autofocus: true,
          obscureText: true,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: InputDecoration(
            labelText: 'PIN de ${_elegido.nombre}',
            prefixIcon: const Icon(Icons.pin_outlined),
            errorText: _error,
          ),
          onSubmitted: (_) => _entrar(),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _revisando ? null : _entrar,
          icon: _revisando
              ? const SizedBox.square(
                  dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.login),
          label: const Text('Entrar'),
        ),
        const SizedBox(height: 12),
        Text(
          '¿Olvidaste tu PIN? El propietario puede cambiarlo en Configuración › Usuarios.',
          textAlign: TextAlign.center,
          style: texto.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _OpcionUsuario extends StatelessWidget {
  const _OpcionUsuario({required this.usuario, required this.elegido, required this.onTap});

  final Usuario usuario;
  final bool elegido;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: elegido ? scheme.secondaryContainer : scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: elegido ? scheme.secondary : scheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: elegido ? scheme.secondary : scheme.surfaceContainerHighest,
                foregroundColor: elegido ? scheme.onSecondary : scheme.onSurfaceVariant,
                child: Text(usuario.nombre.isEmpty ? '?' : usuario.nombre[0].toUpperCase()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(usuario.nombre, style: Theme.of(context).textTheme.titleSmall),
                    Text('${usuario.usuario} · ${etiquetaPerfil(usuario)}',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              if (elegido) Icon(Icons.check_circle, color: scheme.secondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Propietario", "Administrador" o "Personalizado" según sus permisos.
String etiquetaPerfil(Usuario u) => nombrePerfil(permisosDeUsuario(u));

// ---------------------------------------------------------------------------
// Primer usuario
// ---------------------------------------------------------------------------

class _PrimerUsuario extends ConsumerStatefulWidget {
  const _PrimerUsuario();

  @override
  ConsumerState<_PrimerUsuario> createState() => _PrimerUsuarioState();
}

class _PrimerUsuarioState extends ConsumerState<_PrimerUsuario> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _usuario = TextEditingController();
  final _pin = TextEditingController();
  final _pin2 = TextEditingController();
  bool _guardando = false;

  @override
  void dispose() {
    for (final c in [_nombre, _usuario, _pin, _pin2]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _crear() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    final repo = ref.read(usuariosRepositoryProvider);
    try {
      await repo.crear(DatosUsuario(
        nombre: _nombre.text,
        usuario: _usuario.text,
        permisos: PerfilBase.propietario.permisos,
        pin: _pin.text.trim(),
      ));
      final usuario = await repo.autenticar(_usuario.text, _pin.text.trim());
      if (usuario != null) ref.read(sesionProvider.notifier).iniciar(usuario);
    } on OperacionNoPermitida catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      mostrarMensaje(context, e.mensaje);
    }
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    const espacio = SizedBox(height: 12);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Bienvenida a NET_MAX',
              style: texto.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            'Crea el usuario del propietario. Con él entrarás a la app y podrás agregar '
            'a otros administradores en Configuración.',
            style: texto.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nombre,
            decoration: const InputDecoration(labelText: 'Tu nombre *'),
            textCapitalization: TextCapitalization.words,
            validator: (v) => (v ?? '').trim().length < 2 ? 'Escribe tu nombre' : null,
          ),
          espacio,
          TextFormField(
            controller: _usuario,
            decoration: const InputDecoration(
              labelText: 'Usuario *',
              helperText: 'Ej. edith (sin acentos ni espacios)',
            ),
            validator: validarNombreUsuario,
          ),
          espacio,
          TextFormField(
            controller: _pin,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: const InputDecoration(labelText: 'PIN (4 a 6 números) *'),
            validator: validarPin,
          ),
          espacio,
          TextFormField(
            controller: _pin2,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: const InputDecoration(labelText: 'Repite el PIN *'),
            validator: (v) => v != _pin.text ? 'Los PIN no coinciden' : null,
            onFieldSubmitted: (_) => _crear(),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _guardando ? null : _crear,
            icon: const Icon(Icons.person_add),
            label: const Text('Crear y entrar'),
          ),
        ],
      ),
    );
  }
}
