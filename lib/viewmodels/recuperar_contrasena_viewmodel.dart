import 'package:flutter/foundation.dart';
import '../core/utilidades/validadores.dart';
import '../repositories/usuario_repository.dart';
import '../services/auth_service.dart';
import 'estado_ui.dart';

/// Pantalla "Olvide mi contrasena" (T37): pide a Firebase que mande el
/// correo con el enlace para crear una contrasena nueva.
class RecuperarContrasenaViewModel extends ChangeNotifier {
  RecuperarContrasenaViewModel(this._repo);

  final UsuarioRepository _repo;

  EstadoUI estado = EstadoUI.inicial;
  String? mensajeError;

  /// Correo al que se mando el enlace, para mostrarlo en la confirmacion.
  String? correoEnviado;

  bool get enviando => estado == EstadoUI.cargando;
  bool get enviado => estado == EstadoUI.listo;

  /// Devuelve true si el correo se envio.
  Future<bool> enviar(String correo) async {
    correo = correo.trim();
    final invalido = Validadores.correo(correo);
    if (invalido != null) return _fallar(invalido);

    estado = EstadoUI.cargando;
    mensajeError = null;
    notifyListeners();
    try {
      await _repo.recuperarContrasena(correo);
      correoEnviado = correo;
      estado = EstadoUI.listo;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      return _fallar(e.mensaje);
    } catch (_) {
      return _fallar(
          'No se pudo enviar el correo. Revisa tu conexión e intenta de nuevo');
    }
  }

  /// Regresa al formulario para escribir otro correo o reenviar.
  void escribirOtraVez() {
    estado = EstadoUI.inicial;
    mensajeError = null;
    notifyListeners();
  }

  bool _fallar(String mensaje) {
    mensajeError = mensaje;
    estado = EstadoUI.error;
    notifyListeners();
    return false;
  }
}
