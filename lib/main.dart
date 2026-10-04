import 'package:flutter/material.dart';
import 'core/tema/tema_app.dart';
import 'views/auth/login_view.dart';

void main() {
  // TODO(T04): inicializar Firebase antes de runApp.
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
