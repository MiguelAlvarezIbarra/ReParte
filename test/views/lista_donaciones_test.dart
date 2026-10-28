import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:reparte/core/tema/tema_app.dart';
import 'package:reparte/repositories/donacion_repository.dart';
import 'package:reparte/repositories/usuario_repository.dart';
import 'package:reparte/views/donaciones/lista_donaciones.dart';

import '../fakes/donacion_repository_falso.dart';
import '../viewmodels/login_viewmodel_test.mocks.dart';

void main() {
  late DonacionRepositoryFalso repo;

  setUp(() => repo = DonacionRepositoryFalso());

  Future<void> abrirLista(WidgetTester tester) {
    final usuarios = MockUsuarioRepository();
    when(usuarios.obtenerPerfil('d1')).thenAnswer((_) async => donanteDePrueba);
    repo.punto = puntoDePrueba;
    return tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<DonacionRepository>.value(value: repo),
          Provider<UsuarioRepository>.value(value: usuarios),
        ],
        child: MaterialApp(
          theme: TemaApp.claro,
          home: const Scaffold(body: ListaDonaciones()),
        ),
      ),
    );
  }

  testWidgets('mientras carga muestra un indicador', (tester) async {
    await abrirLista(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('muestra las donaciones con cantidad y fecha de caducidad',
      (tester) async {
    await abrirLista(tester);

    repo.emitir([donacionDePrueba('a', descripcion: 'Pan', cantidadKg: 2.5)]);
    await tester.pump();

    expect(find.text('Pan'), findsOneWidget);
    expect(find.text('2.5 kg'), findsOneWidget);
    expect(find.textContaining('Caduca el'), findsOneWidget);
  });

  testWidgets('las muestra ordenadas: primero la que caduca antes',
      (tester) async {
    await abrirLista(tester);

    repo.emitir([
      donacionDePrueba('b', descripcion: 'Verduras', dias: 4),
      donacionDePrueba('a', descripcion: 'Pan', dias: 1),
    ]);
    await tester.pump();

    final pan = tester.getTopLeft(find.text('Pan')).dy;
    final verduras = tester.getTopLeft(find.text('Verduras')).dy;
    expect(pan, lessThan(verduras));
  });

  testWidgets('se actualiza solo cuando llega una donacion nueva',
      (tester) async {
    await abrirLista(tester);
    repo.emitir([donacionDePrueba('a', descripcion: 'Pan')]);
    await tester.pump();
    expect(find.text('Tortillas'), findsNothing);

    repo.emitir([
      donacionDePrueba('a', descripcion: 'Pan'),
      donacionDePrueba('b', descripcion: 'Tortillas'),
    ]);
    await tester.pump();

    expect(find.text('Tortillas'), findsOneWidget);
  });

  testWidgets('al tocar una donacion abre su detalle', (tester) async {
    await abrirLista(tester);
    repo.emitir([
      donacionDePrueba('a', descripcion: 'Pan'),
      donacionDePrueba('b', descripcion: 'Verduras', dias: 4),
    ]);
    await tester.pump();

    await tester.tap(find.text('Verduras'));
    await tester.pumpAndSettle();

    expect(find.text('Detalle de la donación'), findsOneWidget);
    expect(find.text('Verduras'), findsOneWidget);
    expect(find.text('La Espiga'), findsOneWidget);
    expect(find.text('Panaderia Central'), findsOneWidget);
  });

  testWidgets('sin donaciones muestra el mensaje vacio', (tester) async {
    await abrirLista(tester);

    repo.emitir([]);
    await tester.pump();

    expect(find.text('No hay donaciones disponibles'), findsOneWidget);
  });

  testWidgets('si falla la carga muestra el mensaje de error', (tester) async {
    await abrirLista(tester);

    repo.fallar();
    await tester.pump();

    expect(find.text('No se pudieron cargar las donaciones'), findsOneWidget);
  });
}
