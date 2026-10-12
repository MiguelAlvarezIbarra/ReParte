import 'package:firebase_auth/firebase_auth.dart';

/// Error de autenticacion con un mensaje listo para mostrarse al usuario.
class AuthException implements Exception {
  const AuthException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Envoltura de Firebase Authentication.
/// Es la unica clase que conoce el SDK de Firebase Auth.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// Id del usuario con sesion activa, o null si no hay sesion.
  String? get uidActual => _auth.currentUser?.uid;

  /// Crea la cuenta y devuelve su id.
  Future<String> registrar(String correo, String contrasena) async {
    try {
      final credencial = await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );
      return credencial.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException(mensajeDeError(e.code));
    }
  }

  /// Inicia sesion y devuelve el id del usuario.
  Future<String> iniciarSesion(String correo, String contrasena) async {
    try {
      final credencial = await _auth.signInWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );
      return credencial.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException(mensajeDeError(e.code));
    }
  }

  Future<void> cerrarSesion() => _auth.signOut();

  /// Traduce los codigos de Firebase a mensajes en espanol.
  static String mensajeDeError(String codigo) {
    switch (codigo) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Correo o contraseña incorrectos';
      case 'invalid-email':
        return 'El correo no tiene un formato válido';
      case 'user-disabled':
        return 'Esta cuenta está deshabilitada';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera unos minutos';
      case 'network-request-failed':
        return 'Sin conexión a internet';
      default:
        return 'No se pudo completar la operación';
    }
  }
}
