// ─────────────────────────────────────────────
// MODELO DE DATOS: PONENCIA
// Representa a una ponencia registrado en la plataforma.
// ─────────────────────────────────────────────
class Ponencia {
  final String idPonencia;
  final String titulo;
  final String ponente;
  final String descripcion;
  final String horaInicio;
  final String horaFin;
  final String qrCode;
  final String idEvento;
  final int orden;

  Ponencia({
    required this.idPonencia,
    required this.titulo,
    required this.ponente,
    required this.descripcion,
    required this.horaInicio,
    required this.horaFin,
    this.qrCode = '',
    required this.idEvento,
    this.orden = 0,
  });

  Ponencia copyWith({
    String? titulo,
    String? ponente,
    String? descripcion,
    String? horaInicio,
    String? horaFin,
    String? qrCode,
    String? idEvento,
    int? orden,
  }) {
    return Ponencia(
      idPonencia: idPonencia,
      titulo: titulo ?? this.titulo,
      ponente: ponente ?? this.ponente,
      descripcion: descripcion ?? this.descripcion,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      qrCode: qrCode ?? this.qrCode,
      idEvento: idEvento ?? this.idEvento,
      orden: orden ?? this.orden,
    );
  }
}
