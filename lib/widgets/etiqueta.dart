import 'package:flutter/material.dart';
import '../core/tema/tema_app.dart';

/// Pastilla pequena para estados y datos cortos ("Caduca hoy", "Reservada").
class Etiqueta extends StatelessWidget {
  const Etiqueta(
    this.texto, {
    super.key,
    this.icono,
    this.destacada = false,
  });

  /// En lima con texto verde: llama la atencion ("Caduca hoy").
  const Etiqueta.destacada(this.texto, {super.key, this.icono})
      : destacada = true;

  final String texto;
  final IconData? icono;
  final bool destacada;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: destacada ? TemaApp.lima : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: destacada ? null : Border.all(color: const Color(0xFFEDE5D6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icono != null) ...[
            Icon(icono, size: 16, color: TemaApp.verde),
            const SizedBox(width: 6),
          ],
          Text(
            texto,
            style: TextStyle(
              fontSize: 13,
              fontWeight: destacada ? FontWeight.w600 : FontWeight.w500,
              color: destacada ? TemaApp.verdeOscuro : TemaApp.texto,
            ),
          ),
        ],
      ),
    );
  }
}
