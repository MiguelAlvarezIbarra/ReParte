import 'package:flutter/material.dart';
import '../models/usuario.dart';

/// Botones "Soy: Donante / Asociación" del registro.
class SelectorRol extends StatelessWidget {
  const SelectorRol({
    super.key,
    required this.rol,
    required this.alCambiar,
    this.habilitado = true,
  });

  final RolUsuario rol;
  final ValueChanged<RolUsuario> alCambiar;
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Soy', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<RolUsuario>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: RolUsuario.donante,
              label: Text('Donante'),
              icon: Icon(Icons.storefront_outlined),
            ),
            ButtonSegment(
              value: RolUsuario.asociacion,
              label: Text('Asociación'),
              icon: Icon(Icons.volunteer_activism_outlined),
            ),
          ],
          selected: {rol},
          onSelectionChanged:
              habilitado ? (seleccion) => alCambiar(seleccion.first) : null,
        ),
      ],
    );
  }
}
