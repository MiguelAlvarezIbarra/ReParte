import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reparte/firebase_options.dart';

/// T36: comprueba contra Firebase real que las reglas de seguridad
/// rechazan lo que no se debe poder hacer, escribiendo directo en
/// Firestore como lo haria alguien que se salta la app.
///
/// Se usan dos conexiones a la vez: la del donante y la de la asociacion.
/// Ejecutar con un telefono conectado:
///   flutter test integration_test/reglas_seguridad_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FirebaseFirestore dbDonante;
  late FirebaseFirestore dbAsociacion;
  late String donanteId;
  late String asociacionId;

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final otra = await Firebase.initializeApp(
      name: 'asociacion_reglas',
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final authDonante = FirebaseAuth.instance;
    final authAsociacion = FirebaseAuth.instanceFor(app: otra);
    donanteId = (await authDonante.signInWithEmailAndPassword(
      email: 'prueba.donante@reparte.mx',
      password: 'reparte123',
    ))
        .user!
        .uid;
    asociacionId = (await authAsociacion.signInWithEmailAndPassword(
      email: 'prueba.asociacion@reparte.mx',
      password: 'reparte123',
    ))
        .user!
        .uid;
    dbDonante = FirebaseFirestore.instance;
    dbAsociacion = FirebaseFirestore.instanceFor(app: otra);

    // Seguro: si las reglas de T36 no estan publicadas, los abusos de abajo
    // si se guardarian y danarian las cuentas de prueba. Se prueba primero
    // con algo inofensivo (una asociacion creando un punto de entrega).
    try {
      final punto = await dbAsociacion.collection('puntos_entrega').add({
        'donanteId': asociacionId,
        'nombre': '[prueba de reglas T36]',
        'direccion': '',
        'latitud': 0,
        'longitud': 0,
        'horario': '',
      });
      await punto.delete();
      fail('Las reglas de T36 no están publicadas en Firebase. Publícalas con '
          '"firebase deploy --only firestore:rules" desde la rama de T36 '
          'antes de correr esta prueba.');
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') rethrow;
    }
  });

  tearDownAll(() => FirebaseAuth.instance.signOut());

  Map<String, dynamic> donacion(
    String duenoId, {
    String estado = 'disponible',
    num kilos = 2,
  }) =>
      {
        'donanteId': duenoId,
        'descripcion': '[prueba de reglas T36]',
        'cantidadKg': kilos,
        'caducidad':
            DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'puntoEntregaId': 'punto-prueba',
        'creadaEn': DateTime.now().toIso8601String(),
        'estado': estado,
        'asociacionId': null,
        'reservadaEn': null,
        'entregadaEn': null,
      };

  Future<void> rechazada(Future<Object?> escritura) => expectLater(
        escritura,
        throwsA(isA<FirebaseException>()
            .having((e) => e.code, 'code', 'permission-denied')),
      );

  Future<DocumentReference<Map<String, dynamic>>> publicar() =>
      dbDonante.collection('donaciones').add(donacion(donanteId));

  Map<String, dynamic> reserva(String quien) => {
        'estado': 'reservada',
        'asociacionId': quien,
        'reservadaEn': DateTime.now().toIso8601String(),
      };

  testWidgets('nadie puede cambiarse el rol', (_) async {
    await rechazada(dbDonante
        .collection('usuarios')
        .doc(donanteId)
        .update({'rol': 'asociacion'}));
    await rechazada(dbAsociacion
        .collection('usuarios')
        .doc(asociacionId)
        .update({'rol': 'donante'}));
  });

  testWidgets('solo un donante publica, a su nombre y con datos validos',
      (_) async {
    final donaciones = dbDonante.collection('donaciones');
    await rechazada(dbAsociacion
        .collection('donaciones')
        .add(donacion(asociacionId))); // una asociacion no publica
    await rechazada(donaciones.add(donacion(asociacionId))); // a nombre de otro
    await rechazada(donaciones.add(donacion(donanteId, estado: 'entregada')));
    await rechazada(donaciones.add(donacion(donanteId, kilos: -3)));
    await rechazada(donaciones.add(donacion(donanteId, kilos: 0)));
  });

  testWidgets('el ciclo de una donacion no se puede saltar', (_) async {
    final ref = await publicar();
    final comoAsociacion = dbAsociacion.collection('donaciones').doc(ref.id);

    // Un donante no puede reservar.
    await rechazada(ref.update(reserva(donanteId)));
    // La asociacion no puede reservar a nombre de otra ni cambiar otros datos.
    await rechazada(comoAsociacion.update(reserva('otra-asociacion')));
    await rechazada(
        comoAsociacion.update({...reserva(asociacionId), 'cantidadKg': 100}));

    // Reserva valida.
    await comoAsociacion.update(reserva(asociacionId));

    // El donante no puede quitar la reserva, cambiar la asociacion
    // ni cancelarla ya reservada.
    await rechazada(ref.update({'estado': 'disponible', 'asociacionId': null}));
    await rechazada(ref.update({'asociacionId': 'otra-asociacion'}));
    await rechazada(ref.update({'estado': 'cancelada'}));

    // Entrega valida y despues queda cerrada.
    await comoAsociacion.update({
      'estado': 'entregada',
      'entregadaEn': DateTime.now().toIso8601String(),
    });
    await rechazada(ref.update({'descripcion': 'cambiada despues'}));
    await rechazada(ref.delete());
  });

  testWidgets('el donante si puede corregir y cancelar la suya disponible',
      (_) async {
    final ref = await publicar();

    await ref.update({'descripcion': '[prueba de reglas T36] corregida'});
    await ref.update({'estado': 'cancelada'});

    final leida = await ref.get();
    expect(leida.data()?['estado'], 'cancelada');
  });
}
