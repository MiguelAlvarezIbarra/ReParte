import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utilidades/validadores.dart';
import '../../models/usuario.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../widgets/mensaje_error.dart';

/// Pantalla para crear una cuenta nueva.
class RegistroView extends StatefulWidget {
  const RegistroView({super.key});

  @override
  State<RegistroView> createState() => _RegistroViewState();
}

class _RegistroViewState extends State<RegistroView> {
  final _formulario = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  bool _ocultarContrasena = true;

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _crearCuenta() async {
    if (!_formulario.currentState!.validate()) return;
    final vm = context.read<LoginViewModel>();
    final ok = await vm.registrar(
      nombre: _nombre.text,
      correo: _correo.text,
      contrasena: _contrasena.text,
      // TODO(T09): usar el rol que elija el usuario.
      rol: RolUsuario.donante,
    );
    if (!ok || !mounted) return;
    // TODO(T10): navegar a la pantalla de inicio segun el rol.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formulario,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nombre,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del establecimiento u organización',
                    prefixIcon: Icon(Icons.storefront_outlined),
                  ),
                  validator: (v) => Validadores.requerido(v, 'nombre'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _correo,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Correo',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                  validator: Validadores.correo,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contrasena,
                  obscureText: _ocultarContrasena,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _crearCuenta(),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    helperText: 'Al menos 6 caracteres',
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
                  validator: Validadores.contrasenaNueva,
                ),
                if (vm.mensajeError != null) ...[
                  const SizedBox(height: 16),
                  MensajeError(vm.mensajeError!),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: vm.cargando ? null : _crearCuenta,
                  child: vm.cargando
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Crear cuenta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
