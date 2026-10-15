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
}
