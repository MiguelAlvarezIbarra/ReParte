import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:reparte/core/tema/tema_app.dart';
import 'package:reparte/models/punto_entrega.dart';
import 'package:reparte/models/ruta.dart';
import 'package:reparte/services/rutas_service.dart';
import 'package:reparte/services/ubicacion_service.dart';
import 'package:reparte/viewmodels/estado_ui.dart';
import 'package:reparte/viewmodels/ruta_viewmodel.dart';
import 'package:reparte/views/mapa/ruta_view.dart';

import '../fakes/ubicacion_service_falso.dart';

const _origen = (latitud: 21.1561, longitud: -100.9346);
const _destino = (latitud: 21.1600, longitud: -100.9300);

const _punto = PuntoEntrega(
  id: 'p1',
  donanteId: 'd1',
  nombre: 'Panadería La Espiga',
  direccion: 'Calle Hidalgo 12',
  latitud: 21.1600,
  longitud: -100.9300,
);

/// Respuesta de OSRM con el mismo formato que devuelve el servidor real.
String _respuestaOsrm() => jsonEncode({
      'code': 'Ok',
      'routes': [
        {
          'distance': 1234.5,
          'duration': 290.0,
          'geometry': {
            'type': 'LineString',
            'coordinates': [
              [-100.9346, 21.1561],
              [-100.9320, 21.1580],
              [-100.9300, 21.1600],
            ],
          },
        },
      ],
    });

class _RutasFalsas implements RutasService {
  _RutasFalsas({this.falla = false});

  bool falla;
  Coordenada? origenPedido;

  @override
  Future<Ruta> calcular(Coordenada origen, Coordenada destino) async {
    origenPedido = origen;
    if (falla) throw const RutaNoDisponible();
    return OsrmRutasService.leerRespuesta(_respuestaOsrm());
  }
}

void main() {
  group('Ruta', () {
    test('muestra la distancia en metros o kilometros', () {
      const corta =
          Ruta(trazo: [], distanciaMetros: 850, duracionSegundos: 120);
      const larga =
          Ruta(trazo: [], distanciaMetros: 3420, duracionSegundos: 4500);

      expect(corta.distanciaTexto, '850 m');
      expect(larga.distanciaTexto, '3.4 km');
      expect(corta.duracionTexto, '2 min');
      expect(larga.duracionTexto, '1 h 15 min');
    });
  });

  group('OsrmRutasService', () {
    test('arma la consulta con longitud,latitud como pide OSRM', () {
      final uri = OsrmRutasService().consulta(_origen, _destino);

      expect(uri.host, 'router.project-osrm.org');
      expect(uri.path, '/route/v1/driving/-100.9346,21.1561;-100.93,21.16');
      expect(uri.queryParameters['geometries'], 'geojson');
      expect(uri.queryParameters['overview'], 'full');
    });

    test('convierte la respuesta en trazo, distancia y tiempo', () async {
      final servicio = OsrmRutasService(
        cliente: MockClient((_) async => http.Response(_respuestaOsrm(), 200)),
      );

      final ruta = await servicio.calcular(_origen, _destino);

      expect(ruta.trazo, hasLength(3));
      expect(ruta.trazo.first.latitud, 21.1561);
      expect(ruta.trazo.first.longitud, -100.9346);
      expect(ruta.distanciaTexto, '1.2 km');
      expect(ruta.duracionTexto, '5 min');
    });

    test('sin camino o con error del servidor lanza RutaNoDisponible',
        () async {
      final sinCamino = OsrmRutasService(
        cliente: MockClient((_) async =>
            http.Response(jsonEncode({'code': 'NoRoute', 'routes': []}), 200)),
      );
      final caido = OsrmRutasService(
        cliente: MockClient((_) async => http.Response('', 503)),
      );
      final sinRed = OsrmRutasService(
        cliente: MockClient((_) async => throw Exception('sin conexion')),
      );

      for (final s in [sinCamino, caido, sinRed]) {
        await expectLater(
          s.calcular(_origen, _destino),
          throwsA(isA<RutaNoDisponible>()),
        );
      }
    });
  });

  group('RutaViewModel', () {
    test('calcula la ruta desde la ubicacion de la asociacion', () async {
      final rutas = _RutasFalsas();
      final vm = RutaViewModel(
        destino: _punto,
        ubicacion: UbicacionServiceFalso(),
        rutas: rutas,
      );

      await vm.cargar();

      expect(vm.estado, EstadoUI.listo);
      expect(rutas.origenPedido, _origen);
      expect(vm.ruta?.trazo, hasLength(3));
    });

    test('sin permiso de ubicacion pide activarla', () async {
      final vm = RutaViewModel(
        destino: _punto,
        ubicacion: UbicacionServiceFalso(permisoConcedido: false),
        rutas: _RutasFalsas(),
      );

      await vm.cargar();

      expect(vm.estado, EstadoUI.error);
      expect(vm.mensajeError, contains('Activa tu ubicación'));
    });

    test('si no se puede calcular avisa de la conexion', () async {
      final vm = RutaViewModel(
        destino: _punto,
        ubicacion: UbicacionServiceFalso(),
        rutas: _RutasFalsas(falla: true),
      );

      await vm.cargar();

      expect(vm.estado, EstadoUI.error);
      expect(vm.mensajeError, contains('Revisa tu conexión'));
    });
  });

  testWidgets('la pantalla de ruta muestra el error y permite reintentar',
      (tester) async {
    final rutas = _RutasFalsas(falla: true);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<UbicacionService>.value(value: UbicacionServiceFalso()),
          Provider<RutasService>.value(value: rutas),
        ],
        child: MaterialApp(
          theme: TemaApp.claro,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => RutaView.abrir(context, _punto),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Ruta al punto de entrega'), findsOneWidget);
    expect(find.textContaining('No se pudo calcular la ruta'), findsOneWidget);

    await tester.tap(find.text('Intentar de nuevo'));
    await tester.pumpAndSettle();
    expect(rutas.origenPedido, _origen);
  });
}
