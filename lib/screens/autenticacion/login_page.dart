import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/app_state.dart';
import '../home/my_home_page.dart';
import 'registro_organizador_page.dart';
import '../../models/organizador.dart';

// ─────────────────────────────────────────────
// PANTALLA DE LOGIN
// Pantalla inicial de la aplicación. El organizador introduce su email y contraseña para acceder.
// Si no tiene cuenta, puede ir a registrarse.
// ─────────────────────────────────────────────
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _passwordVisible = false;
  bool _cargando = false;

  final _emailPattern = RegExp(
    r'^[\p{L}\p{N}._%+\-]+@[\p{L}\p{N}_\-]+(\.[\p{L}\p{N}_\-]+)*\.[\p{L}]{2,}$',
    unicode: true,
  );

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _iniciarSesion(MyAppState appState) async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    // ── Validaciones de formato ──────────────────────────────
    if (email.isEmpty) {
      _mostrarError('Introduce tu email');
      return;
    }
    if (!_emailPattern.hasMatch(email)) {
      _mostrarError('El formato del email no es válido');
      return;
    }
    if (password.isEmpty) {
      _mostrarError('Introduce tu contraseña');
      return;
    }
    if (password.length < 6) {
      _mostrarError('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    setState(() => _cargando = true);

    try {
      // ── Paso 1: autenticar con Firebase Auth ─────────────────
      final resultado = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = resultado.user?.uid ?? '';

      // ── Paso 2: leer el documento de Firestore ───────────────
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();

      if (!doc.exists) {
        await FirebaseAuth.instance.signOut();
        _mostrarError('No se encontraron datos del usuario');
        setState(() => _cargando = false);
        return;
      }

      final rol = doc.getString('rol') ?? '';

      // ── Paso 3: verificar que es organizador ─────────────────
      if (rol != 'organizador') {
        await FirebaseAuth.instance.signOut();
        _mostrarError(
          'Esta aplicación es solo para organizadores. '
          'Usa la app móvil si eres participante.',
        );
        setState(() => _cargando = false);
        return;
      }

      // ── Paso 4: cargar datos en el estado global ─────────────
      final organizador = Organizador(
        idOrganizador: uid,
        nombre: doc.getString('nombre') ?? '',
        apellidos: doc.getString('apellidos') ?? '',
        emailEduca: doc.getString('emailEduca') ?? '',
        centro: doc.getString('centro') ?? '',
        codigoCentro: doc.getString('codigoCentro') ?? '',
        rol: rol,
        fechaRegistro: doc.getString('fechaRegistro') ?? '',
        idEvento: doc.getString('idEvento') ?? '',
        // La contraseña no se guarda localmente por seguridad
        password: '',
        fotoPerfilUrl: doc.getString('fotoPerfilUrl') ?? '',
      );

      appState.organizadorActual = organizador;

      // ── Paso 5: navegar al panel ─────────────────────────────
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyHomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _cargando = false);

      // Mensajes de error legibles para el usuario
      final mensaje = switch (e.code) {
        'user-not-found' => 'No existe ninguna cuenta con ese email',
        'wrong-password' => 'Contraseña incorrecta',
        'invalid-credential' => 'Email o contraseña incorrectos',
        'user-disabled' => 'Esta cuenta ha sido deshabilitada',
        'too-many-requests' => 'Demasiados intentos. Espera un momento',
        _ => 'Error al iniciar sesión: ${e.message}',
      };
      _mostrarError(mensaje);
    } catch (e) {
      setState(() => _cargando = false);
      _mostrarError('Error inesperado: $e');
    }
  }

  void _showRecuperarContrasenaDialog(BuildContext context) {
    final emailController = TextEditingController();
    final emailPattern = RegExp(
      r'^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape:
            theme.cardTheme.shape ??
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                Text(
                  'Recuperar contraseña',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Introduce tu email y te enviaremos un enlace para restablecer tu contraseña.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: const OutlineInputBorder(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () async {
                        final email = emailController.text.trim();

                        if (email.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Introduce tu email')),
                          );
                          return;
                        }

                        if (!emailPattern.hasMatch(email)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Formato de email inválido'),
                            ),
                          );
                          return;
                        }

                        try {
                          await FirebaseAuth.instance.sendPasswordResetEmail(
                            email: email,
                          );
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Email de recuperación enviado'),
                              ),
                            );
                          }
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error enviando el email'),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Enviar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.primaryContainer,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Logo y título ───────────────────────────────
                Image.asset(
                  isDark
                      ? 'assets/img/logotemaoscuro.png'
                      : 'assets/img/logotemaclaro.png',
                  height: 120,
                ),
                const SizedBox(height: 16),
                Text(
                  'PonenciApp',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Panel de Organizador',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 40),

                // ── Campo email ─────────────────────────────────
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_cargando,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Email educativo',
                    hintText: 'usuario@educa.ejemplo.es',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Campo contraseña ────────────────────────────
                TextField(
                  controller: _passwordCtrl,
                  obscureText: !_passwordVisible,
                  enabled: !_cargando,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _passwordVisible = !_passwordVisible),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _showRecuperarContrasenaDialog(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '¿Has olvidado tu contraseña?',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Botón iniciar sesión ────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _cargando
                        ? null
                        : () => _iniciarSesion(appState),
                    icon: _cargando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.login),
                    label: Text(
                      _cargando ? 'Iniciando sesión...' : 'Iniciar sesión',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Botón registrarse ───────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _cargando
                        ? null
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegistroOrganizadorPage(),
                            ),
                          ),
                    icon: const Icon(Icons.person_add_outlined),
                    label: const Text(
                      'Registrarse',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Extensión auxiliar para leer strings de Firestore de forma segura
extension DocumentSnapshotX on DocumentSnapshot {
  String? getString(String field) {
    final data = this.data() as Map<String, dynamic>?;
    return data?[field] as String?;
  }
}
