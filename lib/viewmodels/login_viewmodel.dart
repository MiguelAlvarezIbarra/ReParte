import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../repositories/usuario_repository.dart';
import '../services/auth_service.dart';
import 'estado_ui.dart';

/// Cerebro de las pantallas de inicio de sesion y registro.
/// La vista solo lee [estado], [mensajeError] y [usuario].
class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._repo);

  final UsuarioRepository _repo;

  EstadoUI estado = EstadoUI.inicial;
  String? mensajeError;
  Usuario? usuario;

  bool get cargando => estado == EstadoUI.cargando;

  /// Devuelve true si la sesion se inicio correctamente.
  Future<bool> iniciarSesion(String correo, String contrasena) async {
    correo = correo.trim();
    if (correo.isEmpty || contrasena.isEmpty) {
      return _fallar('Escribe tu correo y tu contraseña');
    }
    return _ejecutar(() => _repo.iniciarSesion(correo, contrasena));
  }

  /// Devuelve true si la cuenta se creo correctamente.
  Future<bool> registrar({
    required String nombre,
    required String correo,
    required String contrasena,
    required RolUsuario rol,
  }) async {
    nombre = nombre.trim();
    correo = correo.trim();
    if (nombre.isEmpty || correo.isEmpty || contrasena.isEmpty) {
      return _fallar('Completa todos los campos');
    }
    return _ejecutar(() => _repo.registrar(
          nombre: nombre,
          correo: correo,
          contrasena: contrasena,
          rol: rol,
        ));
  }

  Future<void> cerrarSesion() async {
    await _repo.cerrarSesion();
    usuario = null;
    estado = EstadoUI.inicial;
    notifyListeners();
  }

  Future<bool> _ejecutar(Future<Usuario> Function() accion) async {
    estado = EstadoUI.cargando;
    mensajeError = null;
    notifyListeners();
    try {
      usuario = await accion();
      estado = EstadoUI.listo;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      return _fallar(e.mensaje);
    } catch (_) {
      return _fallar('Ocurrió un error inesperado. Intenta de nuevo');
    }
  }

  bool _fallar(String mensaje) {
    mensajeError = mensaje;
    estado = EstadoUI.error;
    notifyListeners();
    return false;
  }
}
