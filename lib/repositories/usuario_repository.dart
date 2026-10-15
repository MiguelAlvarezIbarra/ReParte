import '../core/constantes/colecciones.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// Maneja la sesion del usuario y su perfil con rol.
/// Une Firebase Auth (cuenta) con Firestore (perfil en "usuarios").
class UsuarioRepository {
  UsuarioRepository({
    required AuthService auth,
    required FirestoreService firestore,
  })  : _auth = auth,
        _firestore = firestore;

  final AuthService _auth;
  final FirestoreService _firestore;

  /// Crea la cuenta y guarda su perfil con el rol elegido.
  Future<Usuario> registrar({
    required String nombre,
    required String correo,
    required String contrasena,
    required RolUsuario rol,
  }) async {
    final uid = await _auth.registrar(correo, contrasena);
    final usuario = Usuario(id: uid, nombre: nombre, correo: correo, rol: rol);
    await _firestore.guardarDocumento(
      Colecciones.usuarios,
      uid,
      usuario.toMap(),
    );
    return usuario;
  }

  /// Inicia sesion y devuelve el perfil del usuario.
  Future<Usuario> iniciarSesion(String correo, String contrasena) async {
    final uid = await _auth.iniciarSesion(correo, contrasena);
    final usuario = await obtenerPerfil(uid);
    if (usuario == null) {
      await _auth.cerrarSesion();
      throw const AuthException('No se encontró el perfil de esta cuenta');
    }
    return usuario;
  }

  /// Perfil del usuario con sesion activa, o null si no hay sesion.
  Future<Usuario?> usuarioActual() async {
    final uid = _auth.uidActual;
    if (uid == null) return null;
    return obtenerPerfil(uid);
  }

  Future<Usuario?> obtenerPerfil(String uid) async {
    final datos = await _firestore.leerDocumento(Colecciones.usuarios, uid);
    return datos == null ? null : Usuario.fromMap(uid, datos);
  }

  Future<void> cerrarSesion() => _auth.cerrarSesion();
}
