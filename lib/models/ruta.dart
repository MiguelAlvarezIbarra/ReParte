/// Un punto geografico de una ruta.
typedef Coordenada = ({double latitud, double longitud});

/// Camino calculado entre dos puntos: el trazo para dibujarlo en el mapa,
/// la distancia y el tiempo aproximado en coche.
class Ruta {
  const Ruta({
    required this.trazo,
    required this.distanciaMetros,
    required this.duracionSegundos,
  });

  final List<Coordenada> trazo;
  final double distanciaMetros;
  final double duracionSegundos;

  /// "850 m" o "3.4 km".
  String get distanciaTexto {
    if (distanciaMetros < 1000) return '${distanciaMetros.round()} m';
    return '${(distanciaMetros / 1000).toStringAsFixed(1)} km';
  }

  /// "8 min" o "1 h 15 min".
  String get duracionTexto {
    final minutos = (duracionSegundos / 60).ceil().clamp(1, 1 << 30);
    if (minutos < 60) return '$minutos min';
    final horas = minutos ~/ 60;
    final resto = minutos % 60;
    return resto == 0 ? '$horas h' : '$horas h $resto min';
  }
}
