import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/tema/tema_app.dart';
import 'firebase_options.dart';
import 'views/auth/login_view.dart';

Future<void> main() async {
  // Firebase debe estar listo antes de que cualquier servicio lo use.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ReParteApp());
}

class ReParteApp extends StatelessWidget {
  const ReParteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReParte',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.claro,
      home: const LoginView(),
    );
  }
}
