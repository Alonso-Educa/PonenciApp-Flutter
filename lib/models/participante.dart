class Participante {
  final String idParticipante;
  final String nombre;
  final String apellidos;
  final String emailEduca;
  final String centro;
  final String codigoCentro;
  final String rol;
  final String fechaRegistro;
  final String idEvento;

  Participante({
    required this.idParticipante,
    required this.nombre,
    required this.apellidos,
    required this.emailEduca,
    required this.centro,
    required this.codigoCentro,
    this.rol = 'participante',
    this.fechaRegistro = '',
    this.idEvento = '',
  });

  Participante copyWith({
    String? nombre,
    String? apellidos,
    String? emailEduca,
    String? centro,
    String? codigoCentro,
    String? rol,
    String? fechaRegistro,
    String? idEvento,
  }) {
    return Participante(
      idParticipante: idParticipante,
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      emailEduca: emailEduca ?? this.emailEduca,
      centro: centro ?? this.centro,
      codigoCentro: codigoCentro ?? this.codigoCentro,
      rol: rol ?? this.rol,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      idEvento: idEvento ?? this.idEvento,
    );
  }
}