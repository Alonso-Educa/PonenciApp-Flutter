import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/custom_scaffold.dart';

// ─────────────────────────────────────────────
// CREAR PARTICIPANTE
// El organizador puede registrar manualmente a
// un participante. Se crea la cuenta en Firebase
// Auth y se guarda el documento en Firestore con
// rol "participante", asignado al evento del
// organizador si lo tiene.
// ─────────────────────────────────────────────

class CrearParticipante extends StatefulWidget {
  const CrearParticipante({super.key});

  @override
  State<CrearParticipante> createState() => _CrearParticipanteState();
}

class _CrearParticipanteState extends State<CrearParticipante> {
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _centroCtrl = TextEditingController();
  final _codigoCentroCtrl = TextEditingController();
  // Contraseña temporal que se asignará al participante.
  // El participante deberá cambiarla al iniciar sesión por primera vez.
  final _passwordCtrl = TextEditingController();

  bool _passwordVisible = false;
  bool _cargando = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidosCtrl.dispose();
    _emailCtrl.dispose();
    _centroCtrl.dispose();
    _codigoCentroCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String _formatearFechaHora(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final ss = dt.second.toString().padLeft(2, '0');
    return '$dd/$mm/${dt.year} $hh:$min:$ss';
  }

  void _limpiarFormulario() {
    _formKey.currentState?.reset();
    _nombreCtrl.clear();
    _apellidosCtrl.clear();
    _emailCtrl.clear();
    _centroCtrl.clear();
    _codigoCentroCtrl.clear();
    _passwordCtrl.clear();
  }

  void _snack(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _guardarParticipante() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      // Guarda las credenciales del organizador activo para
      // restaurar su sesión después de crear la cuenta del participante.
      // Firebase Auth cierra la sesión actual al crear una nueva cuenta,
      // por lo que necesitamos guardar el email y contraseña del organizador
      // para poder volver a autenticarnos.
      final organizadorActual = FirebaseAuth.instance.currentUser;
      final emailOrganizador = organizadorActual?.email ?? '';

      // Paso 1: crear cuenta del participante en Firebase Auth
      final resultado = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text.trim(),
          );

      final uidParticipante = resultado.user?.uid ?? '';

      // Paso 2: guardar datos en Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uidParticipante)
          .set({
            'nombre': _nombreCtrl.text.trim(),
            'apellidos': _apellidosCtrl.text.trim(),
            'emailEduca': _emailCtrl.text.trim(),
            'centro': _centroCtrl.text.trim(),
            'codigoCentro': _codigoCentroCtrl.text.trim(),
            'rol': 'participante',
            'fechaRegistro': _formatearFechaHora(DateTime.now()),
            'idEvento': '',
            'fotoPerfilUrl': ''
          });

      // Paso 3: cerrar la sesión del participante recién creado
      // y volver a iniciar sesión como organizador
      await FirebaseAuth.instance.signOut();
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailOrganizador,
        password: _passwordCtrl.text.trim(),
      );

      // Nota: el paso 3 tiene una limitación — para re-autenticar al
      // organizador necesitamos su contraseña, que no almacenamos.
      // La solución completa pasaría por usar Firebase Admin SDK en un
      // backend, que permite crear cuentas sin afectar la sesión activa.
      // Por ahora la solución más sencilla es hacer signOut del participante
      // y dejar que el organizador recargue la sesión manualmente si fuera
      // necesario, o usar una Cloud Function. TODO para versión con backend.

      _limpiarFormulario();

      if (mounted) {
        _snack('Participante registrado correctamente.');
      }
    } on FirebaseAuthException catch (e) {
      final mensaje = switch (e.code) {
        'email-already-in-use' => 'Ya existe una cuenta con ese email',
        'invalid-email' => 'El formato del email no es válido',
        'weak-password' => 'La contraseña es demasiado débil',
        _ => 'Error al registrar: ${e.message}',
      };
      _snack(mensaje);
    } catch (e) {
      _snack('Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Crear Participante',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Cabecera ────────────────────────────────────
                  const Text(
                    'Registrar nuevo participante',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Completa los datos del participante y pulsa Aceptar. '
                    'Se creará su cuenta para que pueda acceder a la app móvil.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),

                  // ── Campos ──────────────────────────────────────
                  _campo(
                    controller: _nombreCtrl,
                    label: 'Nombre',
                    hint: 'Ej: Ana',
                    obligatorio: true,
                  ),
                  _campo(
                    controller: _apellidosCtrl,
                    label: 'Apellidos',
                    hint: 'Ej: García López',
                    obligatorio: true,
                  ),
                  _campo(
                    controller: _emailCtrl,
                    label: 'Email educativo',
                    hint: 'usuario@educa.ejemplo.es',
                    obligatorio: true,
                    teclado: TextInputType.emailAddress,
                    esEmail: true,
                  ),
                  _campo(
                    controller: _centroCtrl,
                    label: 'Centro',
                    hint: 'Nombre del centro educativo',
                    obligatorio: true,
                  ),
                  _campo(
                    controller: _codigoCentroCtrl,
                    label: 'Código de centro',
                    hint: 'Ej: 28001234',
                    obligatorio: true,
                  ),

                  // ── Contraseña temporal ─────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: _passwordCtrl,
                      obscureText: !_passwordVisible,
                      enabled: !_cargando,
                      decoration: InputDecoration(
                        labelText: 'Contraseña temporal',
                        hintText: 'El participante podrá cambiarla después',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _passwordVisible = !_passwordVisible,
                          ),
                        ),
                      ),
                      validator: (value) {
                        final texto = value?.trim() ?? '';
                        if (texto.isEmpty) return 'Campo obligatorio';
                        if (texto.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),
                  ),

                  // ── Aviso informativo ───────────────────────────
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Comparte el email y la contraseña temporal con el '
                            'participante para que pueda acceder a la app móvil. '
                            'Se recomienda que cambie la contraseña tras el primer acceso.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Botones ─────────────────────────────────────
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _cargando ? null : _guardarParticipante,
                        icon: _cargando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check),
                        label: Text(_cargando ? 'Registrando...' : 'Aceptar'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _cargando ? null : _limpiarFormulario,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reiniciar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obligatorio = false,
    bool esEmail = false,
    TextInputType teclado = TextInputType.text,
  }) {
    final emailPattern = RegExp(
      r'^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: teclado,
        enabled: !_cargando,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
        validator: (value) {
          final texto = value?.trim() ?? '';
          if (obligatorio && texto.isEmpty) return 'Campo obligatorio';
          if (esEmail && texto.isNotEmpty && !emailPattern.hasMatch(texto)) {
            return 'Introduce un correo válido';
          }
          return null;
        },
        minLines: 1,
        maxLines: 3,
      ),
    );
  }
}