import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reparte/firebase_options.dart';
import 'package:reparte/main.dart';
import 'package:reparte/repositories/donacion_repository.dart';
import 'package:reparte/services/auth_service.dart';
import 'package:reparte/services/firestore_service.dart';
import 'package:reparte/services/notificaciones_service.dart';

import 'cuentas_prueba.dart';

/// T25: recorre las seis historias del PMV (H1 a H6) en un telefono real,
/// tocando la app como lo haria una persona, contra Firebase real.
///
/// La app del telefono hace de donante y luego de asociacion. Para H5 hace
/// falta que otra persona reserve mientras el donante tiene la app abierta:
/// eso lo hace un "segundo telefono", que es otra conexion a Firebase con la
/// cuenta de la asociacion.
///
/// Con capturas de pantalla (se guardan en docs/pruebas/capturas):
///   flutter drive --driver=test_driver/integration_test.dart --dart-define-from-file=pruebas.env.json
///     --target=integration_test/flujo_completo_test.dart
const _donante = CuentasPrueba.correoDonante;
const _asociacion = CuentasPrueba.correoAsociacion;
const _contrasena = CuentasPrueba.contrasena;

/// Usa las notificaciones reales y ademas anota cuales se mostraron.
class _NotificacionesAnotadas implements NotificacionesService {
  final _real = LocalNotificacionesService();
  final mostradas = <({String titulo, String mensaje})>[];

  @override
  Future<void> inicializar() => _real.inicializar();

