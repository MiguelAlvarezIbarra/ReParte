import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:reparte/core/tema/tema_app.dart';
import 'package:reparte/services/ubicacion_service.dart';
import 'package:reparte/views/mapa/seleccionar_ubicacion_view.dart';

import '../fakes/ubicacion_service_falso.dart';

void main() {
  late UbicacionServiceFalso servicio;
  ResultadoUbicacion? resultado;

  setUp(() {
    servicio = UbicacionServiceFalso();
    resultado = null;
  });

  Future<void> abrirMapa(
    WidgetTester tester, {
    bool desdeProvider = false,
  }) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      Provider<UbicacionService>.value(
        value: servicio,
        child: MaterialApp(
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
                      ubicacionService: desdeProvider ? null : servicio,
                    );
                  },
                  child: const Text('abrir mapa'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir mapa'));
    await tester.pumpAndSettle();
  }

  testWidgets('muestra el mapa, atribucion de OSM y controles de confirmacion',
      (tester) async {
    await abrirMapa(tester);

    expect(find.byKey(const Key('mapa_osm_view')), findsOneWidget);
    expect(find.byKey(const Key('boton_mi_ubicacion_mapa')), findsOneWidget);
    expect(
        find.byKey(const Key('boton_confirmar_ubicacion_mapa')), findsOneWidget);
    expect(find.text('Elegir punto en el mapa'), findsOneWidget);
    expect(find.text('OpenStreetMap contributors'), findsOneWidget);
  });

  testWidgets('el boton Mi ubicacion consulta el servicio de GPS',
      (tester) async {
    await abrirMapa(tester);

    await tester.tap(find.byKey(const Key('boton_mi_ubicacion_mapa')));
    await tester.pumpAndSettle();

    expect(servicio.llamadasObtenerUbicacion, 1);
    expect(servicio.llamadasSolicitarPermiso, 1);
  });

  testWidgets('toma UbicacionService del Provider si no se pasa directo (T26)',
      (tester) async {
    await abrirMapa(tester, desdeProvider: true);

    await tester.tap(find.byKey(const Key('boton_mi_ubicacion_mapa')));
    await tester.pumpAndSettle();

    expect(servicio.llamadasObtenerUbicacion, 1);
    expect(servicio.llamadasSolicitarPermiso, 1);
  });

  testWidgets('sin permiso de GPS muestra aviso en SnackBar (T26)',
      (tester) async {
    servicio.permisoConcedido = false;
    await abrirMapa(tester);

    await tester.tap(find.byKey(const Key('boton_mi_ubicacion_mapa')));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('No se pudo obtener tu ubicación actual'),
      findsOneWidget,
    );
  });

  testWidgets('confirmar punto devuelve las coordenadas y direccion seleccionadas',
      (tester) async {
    await abrirMapa(tester);

    await tester.tap(find.byKey(const Key('boton_confirmar_ubicacion_mapa')));
    await tester.pumpAndSettle();

    expect(resultado, isNotNull);
    expect(resultado!.latitud, 21.1561);
    expect(resultado!.longitud, -100.9346);
    expect(resultado!.direccion, 'Calle Hidalgo 12, Dolores Hidalgo');
  });
}
