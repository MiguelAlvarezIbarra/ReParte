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

  /// Momento en que se reservo; null mientras esta disponible.
  final DateTime? reservadaEn;

  /// Momento en que se entrego; despues de eso ya no cambia.
  final DateTime? entregadaEn;

  /// Ruta o enlace de la foto de la donacion (T34/T35); null si no tiene.
  final String? fotoUrl;

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
    this.reservadaEn,
    this.entregadaEn,
    this.fotoUrl,
  });

  /// True si la donacion cuenta con una foto asignada.
  bool get tieneFoto => fotoUrl != null && fotoUrl!.trim().isNotEmpty;

  /// Entregada o cancelada: el registro queda cerrado.
  bool get estaCerrada =>
      estado == EstadoDonacion.entregada || estado == EstadoDonacion.cancelada;

  bool get estaVigente => caducidad.isAfter(DateTime.now());

  bool get estaDisponible => estado == EstadoDonacion.disponible && estaVigente;

  /// Valida que la donacion tenga datos obligatorios y validos antes de guardarse.
  /// Lanza [ArgumentError] si algun campo esta vacio, la cantidad es cero o menor,
  /// o la fecha de caducidad ya paso.
  void validar({DateTime? ahora}) {
    if (donanteId.trim().isEmpty) {
      throw ArgumentError('El donante es obligatorio');
    }
    if (descripcion.trim().isEmpty) {
      throw ArgumentError('La descripción es obligatoria');
    }
    if (cantidadKg.isNaN || !cantidadKg.isFinite || cantidadKg <= 0) {
      throw ArgumentError('La cantidad debe ser mayor a 0');
    }
    final hoy = ahora ?? DateTime.now();
    final inicioDeHoy = DateTime(hoy.year, hoy.month, hoy.day);
    if (caducidad.isBefore(inicioDeHoy)) {
      throw ArgumentError('La fecha de caducidad ya pasó');
    }
    if (puntoEntregaId.trim().isEmpty) {
      throw ArgumentError('El punto de entrega es obligatorio');
    }
  }

  /// Copia con cambios, util para reservar o marcar como entregada.
  Donacion copyWith({
    EstadoDonacion? estado,
    String? asociacionId,
    DateTime? reservadaEn,
    DateTime? entregadaEn,
    String? fotoUrl,
  }) {
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
      reservadaEn: reservadaEn ?? this.reservadaEn,
      entregadaEn: entregadaEn ?? this.entregadaEn,
      fotoUrl: fotoUrl ?? this.fotoUrl,
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
      reservadaEn: switch (map['reservadaEn']) {
        final String fecha => DateTime.parse(fecha),
        _ => null,
      },
      entregadaEn: switch (map['entregadaEn']) {
        final String fecha => DateTime.parse(fecha),
        _ => null,
      },
      fotoUrl: switch (map['fotoUrl']) {
        final String url when url.trim().isNotEmpty => url.trim(),
        _ => null,
      },
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
        'reservadaEn': reservadaEn?.toIso8601String(),
        'entregadaEn': entregadaEn?.toIso8601String(),
        'fotoUrl': fotoUrl,
      };
}
