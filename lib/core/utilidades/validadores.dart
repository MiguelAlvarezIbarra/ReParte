/// Validaciones de formularios. Devuelven el mensaje de error o null si
/// el valor es valido, como lo espera TextFormField.validator.
class Validadores {
  static final _formatoCorreo = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? correo(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Escribe tu correo';
    if (!_formatoCorreo.hasMatch(texto)) return 'El correo no es válido';
    return null;
  }

  static String? contrasena(String? valor) {
    if (valor == null || valor.isEmpty) return 'Escribe tu contraseña';
    return null;
  }

  /// Para crear cuenta: Firebase exige al menos 6 caracteres.
  static String? contrasenaNueva(String? valor) {
    final error = contrasena(valor);
    if (error != null) return error;
    if (valor!.length < 6) return 'Usa al menos 6 caracteres';
    return null;
  }

  static String? requerido(String? valor, String campo) {
    if (valor == null || valor.trim().isEmpty) return 'Escribe tu $campo';
    return null;
  }

  /// Campo de texto que no puede ir vacio, con el mensaje que se le muestre.
  static String? obligatorio(String? valor, String mensaje) {
    if (valor == null || valor.trim().isEmpty) return mensaje;
    return null;
  }

  /// Convierte lo escrito a kilogramos; acepta coma o punto decimal.
  /// Devuelve null si no es un numero.
  static double? parsearCantidad(String? valor) {
    return double.tryParse((valor ?? '').trim().replaceAll(',', '.'));
  }

  static String? cantidadKg(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Escribe la cantidad';
    final cantidad = parsearCantidad(valor);
    if (cantidad == null || cantidad.isNaN || !cantidad.isFinite) {
      return 'Escribe un número válido';
    }
    if (cantidad <= 0) return 'La cantidad debe ser mayor a 0';
    return null;
  }

  /// La fecha de caducidad es obligatoria y no puede ser anterior a hoy.
  /// [ahora] solo existe para poder probarlo con una fecha fija.
  static String? caducidad(DateTime? fecha, {DateTime? ahora}) {
    if (fecha == null) return 'Elige la fecha de caducidad';
    final hoy = ahora ?? DateTime.now();
    final inicioDeHoy = DateTime(hoy.year, hoy.month, hoy.day);
    if (fecha.isBefore(inicioDeHoy)) return 'Esa fecha ya pasó';
    return null;
  }
}
