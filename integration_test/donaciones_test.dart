import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reparte/core/constantes/colecciones.dart';
import 'package:reparte/firebase_options.dart';
import 'package:reparte/models/donacion.dart';
import 'package:reparte/models/punto_entrega.dart';
import 'package:reparte/repositories/donacion_repository.dart';
import 'package:reparte/services/auth_service.dart';
import 'package:reparte/services/firestore_service.dart';

/// Criterio de T12: una donacion creada desde la app aparece en Firestore
/// y se puede leer de vuelta. Ejecutar con un telefono conectado:
///   flutter test integration_test/donaciones_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AuthService auth;
  late FirestoreService firestore;
  late DonacionRepository repo;
  late String donanteId;

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    auth = AuthService();
    firestore = FirestoreService();
    repo = DonacionRepository(firestore: firestore);
    // Las reglas exigen sesion: se usa la cuenta de prueba del donante.
    donanteId =
        await auth.iniciarSesion('prueba.donante@reparte.mx', 'reparte123');
  });

  tearDownAll(() => auth.cerrarSesion());

  testWidgets('una donacion publicada se guarda y se lee de vuelta', (_) async {
    final puntoId = await repo.crearPuntoEntrega(PuntoEntrega(
      id: '',
      donanteId: donanteId,
      nombre: 'Punto de prueba',
      direccion: 'Av. Universidad 210',
      latitud: 0,
      longitud: 0,
    ));
    final donacion = Donacion(
      id: '',
      donanteId: donanteId,
      descripcion: '[prueba automatica] pan del dia',
      cantidadKg: 2.5,
      caducidad: DateTime.now().add(const Duration(days: 1)),
      puntoEntregaId: puntoId,
      creadaEn: DateTime.now(),
    );

    final id = await repo.crear(donacion);

    final disponibles = await repo
        .observarDisponibles()
        .firstWhere((lista) => lista.any((d) => d.id == id));
    final leida = disponibles.firstWhere((d) => d.id == id);
    expect(leida.descripcion, donacion.descripcion);
    expect(leida.cantidadKg, 2.5);
    expect(leida.puntoEntregaId, puntoId);

    final punto = await repo.obtenerPuntoEntrega(puntoId);
    expect(punto?.direccion, 'Av. Universidad 210');

    // Se cancela para que no aparezca en la lista de las asociaciones.
    await firestore.guardarDocumento(
      Colecciones.donaciones,
      id,
      leida.copyWith(estado: EstadoDonacion.cancelada).toMap(),
    );
  });

  // Criterio de T19: al reservar, la donacion cambia de estado y deja de
  // aparecer como disponible.
  testWidgets('una asociacion reserva y la donacion deja de estar disponible',
      (_) async {
    final puntoId = await repo.crearPuntoEntrega(PuntoEntrega(
      id: '',
      donanteId: donanteId,
      nombre: 'Punto de prueba',
      direccion: 'Av. Universidad 210',
      latitud: 0,
      longitud: 0,
    ));
    final id = await repo.crear(Donacion(
      id: '',
      donanteId: donanteId,
      descripcion: '[prueba automatica] reserva',
      cantidadKg: 1.5,
      caducidad: DateTime.now().add(const Duration(days: 1)),
      puntoEntregaId: puntoId,
      creadaEn: DateTime.now(),
    ));
    final publicada = (await repo
            .observarDisponibles()
            .firstWhere((lista) => lista.any((d) => d.id == id)))
        .firstWhere((d) => d.id == id);

    // La asociacion de prueba es la que reserva.
    await auth.cerrarSesion();
    final asociacionId = await auth.iniciarSesion(
      'prueba.asociacion@reparte.mx',
      'reparte123',
    );
    final reservada = await repo.reservar(publicada, asociacionId);

    expect(reservada.estado, EstadoDonacion.reservada);
    final disponibles = await repo
        .observarDisponibles()
        .firstWhere((lista) => lista.every((d) => d.id != id));
    expect(disponibles.map((d) => d.id), isNot(contains(id)));
    final enFirestore =
        await firestore.leerDocumento(Colecciones.donaciones, id);
    expect(enFirestore?['estado'], 'reservada');
    expect(enFirestore?['asociacionId'], asociacionId);
  });
}
