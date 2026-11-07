import 'package:flutter/material.dart';
import '../core/tema/tema_app.dart';
import 'boton_cerrar_sesion.dart';

/// Franja verde de arriba en las pantallas de inicio: iniciales, saludo,
/// cerrar sesion y, debajo, una accion principal opcional.
class EncabezadoInicio extends StatelessWidget {
  const EncabezadoInicio({
    super.key,
    required this.nombre,
    this.subtitulo,
    this.accion,
  });

  final String nombre;
  final String? subtitulo;
  final Widget? accion;

  /// "Panadería La Espiga" -> "PL"
  static String iniciales(String nombre) {
    final partes = nombre.trim().split(RegExp(r'\s+'))
      ..removeWhere((p) => p.isEmpty);
    if (partes.isEmpty) return '?';
    return partes.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Container(
      decoration: const BoxDecoration(
        color: TemaApp.verde,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: TemaApp.lima,
                    child: Text(
                      iniciales(nombre),
                      style: const TextStyle(
                        fontFamily: TemaApp.fuenteTitulos,
                        fontWeight: FontWeight.w700,
                        color: TemaApp.verdeOscuro,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hola, $nombre',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: texto.titleMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        if (subtitulo != null)
                          Text(
                            subtitulo!,
                            style: const TextStyle(
                              color: Color(0xFFCFE3DA),
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const IconTheme(
                    data: IconThemeData(color: Colors.white),
                    child: BotonCerrarSesion(),
                  ),
                ],
              ),
              if (accion != null) ...[
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: accion!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
