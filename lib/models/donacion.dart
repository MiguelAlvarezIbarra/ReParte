/// Estados por los que pasa una donacion dentro de la app.
enum EstadoDonacion { disponible, reservada, entregada, cancelada }

/// Representa una donacion publicada por un donante.
class Donacion {
  final String id;
  final String donanteId;
  final String descripcion;
  final double cantidadKg;
  final DateTime caducidad;
  final EstadoDonacion estado;

  const Donacion({
    required this.id,
    required this.donanteId,
    required this.descripcion,
    required this.cantidadKg,
    required this.caducidad,
    this.estado = EstadoDonacion.disponible,
  });

  bool get estaVigente => caducidad.isAfter(DateTime.now());

  factory Donacion.fromMap(String id, Map<String, dynamic> map) {
    return Donacion(
      id: id,
      donanteId: map['donanteId'] as String,
      descripcion: map['descripcion'] as String,
      cantidadKg: (map['cantidadKg'] as num).toDouble(),
      caducidad: DateTime.parse(map['caducidad'] as String),
      estado: EstadoDonacion.values.firstWhere(
        (e) => e.name == map['estado'],
        orElse: () => EstadoDonacion.disponible,
      ),
    );
  }

  Map<String, dynamic> toMap() => {
        'donanteId': donanteId,
        'descripcion': descripcion,
        'cantidadKg': cantidadKg,
        'caducidad': caducidad.toIso8601String(),
        'estado': estado.name,
      };
}
