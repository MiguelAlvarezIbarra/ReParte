/// Estados por los que pasa una donacion dentro de la app.
enum EstadoDonacion { disponible, reservada, entregada, cancelada }

/// Representa una donacion publicada por un donante.
class Donacion {
  final String id;
  final String donanteId;
  final String descripcion;
  final double cantidadKg;
  final DateTime caducidad;
  final String puntoEntregaId;
  final DateTime creadaEn;
  final EstadoDonacion estado;

  /// Asociacion que reservo la donacion; null mientras esta disponible.
  final String? asociacionId;

  const Donacion({
    required this.id,
    required this.donanteId,
    required this.descripcion,
    required this.cantidadKg,
    required this.caducidad,
    required this.puntoEntregaId,
    required this.creadaEn,
    this.estado = EstadoDonacion.disponible,
    this.asociacionId,
  });

  bool get estaVigente => caducidad.isAfter(DateTime.now());

  bool get estaDisponible => estado == EstadoDonacion.disponible && estaVigente;

  /// Copia con cambios, util para reservar o marcar como entregada.
  Donacion copyWith({EstadoDonacion? estado, String? asociacionId}) {
    return Donacion(
      id: id,
      donanteId: donanteId,
      descripcion: descripcion,
      cantidadKg: cantidadKg,
      caducidad: caducidad,
      puntoEntregaId: puntoEntregaId,
      creadaEn: creadaEn,
      estado: estado ?? this.estado,
      asociacionId: asociacionId ?? this.asociacionId,
    );
  }

  factory Donacion.fromMap(String id, Map<String, dynamic> map) {
    return Donacion(
      id: id,
      donanteId: map['donanteId'] as String,
      descripcion: map['descripcion'] as String,
      cantidadKg: (map['cantidadKg'] as num).toDouble(),
      caducidad: DateTime.parse(map['caducidad'] as String),
      puntoEntregaId: map['puntoEntregaId'] as String,
      creadaEn: DateTime.parse(map['creadaEn'] as String),
      estado: EstadoDonacion.values.firstWhere(
        (e) => e.name == map['estado'],
        orElse: () => EstadoDonacion.disponible,
      ),
      asociacionId: map['asociacionId'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'donanteId': donanteId,
        'descripcion': descripcion,
        'cantidadKg': cantidadKg,
        'caducidad': caducidad.toIso8601String(),
        'puntoEntregaId': puntoEntregaId,
        'creadaEn': creadaEn.toIso8601String(),
        'estado': estado.name,
        'asociacionId': asociacionId,
      };
}
