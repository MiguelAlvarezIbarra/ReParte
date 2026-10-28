import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:reparte/core/tema/tema_app.dart';
import 'package:reparte/repositories/donacion_repository.dart';
import 'package:reparte/views/donaciones/publicar_donacion_view.dart';

import '../fakes/donacion_repository_falso.dart';

void main() {
  late DonacionRepositoryFalso repo;
  bool? resultado;

  setUp(() {
    repo = DonacionRepositoryFalso();
    resultado = null;
  });

  /// Abre el formulario desde un boton, como lo hace la pantalla del donante.
  Future<void> abrirFormulario(WidgetTester tester) async {
    // Pantalla alta para que todos los campos queden a la vista.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      Provider<DonacionRepository>.value(
        value: repo,
        child: MaterialApp(
          theme: TemaApp.claro,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () async {
                    resultado = await PublicarDonacionView.abrir(
                      context,
                      donanteId: 'd1',
                    );
                  },
                  child: const Text('abrir'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  Finder campo(String etiqueta) => find.widgetWithText(TextFormField, etiqueta);
  Finder botonPublicar() =>
      find.widgetWithText(FilledButton, 'Publicar donación');

  testWidgets('muestra los campos del formulario', (tester) async {
    await abrirFormulario(tester);

    expect(campo('Descripción'), findsOneWidget);
    expect(campo('Cantidad (kg)'), findsOneWidget);
    expect(campo('Fecha de caducidad'), findsOneWidget);
    expect(campo('Nombre del punto de entrega'), findsOneWidget);
    expect(campo('Dirección'), findsOneWidget);
    expect(botonPublicar(), findsOneWidget);
  });

  testWidgets('valida los campos vacios y no cierra el formulario',
      (tester) async {
    await abrirFormulario(tester);

    await tester.tap(botonPublicar());
    await tester.pump();

    expect(find.text('Describe qué vas a donar'), findsOneWidget);
    expect(find.text('Escribe la cantidad'), findsOneWidget);
    expect(find.text('Elige la fecha de caducidad'), findsOneWidget);
    expect(find.text('Escribe el nombre del punto de entrega'), findsOneWidget);
    expect(find.text('Escribe la dirección de entrega'), findsOneWidget);
    expect(botonPublicar(), findsOneWidget);
    expect(resultado, isNull);
  });

  testWidgets('rechaza una cantidad que no es numero', (tester) async {
    await abrirFormulario(tester);

    await tester.enterText(campo('Cantidad (kg)'), 'mucho');
    await tester.tap(botonPublicar());
    await tester.pump();

    expect(find.text('Escribe un número válido'), findsOneWidget);
  });

  Future<void> llenarFormulario(WidgetTester tester) async {
    await tester.enterText(campo('Descripción'), 'Pan del dia');
    await tester.enterText(campo('Cantidad (kg)'), '3,5');
    await tester.tap(campo('Fecha de caducidad'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.enterText(
        campo('Nombre del punto de entrega'), 'Panaderia La Espiga');
    await tester.enterText(campo('Dirección'), 'Calle Hidalgo 12');
  }

  testWidgets('con datos validos publica la donacion y se cierra',
      (tester) async {
    await abrirFormulario(tester);
    await llenarFormulario(tester);

    await tester.tap(botonPublicar());
    await tester.pumpAndSettle();

    // El formulario se cerro y la donacion quedo guardada.
    expect(botonPublicar(), findsNothing);
    expect(resultado, isTrue);
    final donacion = repo.creadas.single;
    expect(donacion.descripcion, 'Pan del dia');
    expect(donacion.cantidadKg, 3.5);
    expect(donacion.donanteId, 'd1');
    expect(donacion.caducidad.isAfter(DateTime.now()), isTrue);
    expect(repo.puntosCreados.single.nombre, 'Panaderia La Espiga');
    expect(repo.puntosCreados.single.direccion, 'Calle Hidalgo 12');
  });

  testWidgets('si falla al guardar muestra el error y no se cierra',
      (tester) async {
    repo.crearFalla = true;
    await abrirFormulario(tester);
    await llenarFormulario(tester);

    await tester.tap(botonPublicar());
    await tester.pumpAndSettle();

    expect(botonPublicar(), findsOneWidget);
    expect(find.textContaining('No se pudo publicar'), findsOneWidget);
    expect(resultado, isNull);
  });
}
