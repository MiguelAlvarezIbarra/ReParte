import 'package:flutter/material.dart';
import '../../core/tema/tema_app.dart';
import '../../models/usuario.dart';
import '../../viewmodels/mis_donaciones_viewmodel.dart';
import '../../widgets/encabezado_inicio.dart';
import '../../widgets/titulo_pestana.dart';
import '../donaciones/mis_donaciones_view.dart';
import '../donaciones/publicar_donacion_view.dart';
import '../perfil/perfil_view.dart';

/// Pantalla principal del donante, con barra inferior:
/// sus donaciones, publicar una nueva y su perfil.
class InicioDonanteView extends StatefulWidget {
  const InicioDonanteView({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<InicioDonanteView> createState() => _InicioDonanteViewState();
}

class _InicioDonanteViewState extends State<InicioDonanteView> {
  /// 0 = Inicio, 2 = Perfil. "Publicar" (1) abre el formulario y no cambia
  /// de pestana.
  int _pestana = 0;

  Future<void> _publicar() async {
    final publicada =
        await PublicarDonacionView.abrir(context, donanteId: widget.usuario.id);
    if (!publicada || !mounted) return;
    setState(() => _pestana = 0);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Donación publicada')),
    );
  }

  void _alElegir(int i) {
    if (i == 1) {
      _publicar();
    } else {
      setState(() => _pestana = i);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = widget.usuario;
    return Scaffold(
      body: _pestana == 2
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TituloPestana('Perfil'),
                Expanded(child: PerfilView(usuario: usuario)),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EncabezadoInicio(
                  nombre: usuario.nombre,
                  subtitulo: 'Donante',
                  accion: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: TemaApp.lima,
                      foregroundColor: TemaApp.verdeOscuro,
                    ),
                    onPressed: _publicar,
                    icon: const Icon(Icons.add),
                    label: const Text('Publicar donación'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Text(
                    'Mis donaciones',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: MisDonacionesView(
                    usuarioId: usuario.id,
                    dueno: DuenoLista.donante,
                  ),
                ),
              ],
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pestana,
        onDestinationSelected: _alElegir,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: 'Publicar',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
