import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/custom_scaffold.dart';

// ─────────────────────────────────────────────
// PANTALLA DE REGISTRO DE ORGANIZADOR
// El organizador introduce sus datos para crear
// su cuenta. Tras el registro vuelve al login.
// ─────────────────────────────────────────────
class RegistroOrganizadorPage extends StatefulWidget {
  const RegistroOrganizadorPage({super.key});

  @override
  State<RegistroOrganizadorPage> createState() =>
      _RegistroOrganizadorPageState();
}

class _RegistroOrganizadorPageState extends State<RegistroOrganizadorPage> {
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _centroCtrl = TextEditingController();
  final _codigoCentroCtrl = TextEditingController();
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

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      // ── Paso 1: crear cuenta en Firebase Auth ────────────────
      final resultado = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text.trim(),
          );

      final uid = resultado.user?.uid ?? '';

      // ── Paso 2: guardar datos en Firestore ───────────────────
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'nombre': _nombreCtrl.text.trim(),
        'apellidos': _apellidosCtrl.text.trim(),
        'emailEduca': _emailCtrl.text.trim(),
        'centro': _centroCtrl.text.trim(),
        'codigoCentro': _codigoCentroCtrl.text.trim(),
        'rol': 'organizador',
        'fechaRegistro': _formatearFechaHora(DateTime.now()),
        'idEvento': '',
        'fotoPerfilUrl': '',
      });

      // ── Paso 3: cerrar sesión para que inicie sesión desde el login ──
      // No dejamos al usuario logueado automáticamente para que
      // pase por el flujo de login, donde se verifica el rol
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cuenta creada correctamente. Por favor inicia sesión.',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _cargando = false);

      final mensaje = switch (e.code) {
        'email-already-in-use' => 'Ya existe una cuenta con ese email',
        'invalid-email' => 'El formato del email no es válido',
        'weak-password' => 'La contraseña es demasiado débil',
        _ => 'Error al registrar: ${e.message}',
      };
      _mostrarError(mensaje);
    } catch (e) {
      setState(() => _cargando = false);
      _mostrarError('Error inesperado: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Registro de usuario',
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
                  // ── Cabecera ──────────────────────────────────
                  const Text(
                    'Crear cuenta de organizador',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Completa los datos de tu cuenta y pulsa Aceptar.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),

                  // ── Campos ────────────────────────────────────
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
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
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

                  // ── Contraseña con toggle ─────────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: _passwordCtrl,
                      obscureText: !_passwordVisible,
                      enabled: !_cargando,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        hintText: 'Mínimo 10 caracteres y un símbolo',
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
                        if (texto.length < 10) return 'Mínimo 10 caracteres';
                        if (!texto.contains(RegExp(r'[^A-Za-z0-9]'))) {
                          return 'Debe incluir al menos un carácter especial';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Botones ───────────────────────────────────
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _cargando ? null : _registrar,
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
    List<TextInputFormatter>? inputFormatters,
  }) {
    final emailPattern = RegExp(
      r'^[\p{L}\p{N}._%+\-]+@[\p{L}\p{N}_\-]+(\.[\p{L}\p{N}_\-]+)*\.[\p{L}]{2,}$',
      unicode: true,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: teclado,
        enabled: !_cargando,
        inputFormatters: inputFormatters,
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
      ),
    );
  }
}
