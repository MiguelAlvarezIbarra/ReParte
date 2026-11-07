import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:reparte/core/tema/tema_app.dart';
import 'package:reparte/models/donacion.dart';
import 'package:reparte/repositories/donacion_repository.dart';
import 'package:reparte/services/conectividad_service.dart';
import 'package:reparte/viewmodels/mis_donaciones_viewmodel.dart';
import 'package:reparte/views/donaciones/lista_donaciones.dart';
import 'package:reparte/views/donaciones/mis_donaciones_view.dart';
import 'package:reparte/widgets/aviso_sin_conexion.dart';

import '../fakes/donacion_repository_falso.dart';

/// Falla la primera vez que se consulta y despues responde bien,
/// como cuando regresa la conexion.
class _FallaUnaVez extends DonacionRepositoryFalso {
  int consultas = 0;

  Stream<List<Donacion>> _responder(List<Donacion> lista) {
    consultas++;
    if (consultas == 1) return Stream.error(Exception('sin conexion'));
    return Stream.value(lista);
  }

  @override
  Stream<List<Donacion>> observarDisponibles() =>
      _responder([donacionDePrueba('a', descripcion: 'Pan del dia')]);

  @override
  Stream<List<Donacion>> observarDeDonante(String donanteId) =>
      _responder([donacionDePrueba('b', descripcion: 'Bolillos')]);
}

class _ConectividadFalsa implements ConectividadService {
  final controlador = StreamController<bool>();

  @override
  Stream<bool> get enLinea => controlador.stream;
}

void main() {
  Future<void> abrir(
      WidgetTester tester, Widget pantalla, DonacionRepository repo) async {
    await tester.pumpWidget(
      Provider<DonacionRepository>.value(
        value: repo,
        child: MaterialApp(
          theme: TemaApp.claro,
          home: Scaffold(body: pantalla),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('si la lista no carga se puede reintentar', (tester) async {
    final repo = _FallaUnaVez();
    await abrir(tester, const ListaDonaciones(), repo);

    expect(find.text('No se pudieron cargar las donaciones'), findsOneWidget);
    expect(find.textContaining('Revisa tu conexión'), findsOneWidget);

    await tester.tap(find.text('Intentar de nuevo'));
    await tester.pumpAndSettle();

    expect(find.text('Pan del dia'), findsOneWidget);
    expect(repo.consultas, 2);
  });

  testWidgets('si Mis donaciones no carga se puede reintentar', (tester) async {
    final repo = _FallaUnaVez();
    await abrir(
      tester,
      const MisDonacionesView(usuarioId: 'd1', dueno: DuenoLista.donante),
      repo,
    );

    expect(find.text('No se pudieron cargar tus donaciones'), findsOneWidget);

    await tester.tap(find.text('Intentar de nuevo'));
    await tester.pumpAndSettle();

    expect(find.text('Bolillos'), findsOneWidget);
  });

  testWidgets('avisa cuando el telefono se queda sin red y cuando vuelve',
      (tester) async {
    final red = _ConectividadFalsa();
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro,
        builder: (context, pantalla) =>
            AvisoSinConexion(conectividad: red, child: pantalla!),
        home: const Scaffold(body: Text('Inicio')),
      ),
    );
    expect(find.textContaining('Sin conexión'), findsNothing);

    red.controlador.add(false);
    await tester.pump();
    expect(find.textContaining('Sin conexión a internet'), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);

    red.controlador.add(true);
    await tester.pumpAndSettle();
    expect(find.textContaining('Sin conexión'), findsNothing);
  });
}
