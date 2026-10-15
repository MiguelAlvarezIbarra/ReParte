import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../auth/login_view.dart';
import 'pantalla_inicio_factory.dart';

/// Primera pantalla de la app. Decide a donde ir segun la sesion:
/// sin sesion muestra el login; con sesion, la pantalla de su rol.
/// Al iniciar o cerrar sesion cambia sola, sin navegar a mano.
class PuertaAcceso extends StatefulWidget {
  const PuertaAcceso({super.key});

  @override
  State<PuertaAcceso> createState() => _PuertaAccesoState();
}

class _PuertaAccesoState extends State<PuertaAcceso> {
  @override
  void initState() {
    super.initState();
    final vm = context.read<LoginViewModel>();
    if (!vm.sesionVerificada) vm.restaurarSesion();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();
    if (!vm.sesionVerificada) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final usuario = vm.usuario;
    if (usuario == null) return const LoginView();
    return PantallaInicioFactory.crear(usuario);
  }
}
