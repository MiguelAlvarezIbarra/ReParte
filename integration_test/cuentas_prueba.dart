/// Cuentas de prueba para las pruebas contra Firebase real (T38).
///
/// Los valores NO estan en el repositorio: se leen del archivo local
/// `pruebas.env.json` (ignorado por git) al ejecutar, por ejemplo:
///   flutter test integration_test --dart-define-from-file=pruebas.env.json
///
/// Copia `pruebas.env.example.json` como `pruebas.env.json` y pide los
/// valores reales al equipo por un canal privado.
class CuentasPrueba {
  static const correoDonante = String.fromEnvironment('CORREO_DONANTE');
  static const correoAsociacion = String.fromEnvironment('CORREO_ASOCIACION');
  static const contrasena = String.fromEnvironment('CONTRASENA_PRUEBAS');

  /// Detiene la prueba con un mensaje claro si faltan los valores.
  static void verificar() {
    if (correoDonante.isEmpty ||
        correoAsociacion.isEmpty ||
        contrasena.isEmpty) {
      throw StateError(
        'Faltan las cuentas de prueba. Copia pruebas.env.example.json como '
        'pruebas.env.json, llena los valores y ejecuta con '
        '--dart-define-from-file=pruebas.env.json',
      );
    }
  }
}
