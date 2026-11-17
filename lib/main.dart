import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/tema/tema_app.dart';
import 'firebase_options.dart';
import 'repositories/donacion_repository.dart';
import 'repositories/usuario_repository.dart';
import 'routes/rutas.dart';
import 'services/auth_service.dart';
import 'services/conectividad_service.dart';
import 'services/firestore_service.dart';
import 'services/fotos_service.dart';
import 'services/navegacion_service.dart';
import 'services/notificaciones_service.dart';
import 'services/rutas_service.dart';
import 'services/selector_foto_service.dart';
import 'services/ubicacion_service.dart';
import 'viewmodels/login_viewmodel.dart';
import 'views/auth/registro_view.dart';
import 'views/inicio/puerta_acceso.dart';
import 'widgets/aviso_sin_conexion.dart';

Future<void> main() async {
  // Firebase debe estar listo antes de que cualquier servicio lo use.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(crearApp());
}

/// Arma la app con sus servicios reales, una sola instancia de cada uno.
/// La prueba de punta a punta (T25) puede cambiar el servicio de avisos
/// para comprobar que se mostro la notificacion.
Widget crearApp({NotificacionesService? notificaciones}) {
  final firestore = FirestoreService();
  final usuarioRepository = UsuarioRepository(
    auth: AuthService(),
    firestore: firestore,
  );
  final donacionRepository = DonacionRepository(firestore: firestore);
  const ubicacionService = GeolocatorUbicacionService();

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => LoginViewModel(usuarioRepository),
      ),
      Provider<UsuarioRepository>.value(value: usuarioRepository),
      Provider<DonacionRepository>.value(value: donacionRepository),
      Provider<UbicacionService>.value(value: ubicacionService),
      Provider<SelectorFotoService>.value(
        value: const ImagePickerSelectorFotoService(),
      ),
      Provider<FotosService>.value(value: const FotosFirestoreService()),
      Provider<NavegacionService>.value(value: const NavegacionService()),
      Provider<RutasService>.value(value: OsrmRutasService()),
      Provider<NotificacionesService>.value(
        value: notificaciones ?? LocalNotificacionesService(),
      ),
    ],
    child: ReParteApp(conectividad: ConnectivityPlusService()),
  );
}

class ReParteApp extends StatelessWidget {
  const ReParteApp({super.key, this.conectividad});

  /// Si se da, muestra el aviso de "Sin conexion" arriba de toda la app.
  final ConectividadService? conectividad;

  @override
  Widget build(BuildContext context) {
    final conectividad = this.conectividad;
    return MaterialApp(
      title: 'ReParte',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.claro,
      builder: conectividad == null
          ? null
          : (context, pantalla) => AvisoSinConexion(
                conectividad: conectividad,
                child: pantalla ?? const SizedBox.shrink(),
              ),
      home: const PuertaAcceso(),
      routes: {
        Rutas.registro: (_) => const RegistroView(),
      },
    );
  }
}
