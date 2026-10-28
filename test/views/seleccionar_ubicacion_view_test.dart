import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reparte/core/tema/tema_app.dart';
import 'package:reparte/views/mapa/seleccionar_ubicacion_view.dart';

import '../fakes/ubicacion_service_falso.dart';

void main() {
  late UbicacionServiceFalso servicio;
  ResultadoUbicacion? resultado;

  setUp(() {
    servicio = UbicacionServiceFalso();
    resultado = null;
  });

  Future<void> abrirMapa(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async {
                  resultado = await SeleccionarUbicacionView.abrir(
                    context,
                    latitudInicial: 21.1561,
                    longitudInicial: -100.9346,
                    ubicacionService: servicio,
                  );
                },
                child: const Text('abrir mapa'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir mapa'));
    await tester.pumpAndSettle();
  }

  testWidgets('muestra el mapa y los controles de confirmacion y GPS',
      (tester) async {
    await abrirMapa(tester);

    expect(find.byKey(const Key('mapa_osm_view')), findsOneWidget);
    expect(find.byKey(const Key('boton_mi_ubicacion_mapa')), findsOneWidget);
    expect(find.byKey(const Key('boton_confirmar_ubicacion_mapa')), findsOneWidget);
    expect(find.text('Elegir punto en el mapa'), findsOneWidget);
  });

  testWidgets('el boton Mi ubicacion consulta el servicio de GPS',
      (tester) async {
    await abrirMapa(tester);

    await tester.tap(find.byKey(const Key('boton_mi_ubicacion_mapa')));
    await tester.pumpAndSettle();

    expect(servicio.llamadasObtenerUbicacion, 1);
    expect(servicio.llamadasSolicitarPermiso, 1);
  });

  testWidgets('confirmar punto devuelve las coordenadas seleccionadas',
      (tester) async {
    await abrirMapa(tester);

    await tester.tap(find.byKey(const Key('boton_confirmar_ubicacion_mapa')));
    await tester.pumpAndSettle();

    expect(resultado, isNotNull);
    expect(resultado!.latitud, 21.1561);
    expect(resultado!.longitud, -100.9346);
  });
}
