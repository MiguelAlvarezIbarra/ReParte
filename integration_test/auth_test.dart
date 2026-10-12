import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reparte/firebase_options.dart';
import 'package:reparte/models/usuario.dart';
import 'package:reparte/repositories/usuario_repository.dart';
import 'package:reparte/services/auth_service.dart';
import 'package:reparte/services/firestore_service.dart';
import 'package:reparte/viewmodels/estado_ui.dart';
import 'package:reparte/viewmodels/login_viewmodel.dart';

/// Prueba el inicio de sesion contra el proyecto real de Firebase.
/// Ejecutar con un telefono conectado:
///   flutter test integration_test/auth_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const correo = 'prueba.donante@reparte.mx';
  const contrasena = 'reparte123';

  late LoginViewModel vm;

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    vm = LoginViewModel(
      UsuarioRepository(auth: AuthService(), firestore: FirestoreService()),
    );
    // La cuenta de prueba se crea solo la primera vez.
    await vm.registrar(
      nombre: 'Donante de prueba',
      correo: correo,
      contrasena: contrasena,
      rol: RolUsuario.donante,
    );
    await vm.cerrarSesion();
  });

  testWidgets('un usuario valido entra con su rol', (_) async {
    final ok = await vm.iniciarSesion(correo, contrasena);

    expect(ok, isTrue, reason: vm.mensajeError);
    expect(vm.usuario?.correo, correo);
    expect(vm.usuario?.rol, RolUsuario.donante);
    await vm.cerrarSesion();
  });

  testWidgets('credenciales incorrectas muestran el mensaje de error',
      (_) async {
    final ok = await vm.iniciarSesion(correo, 'incorrecta');

    expect(ok, isFalse);
    expect(vm.estado, EstadoUI.error);
    expect(vm.mensajeError, 'Correo o contraseña incorrectos');
  });
}
