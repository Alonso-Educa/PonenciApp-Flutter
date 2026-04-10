import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/organizador.dart';
import '../../providers/app_state.dart';
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

  // Controla la visibilidad de la contraseña
  bool _passwordVisible = false;

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

  void _guardarOrganizador(MyAppState appState) {
    if (!_formKey.currentState!.validate()) return;

    // Comprueba que el email no esté ya registrado
    final emailYaExiste = appState.organizadores
        .any((o) => o.emailEduca == _emailCtrl.text.trim());

    if (emailYaExiste) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ya existe una cuenta con ese email')),
      );
      return;
    }

    appState.addOrganizador(
      Organizador(
        idParticipante: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: _nombreCtrl.text.trim(),
        apellidos: _apellidosCtrl.text.trim(),
        emailEduca: _emailCtrl.text.trim(),
        centro: _centroCtrl.text.trim(),
        codigoCentro: _codigoCentroCtrl.text.trim(),
        rol: 'organizador', // ← corregido
        fechaRegistro: _formatearFechaHora(DateTime.now()),
        idEvento: '',
        password: _passwordCtrl.text.trim(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Cuenta registrada correctamente. Por favor inicia sesión.',
        ),
      ),
    );

    // Vuelve al login tras registrarse
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

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
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
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

                  // ── Campo contraseña con toggle ───────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: _passwordCtrl,
                      obscureText: !_passwordVisible,
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
                        if (texto.length < 10) {
                          return 'Mínimo 10 caracteres';
                        }
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
                        onPressed: () => _guardarOrganizador(appState),
                        icon: const Icon(Icons.check),
                        label: const Text('Aceptar'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _limpiarFormulario,
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