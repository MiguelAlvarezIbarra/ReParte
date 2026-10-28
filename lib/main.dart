import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/tema/tema_app.dart';
import 'firebase_options.dart';
import 'repositories/donacion_repository.dart';
import 'repositories/usuario_repository.dart';
import 'routes/rutas.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'viewmodels/login_viewmodel.dart';
import 'views/auth/registro_view.dart';
import 'views/inicio/puerta_acceso.dart';

Future<void> main() async {
  // Firebase debe estar listo antes de que cualquier servicio lo use.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Una sola instancia de cada servicio, inyectada hacia arriba.
  final firestore = FirestoreService();
  final usuarioRepository = UsuarioRepository(
    auth: AuthService(),
    firestore: firestore,
  );
  final donacionRepository = DonacionRepository(firestore: firestore);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(usuarioRepository),
        ),
        Provider<UsuarioRepository>.value(value: usuarioRepository),
        Provider<DonacionRepository>.value(value: donacionRepository),
      ],
      child: const ReParteApp(),
    ),
  );
}

class ReParteApp extends StatelessWidget {
  const ReParteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReParte',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.claro,
      home: const PuertaAcceso(),
      routes: {
        Rutas.registro: (_) => const RegistroView(),
      },
    );
  }
}
