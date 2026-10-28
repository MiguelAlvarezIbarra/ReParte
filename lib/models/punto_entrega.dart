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

  /// Valida que el punto de entrega tenga datos obligatorios no vacios.
  /// Lanza [ArgumentError] si algun campo es invalido.
  void validar() {
    if (donanteId.trim().isEmpty) {
      throw ArgumentError('El donante es obligatorio');
    }
    if (nombre.trim().isEmpty) {
      throw ArgumentError('El nombre del punto de entrega es obligatorio');
    }
    if (direccion.trim().isEmpty) {
      throw ArgumentError('La dirección de entrega es obligatoria');
    }
  }

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
