// ─────────────────────────────────────────────
// MODELO DE DATOS: ORGANIZADOR
// Representa a un organizador registrado en la plataforma.
// ─────────────────────────────────────────────
class Organizador {
  final String idOrganizador;
  final String nombre;
  final String apellidos;
  final String emailEduca;
  final String centro;
  final String codigoCentro;
  final String rol;
  final String fechaRegistro;
  final String idEvento;
  final String password;
  final String fotoPerfilUrl;

  Organizador({
    required this.idOrganizador,
    required this.nombre,
    required this.apellidos,
    required this.emailEduca,
    required this.centro,
    required this.codigoCentro,
    this.rol = 'organizador',
    this.fechaRegistro = '',
    this.idEvento = '',
    required this.password,
    required this.fotoPerfilUrl,
  });

  Organizador copyWith({
    String? nombre,
    String? apellidos,
    String? emailEduca,
    String? centro,
    String? codigoCentro,
    String? rol,
    String? fechaRegistro,
    String? idEvento,
    String? password,
    String? fotoPerfilUrl,
  }) {
    return Organizador(
      idOrganizador: idOrganizador,
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      emailEduca: emailEduca ?? this.emailEduca,
      centro: centro ?? this.centro,
      codigoCentro: codigoCentro ?? this.codigoCentro,
      rol: rol ?? this.rol,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      idEvento: idEvento ?? this.idEvento,
      password: password ?? this.password,
      fotoPerfilUrl: fotoPerfilUrl ?? this.fotoPerfilUrl,
    );
  }
}