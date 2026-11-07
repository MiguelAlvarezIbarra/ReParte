import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/tema/tema_app.dart';
import '../../models/usuario.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../widgets/encabezado_inicio.dart';

/// Datos de la cuenta y el boton para salir.
class PerfilView extends StatelessWidget {
  const PerfilView({super.key, required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      children: [
        Center(
          child: CircleAvatar(
            radius: 44,
            backgroundColor: TemaApp.verde,
            child: Text(
              EncabezadoInicio.iniciales(usuario.nombre),
              style: const TextStyle(
                fontFamily: TemaApp.fuenteTitulos,
                fontWeight: FontWeight.w700,
                fontSize: 28,
                color: TemaApp.lima,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          usuario.nombre,
          textAlign: TextAlign.center,
          style: texto.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          usuario.esDonante ? 'Donante' : 'Asociación',
          textAlign: TextAlign.center,
          style: texto.bodyMedium?.copyWith(color: TemaApp.gris),
        ),
        const SizedBox(height: 24),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.mail_outline, color: TemaApp.verde),
                title: const Text('Correo'),
                subtitle: Text(usuario.correo),
              ),
              if (usuario.telefono.isNotEmpty)
                ListTile(
                  leading:
                      const Icon(Icons.phone_outlined, color: TemaApp.verde),
                  title: const Text('Teléfono'),
                  subtitle: Text(usuario.telefono),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => context.read<LoginViewModel>().cerrarSesion(),
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar sesión'),
        ),
      ],
    );
  }
}
