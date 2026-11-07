import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:reparte/models/donacion.dart';
import 'package:reparte/models/usuario.dart';
import 'package:reparte/services/notificaciones_service.dart';
import 'package:reparte/viewmodels/avisador_reservas.dart';

import '../fakes/donacion_repository_falso.dart';
import 'login_viewmodel_test.mocks.dart';

/// Repositorio cuyas donaciones del donante se emiten a mano.
class _RepoEnVivo extends DonacionRepositoryFalso {
  final delDonante = StreamController<List<Donacion>>();

  @override
  Stream<List<Donacion>> observarDeDonante(String donanteId) =>
      delDonante.stream;
}

class _NotificacionesFalsas implements NotificacionesService {
  final mostradas = <({String titulo, String mensaje})>[];

  @override
  Future<void> inicializar() async {}

  @override
  Future<void> mostrar({
    required int id,
    required String titulo,
    required String mensaje,
  }) async {
    mostradas.add((titulo: titulo, mensaje: mensaje));
  }
}

void main() {
  late _RepoEnVivo repo;
  late MockUsuarioRepository usuarios;
  late _NotificacionesFalsas notificaciones;
  late AvisadorReservas avisador;

  final disponible = donacionDePrueba('a', descripcion: 'Pan del dia');
  final reservada = disponible.copyWith(
      estado: EstadoDonacion.reservada, asociacionId: 'as1');

  Future<void> emitir(List<Donacion> lista) async {
    repo.delDonante.add(lista);
    await Future<void>.delayed(Duration.zero);
  }

  setUp(() {
    repo = _RepoEnVivo();
    usuarios = MockUsuarioRepository();
    notificaciones = _NotificacionesFalsas();
    when(usuarios.obtenerPerfil('as1')).thenAnswer((_) async => const Usuario(
          id: 'as1',
          nombre: 'Comedor San José',
          correo: 'ana@comedor.org',
          rol: RolUsuario.asociacion,
        ));
    avisador = AvisadorReservas(
      donaciones: repo,
      usuarios: usuarios,
      notificaciones: notificaciones,
      donanteId: 'd1',
    )..iniciar();
  });

  tearDown(() => avisador.detener());

  test('avisa al donante cuando reservan su donacion', () async {
    await emitir([disponible]);
    await emitir([reservada]);

    final aviso = notificaciones.mostradas.single;
    expect(aviso.titulo, '¡Reservaron tu donación!');
    expect(aviso.mensaje, contains('Comedor San José'));
    expect(aviso.mensaje, contains('Pan del dia'));
    expect(aviso.mensaje, contains('3 kg'));
  });

  test('no avisa de las que ya estaban reservadas al abrir la app', () async {
    await emitir([reservada]);
    await emitir([reservada]);

    expect(notificaciones.mostradas, isEmpty);
  });

  test('avisa una sola vez aunque la lista llegue varias veces', () async {
    await emitir([disponible]);
    await emitir([reservada]);
    await emitir([reservada]);

    expect(notificaciones.mostradas, hasLength(1));
  });

  test('no avisa al publicar ni al entregar', () async {
    await emitir([]);
    await emitir([disponible]);
    await emitir([
      reservada.copyWith(estado: EstadoDonacion.entregada),
    ]);

    expect(notificaciones.mostradas, isEmpty);
  });

  test('si no se puede leer la asociacion avisa sin su nombre', () async {
    when(usuarios.obtenerPerfil('as1')).thenThrow(Exception('sin conexion'));

    await emitir([disponible]);
    await emitir([reservada]);

    expect(notificaciones.mostradas.single.mensaje,
        startsWith('Una asociación reservó'));
  });
}
