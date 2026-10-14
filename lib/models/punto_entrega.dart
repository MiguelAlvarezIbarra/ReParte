/// Lugar donde la asociacion recoge una donacion.
/// Pertenece a un donante y puede reutilizarse en varias donaciones.
class PuntoEntrega {
  final String id;
  final String donanteId;
  final String nombre;
  final String direccion;
  final double latitud;
  final double longitud;

  /// Horario de recoleccion en texto libre, por ejemplo "18:00 a 20:30".
  final String horario;

  const PuntoEntrega({
    required this.id,
    required this.donanteId,
    required this.nombre,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    this.horario = '',
  });

  factory PuntoEntrega.fromMap(String id, Map<String, dynamic> map) {
    return PuntoEntrega(
      id: id,
      donanteId: map['donanteId'] as String,
      nombre: map['nombre'] as String,
      direccion: map['direccion'] as String,
      latitud: (map['latitud'] as num).toDouble(),
      longitud: (map['longitud'] as num).toDouble(),
      horario: map['horario'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'donanteId': donanteId,
        'nombre': nombre,
        'direccion': direccion,
        'latitud': latitud,
        'longitud': longitud,
        'horario': horario,
      };
}
