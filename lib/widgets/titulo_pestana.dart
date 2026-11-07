import 'package:flutter/material.dart';

/// Titulo grande arriba de una pestana de la barra inferior.
class TituloPestana extends StatelessWidget {
  const TituloPestana(this.titulo, {super.key});

  final String titulo;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
        child: Text(titulo, style: Theme.of(context).textTheme.headlineSmall),
      ),
    );
  }
}
