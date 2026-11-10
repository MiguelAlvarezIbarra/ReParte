import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:reparte/services/auth_service.dart';
import 'package:reparte/viewmodels/estado_ui.dart';
import 'package:reparte/viewmodels/recuperar_contrasena_viewmodel.dart';

import 'login_viewmodel_test.mocks.dart';

void main() {
  late MockUsuarioRepository repo;
  late RecuperarContrasenaViewModel vm;

  setUp(() {
    repo = MockUsuarioRepository();
    vm = RecuperarContrasenaViewModel(repo);
  });

  test('pide el correo de recuperacion y recuerda a donde se mando', () async {
    when(repo.recuperarContrasena(any)).thenAnswer((_) async {});

    final ok = await vm.enviar('  laura@restaurante.mx ');

    expect(ok, isTrue);
    verify(repo.recuperarContrasena('laura@restaurante.mx')).called(1);
    expect(vm.enviado, isTrue);
    expect(vm.correoEnviado, 'laura@restaurante.mx');
    expect(vm.mensajeError, isNull);
  });

  test('con un correo invalido no llama a Firebase', () async {
    final ok = await vm.enviar('laura');

    expect(ok, isFalse);
    expect(vm.mensajeError, 'El correo no es válido');
    verifyNever(repo.recuperarContrasena(any));
  });

  test('muestra el mensaje del error de Firebase', () async {
    when(repo.recuperarContrasena(any))
        .thenThrow(const AuthException('Sin conexión a internet'));

    final ok = await vm.enviar('laura@restaurante.mx');

    expect(ok, isFalse);
    expect(vm.estado, EstadoUI.error);
    expect(vm.mensajeError, 'Sin conexión a internet');
  });

  test('ante un error inesperado pide revisar la conexion', () async {
    when(repo.recuperarContrasena(any)).thenThrow(Exception('falla'));

    await vm.enviar('laura@restaurante.mx');

    expect(vm.mensajeError, contains('Revisa tu conexión'));
  });

  test('se puede volver al formulario para reenviar', () async {
    when(repo.recuperarContrasena(any)).thenAnswer((_) async {});
    await vm.enviar('laura@restaurante.mx');

    vm.escribirOtraVez();

    expect(vm.enviado, isFalse);
    expect(vm.estado, EstadoUI.inicial);
  });
}
