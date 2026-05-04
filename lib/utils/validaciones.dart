import 'dart:math';

// lib/utils/validaciones.dart
//
// Lógica de validación extraída de los widgets para permitir
// tests unitarios de caja blanca sin necesidad de levantar la UI.
//
// Uso:
//   - En login_page.dart           → sustituir _emailPattern y las guards de _iniciarSesion
//   - En registro_page.dart        → sustituir los validator: inline del TextFormField
//   - En dialog_crear_ponencia     → sustituir la guard de horas en _guardar()
//   - En crear_participante.dart   → sustituir validator de contraseña (líneas 233-238)
//                                    y _formatearFechaHora() (líneas 48-55)
//   - En estadisticas_page.dart    → sustituir parseo de fecha (líneas 84-90)

class Validaciones {
  // ─────────────────────────────────────────────────────────────
  // EMAIL
  // Patrón extraído de LoginPage y RegistroOrganizadorPage (_campo).
  // ─────────────────────────────────────────────────────────────

  static final _emailPattern = RegExp(
    r'^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  /// Devuelve true si el email tiene formato válido.
  /// Devuelve false si está vacío o no coincide con el patrón.
  static bool emailEsValido(String email) {
    final texto = email.trim();
    if (texto.isEmpty) return false;
    return _emailPattern.hasMatch(texto);
  }

  // ─────────────────────────────────────────────────────────────
  // CONTRASEÑA — LOGIN
  // Regla extraída de _iniciarSesion en LoginPage:
  //   · No puede estar vacía
  //   · Debe tener al menos 6 caracteres
  // ─────────────────────────────────────────────────────────────

  /// Devuelve null si la contraseña es válida para el login,
  /// o el mensaje de error correspondiente.
  static String? validarPasswordLogin(String password) {
    final texto = password.trim();
    if (texto.isEmpty) return 'Introduce tu contraseña';
    if (texto.length < 6)
      return 'La contraseña debe tener al menos 6 caracteres';
    return null;
  }

  // ─────────────────────────────────────────────────────────────
  // CONTRASEÑA — REGISTRO ORGANIZADOR
  // Regla extraída del validator del TextFormField en RegistroOrganizadorPage:
  //   · No puede estar vacía
  //   · Mínimo 10 caracteres
  //   · Al menos un carácter especial (no alfanumérico)
  // ─────────────────────────────────────────────────────────────

  /// Devuelve null si la contraseña cumple los requisitos de registro,
  /// o el mensaje de error correspondiente.
  static String? validarPasswordRegistro(String? value) {
    final texto = value?.trim() ?? '';
    if (texto.isEmpty) return 'Campo obligatorio';
    if (texto.length < 10) return 'Mínimo 10 caracteres';
    if (!texto.contains(RegExp(r'[^A-Za-z0-9]'))) {
      return 'Debe incluir al menos un carácter especial';
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────
  // CONTRASEÑA — PARTICIPANTE
  // Extraído del validator en crear_participante.dart (líneas 233-238).
  // Regla: no vacía + mínimo 6 caracteres (sin requisito de carácter especial)
  // ─────────────────────────────────────────────────────────────

  /// Devuelve null si la contraseña cumple los requisitos de participante,
  /// o el mensaje de error correspondiente.
  static String? validarPasswordParticipante(String? value) {
    final texto = value?.trim() ?? '';
    if (texto.isEmpty) return 'Campo obligatorio';
    if (texto.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  // ─────────────────────────────────────────────────────────────
  // CAMPO OBLIGATORIO GENÉRICO
  // Extraído del helper _campo() en RegistroOrganizadorPage.
  // ─────────────────────────────────────────────────────────────

  /// Devuelve null si el campo contiene texto, 'Campo obligatorio' si no.
  static String? validarCampoObligatorio(String? value) {
    final texto = value?.trim() ?? '';
    if (texto.isEmpty) return 'Campo obligatorio';
    return null;
  }

  // ─────────────────────────────────────────────────────────────
  // HORAS DE PONENCIA
  // Extraído de _guardar() en DialogCrearPonencia:
  //   finCtrl.text.compareTo(inicioCtrl.text) <= 0 → error
  // Formato esperado: "HH:mm" en 24h (e.g. "09:00", "17:30")
  // ─────────────────────────────────────────────────────────────

  /// Devuelve true si horaFin es estrictamente posterior a horaInicio.
  /// Devuelve false si son iguales o fin es anterior a inicio.
  static bool horaFinEsValida(String horaInicio, String horaFin) {
    return horaFin.trim().compareTo(horaInicio.trim()) > 0;
  }

  // ─────────────────────────────────────────────────────────────
  // CÓDIGO DE EVENTO — GENERADOR
  // Extraído de _generarCodigo() en DialogCrearEvento.
  // Formato generado: 'FORM-XXXX' donde X es [A-Za-z0-9]
  // ─────────────────────────────────────────────────────────────

  /// Devuelve el código de evento generado para su posterior validación.
  static String generarCodigoEvento() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    final code = List.generate(
      4,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
    return 'FORM-$code';
  }

  // ─────────────────────────────────────────────────────────────
  // CÓDIGO DE EVENTO — VALIDADOR
  // Formato esperado: 'FORM-' + 4 chars de [A-Za-z0-9]
  // ─────────────────────────────────────────────────────────────

  /// Devuelve true si el código tiene el formato FORM-XXXX válido.
  static bool codigoEventoEsValido(String codigo) {
    return RegExp(r'^FORM-[A-Za-z0-9]{4}$').hasMatch(codigo);
  }

  // ─────────────────────────────────────────────────────────────
  // FORMATEO DE FECHA/HORA
  // Extraído de _formatearFechaHora() en crear_participante.dart (líneas 48-55)
  // ─────────────────────────────────────────────────────────────

  /// Devuelve la fecha y hora formateada como "dd/MM/yyyy HH:mm:ss".
  static String formatearFechaHora(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final ss = dt.second.toString().padLeft(2, '0');
    return '$dd/$mm/${dt.year} $hh:$min:$ss';
  }

  // ─────────────────────────────────────────────────────────────
  // PARSEO DE FECHA DE EVENTO
  // Extraído de estadisticas_page.dart (líneas 84-90)
  // Formato esperado: "dd/MM/yyyy"
  // ─────────────────────────────────────────────────────────────

  /// Parsea una fecha en formato "dd/MM/yyyy" y devuelve un DateTime,
  /// o null si el formato es inválido.
  static DateTime? parsearFechaEvento(String fecha) {
    try {
      final partes = fecha.split('/');
      if (partes.length != 3) return null;
      return DateTime(
        int.parse(partes[2]),
        int.parse(partes[1]),
        int.parse(partes[0]),
      );
    } catch (_) {
      return null;
    }
  }
}
