import '../../models/donacion.dart';

/// Textos con formato para mostrar en pantalla.
class Formato {
  /// 05/11/2026
  static String fecha(DateTime f) =>
      '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';

  /// "3 kg" si es entero, "2.5 kg" si trae decimales.
  static String kilos(double kg) {
    final texto = kg == kg.roundToDouble() ? kg.toInt().toString() : kg.toString();
    return '$texto kg';
  }

  /// Nombre del estado de una donacion, listo para mostrar.
  static String estado(EstadoDonacion estado) {
    switch (estado) {
      case EstadoDonacion.disponible:
        return 'Disponible';
      case EstadoDonacion.reservada:
        return 'Reservada';
      case EstadoDonacion.entregada:
        return 'Entregada';
      case EstadoDonacion.cancelada:
        return 'Cancelada';
    }
  }
}
