class Organizador {
  final String idParticipante;
  final String nombre;
  final String apellidos;
  final String emailEduca;
  final String centro;
  final String codigoCentro;
  final String rol;
  final String fechaRegistro;
  final String idEvento;

  Organizador({
    required this.idParticipante,
    required this.nombre,
    required this.apellidos,
    required this.emailEduca,
    required this.centro,
    required this.codigoCentro,
    this.rol = 'organizador',
    this.fechaRegistro = '',
    this.idEvento = '',
  });
}