import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:reparte/core/tema/tema_app.dart';
import 'package:reparte/core/utilidades/formato.dart';
import 'package:reparte/models/donacion.dart';
import 'package:reparte/repositories/donacion_repository.dart';
import 'package:reparte/views/donaciones/lista_donaciones.dart';
import 'package:reparte/widgets/encabezado_inicio.dart';
import 'package:reparte/widgets/ilustracion_alimento.dart';

import '../fakes/donacion_repository_falso.dart';

void main() {
  group('IlustracionAlimento.estilo', () {
    test('elige el icono segun la comida', () {
      expect(IlustracionAlimento.estilo('20 panes del dia').icono,
          Icons.bakery_dining_outlined);
      expect(IlustracionAlimento.estilo('Frutas y verduras').icono,
          Icons.eco_outlined);
      expect(IlustracionAlimento.estilo('Leche y yogur').icono,
          Icons.local_drink_outlined);
      expect(IlustracionAlimento.estilo('Comida corrida').icono,
          Icons.restaurant_outlined);
    });
  });

  test('Formato.esHoy compara solo el dia', () {
    final ahora = DateTime(2026, 11, 7, 10);
    expect(Formato.esHoy(DateTime(2026, 11, 7, 23, 59), ahora: ahora), isTrue);
    expect(Formato.esHoy(DateTime(2026, 11, 8), ahora: ahora), isFalse);
  });

  test('EncabezadoInicio.iniciales toma las dos primeras palabras', () {
    expect(EncabezadoInicio.iniciales('Panadería La Espiga'), 'PL');
    expect(EncabezadoInicio.iniciales('laura'), 'L');
    expect(EncabezadoInicio.iniciales('  '), '?');
  });

  testWidgets('la lista avisa cuantas donaciones caducan hoy', (tester) async {
    final hoy = DateTime.now();
    final repo = DonacionRepositoryFalso();
    await tester.pumpWidget(
      Provider<DonacionRepository>.value(
        value: repo,
        child: MaterialApp(
          theme: TemaApp.claro,
          home: const Scaffold(body: ListaDonaciones()),
        ),
      ),
    );
    repo.emitir([
      Donacion(
        id: 'a',
        donanteId: 'd1',
        descripcion: 'Pan',
        cantidadKg: 2,
        caducidad: DateTime(hoy.year, hoy.month, hoy.day, 23, 59),
        puntoEntregaId: 'p1',
        creadaEn: hoy,
      ),
      donacionDePrueba('b', descripcion: 'Verduras', dias: 3),
    ]);
    await tester.pump();

    expect(find.text('1 donación caduca hoy'), findsOneWidget);
    expect(find.text('Caduca hoy'), findsOneWidget);
  });
}
