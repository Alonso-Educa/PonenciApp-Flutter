import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/organizador.dart';
import '../../providers/app_state.dart';
import '../../widgets/custom_scaffold.dart';
import 'autenticacion/login_page.dart';

// ─────────────────────────────────────────────
// PANTALLA DE AJUSTES
// Muestra los datos del organizador activo,
// permite editarlos, cambiar el tema, cerrar sesión y eliminar la cuenta.
// ─────────────────────────────────────────────
class AjustesPage extends StatelessWidget {
  const AjustesPage({super.key});

  void _irAlLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  void _confirmarCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.logout),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas cerrar sesión y volver al menú de inicio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                context.read<MyAppState>().cerrarSesion();
                Navigator.pop(context);
                _irAlLogin(context);
              }
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final organizador = appState.organizadorActual;
    final theme = Theme.of(context);

    return CustomScaffold(
      title: 'Ajustes',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [

          // ─────────────────────────────────────────────────────
          // SECCIÓN: DATOS DEL USUARIO
          // ─────────────────────────────────────────────────────
          Text(
            'Datos del usuario',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Puedes editar los datos de tu cuenta aquí',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 12),

          if (organizador != null)
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Cabecera ─────────────────────────────────
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: theme.colorScheme.tertiary,
                          child: Text(
                            organizador.nombre.isNotEmpty
                                ? organizador.nombre[0].toUpperCase()
                                : 'O',
                            style: TextStyle(
                              color: theme.colorScheme.onTertiary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${organizador.nombre} ${organizador.apellidos}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                organizador.rol[0].toUpperCase() +
                                    organizador.rol.substring(1),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Editar datos',
                          onPressed: () => showDialog(
                            context: context,
                            useRootNavigator: true,
                            builder: (_) => _DialogEditarOrganizador(
                              organizador: organizador,
                              onGuardado: (actualizado) =>
                                  appState.actualizarOrganizadorActual(
                                actualizado,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 24),

                    // ── Email ───────────────────────────────────
                    Row(
                      children: [
                        Icon(Icons.email_outlined,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          organizador.emailEduca,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // ── Centro ──────────────────────────────────
                    Row(
                      children: [
                        Icon(Icons.school_outlined,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          '${organizador.centro} — ${organizador.codigoCentro}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 24),

                    // ── Opciones de credenciales ─────────────────
                    Text(
                      'Restablecer mis datos privados',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Cambiar email
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => showDialog(
                              context: context,
                              useRootNavigator: true,
                              builder: (_) => _DialogCambiarEmail(
                                emailActual: organizador.emailEduca,
                                onEmailCambiado: (nuevoEmail) {
                                  // Actualiza el estado local para reflejar
                                  // el nuevo email en la UI
                                  appState.actualizarOrganizadorActual(
                                    Organizador(
                                      idParticipante:
                                          organizador.idParticipante,
                                      nombre: organizador.nombre,
                                      apellidos: organizador.apellidos,
                                      emailEduca: nuevoEmail,
                                      centro: organizador.centro,
                                      codigoCentro: organizador.codigoCentro,
                                      rol: organizador.rol,
                                      fechaRegistro: organizador.fechaRegistro,
                                      idEvento: organizador.idEvento,
                                      password: organizador.password,
                                    ),
                                  );
                                },
                              ),
                            ),
                            icon: Icon(
                              Icons.email_outlined,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            label: Text(
                              'Cambiar correo',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),

                        // Restablecer contraseña
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => showDialog(
                              context: context,
                              useRootNavigator: true,
                              builder: (_) => _DialogRecuperarContrasena(
                                emailActual: organizador.emailEduca,
                              ),
                            ),
                            icon: Icon(
                              Icons.lock_outline,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            label: Text(
                              'Restablecer contraseña',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // ─────────────────────────────────────────────────────
          // SECCIÓN: PERSONALIZACIÓN
          // ─────────────────────────────────────────────────────
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Personalización',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cambia el aspecto de la aplicación',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.dark_mode_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Modo oscuro',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Switch(
                value: appState.isDarkTheme,
                onChanged: (_) => appState.toggleTheme(),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ─────────────────────────────────────────────────────
          // SECCIÓN: GESTIÓN DE CUENTA
          // ─────────────────────────────────────────────────────
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Gestión de cuenta',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Puedes eliminar permanentemente tu cuenta y todos tus datos.',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 12),

          // Botón borrar cuenta
          OutlinedButton.icon(
            onPressed: () => showDialog(
              context: context,
              useRootNavigator: true,
              builder: (_) => _DialogBorrarCuenta(
                onConfirmado: () async {
                  await context.read<MyAppState>().eliminarCuenta();
                  if (context.mounted) _irAlLogin(context);
                },
              ),
            ),
            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            label: Text(
              'Borrar cuenta',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.colorScheme.error),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),

          const Divider(height: 32),

          // Botón cerrar sesión
          TextButton.icon(
            onPressed: () => _confirmarCerrarSesion(context),
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.red),
            ),
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              alignment: Alignment.centerLeft,
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DIÁLOGO EDITAR ORGANIZADOR
// Actualiza nombre, apellidos, centro y código
// en Firestore. El email no es editable aquí.
// ─────────────────────────────────────────────

class _DialogEditarOrganizador extends StatefulWidget {
  final Organizador organizador;
  final Function(Organizador) onGuardado;

  const _DialogEditarOrganizador({
    required this.organizador,
    required this.onGuardado,
  });

  @override
  State<_DialogEditarOrganizador> createState() =>
      _DialogEditarOrganizadorState();
}

class _DialogEditarOrganizadorState extends State<_DialogEditarOrganizador> {
  late TextEditingController _nombreCtrl;
  late TextEditingController _apellidosCtrl;
  late TextEditingController _centroCtrl;
  late TextEditingController _codigoCentroCtrl;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.organizador.nombre);
    _apellidosCtrl =
        TextEditingController(text: widget.organizador.apellidos);
    _centroCtrl = TextEditingController(text: widget.organizador.centro);
    _codigoCentroCtrl =
        TextEditingController(text: widget.organizador.codigoCentro);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidosCtrl.dispose();
    _centroCtrl.dispose();
    _codigoCentroCtrl.dispose();
    super.dispose();
  }

  void _snack(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _guardar() async {
    if (_nombreCtrl.text.trim().isEmpty) {
      _snack('El nombre no puede estar vacío');
      return;
    }
    if (_apellidosCtrl.text.trim().isEmpty) {
      _snack('Los apellidos no pueden estar vacíos');
      return;
    }
    if (_centroCtrl.text.trim().isEmpty) {
      _snack('El centro no puede estar vacío');
      return;
    }
    if (_codigoCentroCtrl.text.trim().isEmpty) {
      _snack('El código de centro no puede estar vacío');
      return;
    }

    setState(() => _cargando = true);

    try {
      final uid = widget.organizador.idParticipante;

      // Actualiza en Firestore
      await FirebaseFirestore.instance
          .collection('participantes')
          .doc(uid)
          .update({
        'nombre': _nombreCtrl.text.trim(),
        'apellidos': _apellidosCtrl.text.trim(),
        'centro': _centroCtrl.text.trim(),
        'codigoCentro': _codigoCentroCtrl.text.trim(),
      });

      final actualizado = Organizador(
        idParticipante: uid,
        nombre: _nombreCtrl.text.trim(),
        apellidos: _apellidosCtrl.text.trim(),
        emailEduca: widget.organizador.emailEduca,
        centro: _centroCtrl.text.trim(),
        codigoCentro: _codigoCentroCtrl.text.trim(),
        rol: widget.organizador.rol,
        fechaRegistro: widget.organizador.fechaRegistro,
        idEvento: widget.organizador.idEvento,
        password: widget.organizador.password,
      );

      widget.onGuardado(actualizado);

      if (mounted) {
        Navigator.pop(context);
        _snack('Datos actualizados correctamente');
      }
    } catch (e) {
      setState(() => _cargando = false);
      _snack('Error al actualizar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar datos'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Email: solo lectura
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Email (no editable)',
                hintText: widget.organizador.emailEduca,
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            _campo(_nombreCtrl, 'Nombre'),
            _campo(_apellidosCtrl, 'Apellidos'),
            _campo(_centroCtrl, 'Centro educativo'),
            _campo(_codigoCentroCtrl, 'Código de centro'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cargando ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _cargando ? null : _guardar,
          child: _cargando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _campo(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        enabled: !_cargando,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DIÁLOGO RECUPERAR CONTRASEÑA
// Envía un email de restablecimiento a la
// dirección del organizador activo.
// El email viene pre-rellenado pero es editable
// por si quiere enviarlo a otra dirección.
// ─────────────────────────────────────────────

class _DialogRecuperarContrasena extends StatefulWidget {
  final String emailActual;

  const _DialogRecuperarContrasena({required this.emailActual});

  @override
  State<_DialogRecuperarContrasena> createState() =>
      _DialogRecuperarContrasenaState();
}

class _DialogRecuperarContrasenaState
    extends State<_DialogRecuperarContrasena> {
  late TextEditingController _emailCtrl;
  bool _cargando = false;

  final _emailPattern = RegExp(
    r'^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  @override
  void initState() {
    super.initState();
    // Pre-rellena con el email del organizador activo
    _emailCtrl = TextEditingController(text: widget.emailActual);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final email = _emailCtrl.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce tu email')),
      );
      return;
    }
    if (!_emailPattern.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formato de email inválido')),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email de restablecimiento enviado a $email'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _cargando = false);
      final mensaje = switch (e.code) {
        'user-not-found' => 'No existe ninguna cuenta con ese email',
        'invalid-email' => 'El formato del email no es válido',
        _ => 'Error: ${e.message}',
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensaje)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Restablecer contraseña'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Te enviaremos un enlace para restablecer tu contraseña.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailCtrl,
            enabled: !_cargando,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _cargando ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _cargando ? null : _enviar,
          child: _cargando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enviar'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// DIÁLOGO CAMBIAR EMAIL
// Re-autentica al organizador con su contraseña
// actual y envía un enlace de verificación al
// nuevo email. El cambio solo se aplica cuando
// el organizador pulsa el enlace del email.
// ─────────────────────────────────────────────

class _DialogCambiarEmail extends StatefulWidget {
  final String emailActual;
  final Function(String) onEmailCambiado;

  const _DialogCambiarEmail({
    required this.emailActual,
    required this.onEmailCambiado,
  });

  @override
  State<_DialogCambiarEmail> createState() => _DialogCambiarEmailState();
}

class _DialogCambiarEmailState extends State<_DialogCambiarEmail> {
  final _nuevoEmailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _passwordVisible = false;
  bool _cargando = false;

  final _emailPattern = RegExp(
    r'^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  @override
  void dispose() {
    _nuevoEmailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _snack(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _enviar() async {
    final nuevoEmail = _nuevoEmailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (nuevoEmail.isEmpty) {
      _snack('Introduce el nuevo email');
      return;
    }
    if (!_emailPattern.hasMatch(nuevoEmail)) {
      _snack('Formato de email inválido');
      return;
    }
    if (nuevoEmail == widget.emailActual) {
      _snack('El email nuevo es igual al actual');
      return;
    }
    if (password.isEmpty) {
      _snack('Introduce tu contraseña actual para confirmar');
      return;
    }

    setState(() => _cargando = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Paso 1: re-autenticar con la contraseña actual
      // Firebase exige re-autenticación antes de cambiar email
      final credencial = EmailAuthProvider.credential(
        email: widget.emailActual,
        password: password,
      );
      await user.reauthenticateWithCredential(credencial);

      // Paso 2: enviar enlace de verificación al nuevo email
      // El cambio solo se aplica cuando el usuario pulsa el enlace
      await user.verifyBeforeUpdateEmail(nuevoEmail);

      // Paso 3: actualizar en Firestore con el nuevo email
      // Se hace ya para que la UI sea consistente, aunque Auth
      // no lo cambia hasta que el usuario verifique el enlace
      await FirebaseFirestore.instance
          .collection('participantes')
          .doc(user.uid)
          .update({'emailEduca': nuevoEmail});

      widget.onEmailCambiado(nuevoEmail);

      if (mounted) {
        Navigator.pop(context);
        _snack(
          'Email de confirmación enviado a $nuevoEmail. '
          'Por favor verifica el enlace para completar el cambio.',
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _cargando = false);
      final mensaje = switch (e.code) {
        'wrong-password' => 'Contraseña incorrecta',
        'invalid-credential' => 'Contraseña incorrecta',
        'email-already-in-use' => 'Ese email ya está en uso por otra cuenta',
        'invalid-email' => 'Formato de email inválido',
        'requires-recent-login' =>
          'Por seguridad, cierra sesión y vuelve a entrar antes de cambiar el email',
        _ => 'Error: ${e.message}',
      };
      _snack(mensaje);
    } catch (e) {
      setState(() => _cargando = false);
      _snack('Error inesperado: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cambiar correo electrónico'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Introduce tu nuevo correo. Te enviaremos un enlace de '
            'confirmación. Inicia sesión de nuevo tras verificarlo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nuevoEmailCtrl,
            enabled: !_cargando,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Nuevo correo',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordCtrl,
            enabled: !_cargando,
            obscureText: !_passwordVisible,
            decoration: InputDecoration(
              labelText: 'Contraseña actual',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _passwordVisible = !_passwordVisible),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _cargando ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _cargando ? null : _enviar,
          child: _cargando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enviar'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// DIÁLOGO BORRAR CUENTA
// Re-autentica con contraseña, elimina el
// documento de Firestore y borra la cuenta
// de Firebase Auth.
// ─────────────────────────────────────────────

class _DialogBorrarCuenta extends StatefulWidget {
  final VoidCallback onConfirmado;

  const _DialogBorrarCuenta({required this.onConfirmado});

  @override
  State<_DialogBorrarCuenta> createState() => _DialogBorrarCuentaState();
}

class _DialogBorrarCuentaState extends State<_DialogBorrarCuenta> {
  final _passwordCtrl = TextEditingController();
  bool _passwordVisible = false;
  bool _cargando = false;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _snack(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _borrar() async {
    final password = _passwordCtrl.text.trim();

    if (password.isEmpty) {
      _snack('Introduce tu contraseña para confirmar');
      return;
    }

    setState(() => _cargando = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Paso 1: re-autenticar
      final credencial = EmailAuthProvider.credential(
        email: user.email ?? '',
        password: password,
      );
      await user.reauthenticateWithCredential(credencial);

      // Paso 2: eliminar documento de Firestore
      await FirebaseFirestore.instance
          .collection('participantes')
          .doc(user.uid)
          .delete();

      // Paso 3: eliminar cuenta de Firebase Auth
      await user.delete();

      if (mounted) {
        Navigator.pop(context);
        widget.onConfirmado();
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _cargando = false);
      final mensaje = switch (e.code) {
        'wrong-password' => 'Contraseña incorrecta',
        'invalid-credential' => 'Contraseña incorrecta',
        'requires-recent-login' =>
          'Por seguridad, cierra sesión y vuelve a entrar antes de borrar la cuenta',
        _ => 'Error: ${e.message}',
      };
      _snack(mensaje);
    } catch (e) {
      setState(() => _cargando = false);
      _snack('Error inesperado: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded),
      title: const Text('Borrar mi cuenta'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Para confirmar, introduce tu contraseña. '
            'Esta acción es irreversible y eliminará todos tus datos.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordCtrl,
            enabled: !_cargando,
            obscureText: !_passwordVisible,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _passwordVisible = !_passwordVisible),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _cargando ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _cargando ? null : _borrar,
          child: _cargando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  'Borrar cuenta',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
        ),
      ],
    );
  }
}