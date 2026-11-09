import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/tema/tema_app.dart';
import '../../core/utilidades/validadores.dart';
import '../../repositories/usuario_repository.dart';
import '../../viewmodels/recuperar_contrasena_viewmodel.dart';
import '../../widgets/mensaje_error.dart';

/// Pantalla para pedir el correo de recuperacion de contrasena (T37).
class RecuperarContrasenaView extends StatefulWidget {
  const RecuperarContrasenaView({super.key, this.correoInicial = ''});

  /// Lo que ya se habia escrito en el inicio de sesion.
  final String correoInicial;

  /// Abre la pantalla con su propio ViewModel.
  static Future<void> abrir(BuildContext context, {String correo = ''}) {
    final repo = context.read<UsuarioRepository>();
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider(
        create: (_) => RecuperarContrasenaViewModel(repo),
        child: RecuperarContrasenaView(correoInicial: correo.trim()),
      ),
    ));
  }

  @override
  State<RecuperarContrasenaView> createState() =>
      _RecuperarContrasenaViewState();
}

class _RecuperarContrasenaViewState extends State<RecuperarContrasenaView> {
  final _formulario = GlobalKey<FormState>();
  late final _correo = TextEditingController(text: widget.correoInicial);

  @override
  void dispose() {
    _correo.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formulario.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await context.read<RecuperarContrasenaViewModel>().enviar(_correo.text);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecuperarContrasenaViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: vm.enviado ? _confirmacion(vm) : _formularioCorreo(vm),
        ),
      ),
    );
  }

  Widget _formularioCorreo(RecuperarContrasenaViewModel vm) {
    final texto = Theme.of(context).textTheme;
    return Form(
      key: _formulario,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Icono(Icons.lock_reset),
          const SizedBox(height: 20),
          Text(
            '¿Olvidaste tu contraseña?',
            textAlign: TextAlign.center,
            style: texto.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Escribe el correo de tu cuenta y te enviaremos un enlace '
            'para crear una contraseña nueva.',
            textAlign: TextAlign.center,
            style: texto.bodyMedium?.copyWith(color: TemaApp.gris),
          ),
          const SizedBox(height: 28),
          TextFormField(
            controller: _correo,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.send,
            onFieldSubmitted: (_) => _enviar(),
            decoration: const InputDecoration(
              labelText: 'Correo',
              prefixIcon: Icon(Icons.mail_outline),
            ),
            validator: Validadores.correo,
          ),
          if (vm.mensajeError != null) ...[
            const SizedBox(height: 16),
            MensajeError(vm.mensajeError!),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: vm.enviando ? null : _enviar,
            child: vm.enviando
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Enviar enlace'),
          ),
        ],
      ),
    );
  }

  Widget _confirmacion(RecuperarContrasenaViewModel vm) {
    final texto = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Icono(Icons.mark_email_read_outlined),
        const SizedBox(height: 20),
        Text(
          'Revisa tu correo',
          textAlign: TextAlign.center,
          style: texto.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Si hay una cuenta con ${vm.correoEnviado}, te llegará un enlace '
          'para crear una contraseña nueva. Si no lo ves, busca en la '
          'carpeta de spam.',
          textAlign: TextAlign.center,
          style: texto.bodyMedium?.copyWith(color: TemaApp.gris),
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Volver a iniciar sesión'),
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: vm.escribirOtraVez,
          child: const Text('Enviar de nuevo'),
        ),
      ],
    );
  }
}

/// Circulo lima con el icono de la pantalla.
class _Icono extends StatelessWidget {
  const _Icono(this.icono);

  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 96,
        height: 96,
        decoration: const BoxDecoration(
          color: TemaApp.lima,
          shape: BoxShape.circle,
        ),
        child: Icon(icono, size: 44, color: TemaApp.verdeOscuro),
      ),
    );
  }
}
