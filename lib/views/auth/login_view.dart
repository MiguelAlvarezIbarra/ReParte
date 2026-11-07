import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/tema/tema_app.dart';
import '../../core/utilidades/validadores.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../widgets/encabezado_reparte.dart';
import '../../widgets/mensaje_error.dart';
import '../../routes/rutas.dart';

/// Pantalla de inicio de sesion.
/// Solo muestra lo que le indica el LoginViewModel.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formulario = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  bool _ocultarContrasena = true;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formulario.currentState!.validate()) return;
    final vm = context.read<LoginViewModel>();
    // Si entra, PuertaAcceso cambia sola a la pantalla de su rol.
    await vm.iniciarSesion(_correo.text, _contrasena.text);
  }

  Future<void> _irARegistro() async {
    final vm = context.read<LoginViewModel>()..limpiarError();
    await Navigator.of(context).pushNamed(Rutas.registro);
    vm.limpiarError();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formulario,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const EncabezadoReParte(),
                  const SizedBox(height: 28),
                  const _Presentacion(),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _correo,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      hintText: 'laura@restaurante.mx',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                    validator: Validadores.correo,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contrasena,
                    obscureText: _ocultarContrasena,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _entrar(),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip: _ocultarContrasena
                            ? 'Mostrar contraseña'
                            : 'Ocultar contraseña',
                        icon: Icon(_ocultarContrasena
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setState(
                          () => _ocultarContrasena = !_ocultarContrasena,
                        ),
                      ),
                    ),
                    validator: Validadores.contrasena,
                  ),
                  if (vm.mensajeError != null) ...[
                    const SizedBox(height: 16),
                    MensajeError(vm.mensajeError!),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: vm.cargando ? null : _entrar,
                    child: vm.cargando
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Entrar'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿Aún no tienes cuenta?',
                        style: TextStyle(color: TemaApp.gris),
                      ),
                      TextButton(
                        onPressed: vm.cargando ? null : _irARegistro,
                        child: const Text('Crear cuenta'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta verde que explica en una linea para que sirve la app.
class _Presentacion extends StatelessWidget {
  const _Presentacion();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TemaApp.verde,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: TemaApp.lima,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.volunteer_activism_outlined,
              color: TemaApp.verdeOscuro,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Restaurantes y asociaciones conectados para que la comida '
              'llegue a quien la necesita.',
              style: TextStyle(color: TemaApp.crema, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