  @override
  Future<void> mostrar({
    required int id,
    required String titulo,
    required String mensaje,
  }) async {
    mostradas.add((titulo: titulo, mensaje: mensaje));
    await _real.mostrar(id: id, titulo: titulo, mensaje: mensaje);
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('flujo completo de una donacion, de H1 a H6', (tester) async {
    CuentasPrueba.verificar();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAuth.instance.signOut();

    // El segundo telefono: otra sesion de Firebase, independiente de la app.
    final otraApp = await Firebase.initializeApp(
      name: 'segundo_telefono',
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final otroAuth = AuthService(auth: FirebaseAuth.instanceFor(app: otraApp));
    final otroRepo = DonacionRepository(
      firestore:
          FirestoreService(db: FirebaseFirestore.instanceFor(app: otraApp)),
    );

    final marca = 'T25-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final descA = 'Pan dulce del día ($marca)';
    final descB = 'Fruta y verdura ($marca)';

    // ---- Utilidades ----
    Future<void> esperar(Finder f, {int segundos = 30}) async {
      final limite = DateTime.now().add(Duration(seconds: segundos));
      while (DateTime.now().isBefore(limite)) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        await tester.pump();
        if (f.evaluate().isNotEmpty) return;
      }
      throw TestFailure('No apareció en pantalla: $f');
    }

    // Cualquier boton con ese texto (FilledButton.icon es una subclase).
    Finder boton(String texto) => find.ancestor(
          of: find.text(texto),
          matching: find.bySubtype<ButtonStyleButton>(),
        );

    Future<void> pausa([int ms = 800]) async {
      await Future<void>.delayed(Duration(milliseconds: ms));
      await tester.pump();
    }

    var numero = 0;
    Future<void> captura(String nombre) async {
      await pausa(1200);
      numero++;
      await binding
          .takeScreenshot('${numero.toString().padLeft(2, '0')}_$nombre');
      debugPrint('EVIDENCIA captura $numero: $nombre');
    }

    Future<void> tocar(Finder f) async {
      await esperar(f);
      await tester.ensureVisible(f.first);
      await tester.pump();
      await tester.tap(f.first);
      await tester.pump();
    }

    Future<void> escribir(String etiqueta, String texto) async {
      final campo = find.widgetWithText(TextFormField, etiqueta);
      await tocar(campo);
      await tester.enterText(campo, texto);
      await tester.pump();
    }

    Future<void> iniciarSesion(String correo) async {
      await esperar(find.text('Entrar'));
      await escribir('Correo', correo);
      await escribir('Contraseña', _contrasena);
      await tocar(boton('Entrar'));
    }

    Future<void> cerrarSesion() async {
      await tocar(find.text('Perfil'));
      await tocar(find.text('Cerrar sesión'));
      await esperar(find.text('Entrar'));
    }

    Future<void> publicar(String descripcion, String kg,
        {bool conCaptura = false}) async {
      await tocar(boton('Publicar donación'));
      await esperar(find.text('Fecha de caducidad'));
      await escribir('Descripción', descripcion);
      await escribir('Cantidad (kg)', kg);
      await tocar(find.widgetWithText(TextFormField, 'Fecha de caducidad'));
      await tocar(find.text('OK'));
      await escribir('Nombre del punto de entrega', 'Panadería La Espiga');
      await escribir('Dirección', 'Av. Universidad 210, Dolores Hidalgo');
      FocusManager.instance.primaryFocus?.unfocus();
      await tocar(find.byKey(const Key('boton_elegir_en_mapa')));
      await tocar(find.byKey(const Key('boton_confirmar_ubicacion_mapa')));
      await esperar(find.textContaining('Coordenadas:'));
      if (conCaptura) await captura('h2_formulario_publicar');
      await tocar(boton('Publicar donación'));
      await esperar(find.text('Donación publicada'));
      await esperar(find.text(descripcion));
    }

    // ---- H1: inicio de sesion segun el rol ----
    final notificaciones = _NotificacionesAnotadas();
    await tester.pumpWidget(crearApp(notificaciones: notificaciones));
    await binding.convertFlutterSurfaceToImage();
    await esperar(find.text('Entrar'));
    await captura('h1_inicio_sesion');

    await iniciarSesion(_donante);
    await esperar(find.text('Mis donaciones'));
    expect(find.text('Donante'), findsWidgets);
    await captura('h1_inicio_donante');
    debugPrint('EVIDENCIA H1: el donante entra y ve su pantalla de inicio');

    // ---- H2: el donante publica dos donaciones ----
    await publicar(descA, '4', conCaptura: true);
    await publicar(descB, '6.5');
    await captura('h2_donaciones_publicadas');
    debugPrint('EVIDENCIA H2: se publicaron "$descA" y "$descB"');

    // ---- H5: otra asociacion reserva A y al donante le llega el aviso ----
    final otroAsociacionId =
        await otroAuth.iniciarSesion(_asociacion, _contrasena);
    final a = (await otroRepo
            .observarDisponibles()
            .firstWhere((l) => l.any((d) => d.descripcion == descA)))
        .firstWhere((d) => d.descripcion == descA);
    await otroRepo.reservar(a, otroAsociacionId);
    debugPrint('EVIDENCIA H5: el segundo telefono reservó "$descA"');

    final limite = DateTime.now().add(const Duration(seconds: 30));
    while (
        notificaciones.mostradas.isEmpty && DateTime.now().isBefore(limite)) {
      await pausa(250);
    }
    final aviso = notificaciones.mostradas.single;
    expect(aviso.titulo, '¡Reservaron tu donación!');
    expect(aviso.mensaje, contains(descA));
    expect(aviso.mensaje, contains('4 kg'));
    debugPrint(
        'EVIDENCIA H5: notificación "${aviso.titulo}" — ${aviso.mensaje}');
    await esperar(find.text('Reservada'));
    await captura('h5_donante_ve_reservada');
    await captura('h5_barra_de_notificaciones');
    await pausa(1500);

    // ---- H6: el donante entrega A y queda cerrada ----
    await tocar(find.text(descA));
    await tocar(boton('Marcar como entregada'));
    await tocar(find.text('Sí, se entregó'));
    await esperar(find.text('Donación entregada. ¡Gracias!'));
    await esperar(find.textContaining('Se rescataron 4 kg'));
    await captura('h6_donante_marca_entregada');
    debugPrint('EVIDENCIA H6: "$descA" quedó entregada');
    await tester.pageBack();
    await cerrarSesion();

    // ---- H1 con la asociacion, H3: ve la lista y el detalle ----
    await iniciarSesion(_asociacion);
    await esperar(find.text('Donaciones disponibles'));
    final buscador = find.byType(TextField).first;
    await tocar(buscador);
    await tester.enterText(buscador, marca);
    FocusManager.instance.primaryFocus?.unfocus();
    await esperar(find.text(descB));
    expect(find.text(descA), findsNothing,
        reason: 'la entregada ya no está disponible');
    await captura('h3_lista_disponibles');
    debugPrint('EVIDENCIA H3: la asociación ve "$descB" en la lista');

    await tocar(find.text(descB));
    await esperar(find.text('Detalle de la donación'));
    await esperar(find.text('Reservar donación'));
    await captura('h3_detalle_donacion');

    // ---- H4: reserva B; un segundo intento es rechazado ----
    final bVistaDisponible = (await otroRepo
            .observarDisponibles()
            .firstWhere((l) => l.any((d) => d.descripcion == descB)))
        .firstWhere((d) => d.descripcion == descB);
    await tocar(boton('Reservar donación'));
    await esperar(find.text('Seguir buscando'));
    await captura('h4_reserva_confirmada');
    debugPrint('EVIDENCIA H4: la asociación reservó "$descB" desde la app');

    await expectLater(
      otroRepo.reservar(bVistaDisponible, otroAsociacionId),
      throwsA(isA<DonacionNoDisponible>()),
    );
    debugPrint('EVIDENCIA H4: el segundo intento de reservar "$descB" '
        'fue rechazado (DonacionNoDisponible)');

    await tocar(find.text('Seguir buscando'));
    await tocar(find.text('Mis reservas'));
    await esperar(find.text(descB));
    await captura('h4_mis_reservas');

    // ---- H6: la asociacion confirma que recogio B ----
    await tocar(find.text(descB));
    await tocar(boton('Marcar como entregada'));
    await tocar(find.text('Sí, se entregó'));
    await esperar(find.textContaining('Se rescataron 6.5 kg'));
    await captura('h6_asociacion_marca_entregada');
    await tester.pageBack();
    await tocar(find.text('Historial'));
    await esperar(find.text(descB));
    await captura('h6_historial');
    debugPrint('EVIDENCIA H6: "$descB" quedó en el historial como entregada');

    await cerrarSesion();
    await otroAuth.cerrarSesion();
  }, timeout: const Timeout(Duration(minutes: 6)));
}
