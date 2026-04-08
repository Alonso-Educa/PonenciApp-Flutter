class Evento {
  final String idEvento;
  final String nombre;
  final String fecha;
  final String lugar;
  final String descripcion;
  final String codigoEvento;

  Evento({
    required this.idEvento,
    required this.nombre,
    required this.fecha,
    required this.lugar,
    required this.descripcion,
    required this.codigoEvento,
  });

  Evento copyWith({
    String? nombre,
    String? fecha,
    String? lugar,
    String? descripcion,
    String? codigoEvento,
  }) {
    return Evento(
      idEvento: idEvento,
      nombre: nombre ?? this.nombre,
      fecha: fecha ?? this.fecha,
      lugar: lugar ?? this.lugar,
      descripcion: descripcion ?? this.descripcion,
      codigoEvento: codigoEvento ?? this.codigoEvento,
    );
  }
}