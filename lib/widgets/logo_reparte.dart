import 'package:flutter/material.dart';
import '../core/tema/tema_app.dart';

/// Logo de ReParte (T32): un marcador de mapa con una hoja, la comida que
/// espera en un punto de entrega. Se dibuja con codigo para verse nitido
/// en cualquier tamano; es el mismo dibujo del icono de Android.
class LogoReParte extends StatelessWidget {
  const LogoReParte({super.key, this.tamano = 84, this.conFondo = true});

  final double tamano;

  /// Con el cuadro verde redondeado, como el icono de la app.
  final bool conFondo;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Logo de ReParte',
      image: true,
      child: SizedBox.square(
        dimension: tamano,
        child: CustomPaint(painter: _PintorLogo(conFondo: conFondo)),
      ),
    );
  }
}

class _PintorLogo extends CustomPainter {
  const _PintorLogo({required this.conFondo});

  final bool conFondo;

  @override
  void paint(Canvas canvas, Size size) {
    final escala = size.width / 100;
    if (conFondo) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(size.width * 0.23),
        ),
        Paint()..color = TemaApp.verde,
      );
      // Dentro del cuadro el marcador ocupa un poco menos.
      canvas
        ..translate(size.width * 0.1, size.height * 0.08)
        ..scale(0.8);
    }
    canvas.scale(escala);

    final fondoHoja = conFondo ? TemaApp.verde : TemaApp.crema;
    canvas
      ..drawPath(marcador(), Paint()..color = TemaApp.lima)
      ..drawPath(hoja(), Paint()..color = fondoHoja)
      ..drawLine(
        const Offset(50, 57),
        const Offset(50, 40),
        Paint()
          ..color = TemaApp.lima
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
  }

  @override
  bool shouldRepaint(_PintorLogo anterior) => anterior.conFondo != conFondo;
}

/// Marcador de mapa en un cuadro de 100 x 100.
Path marcador() => Path()
  ..moveTo(50, 90)
  ..cubicTo(50, 90, 22, 60, 22, 41)
  ..arcToPoint(const Offset(78, 41), radius: const Radius.circular(28))
  ..cubicTo(78, 60, 50, 90, 50, 90)
  ..close();

/// Hoja dentro del marcador, en el mismo cuadro de 100 x 100.
Path hoja() => Path()
  ..moveTo(50, 58)
  ..cubicTo(38, 53, 37, 38, 50, 28)
  ..cubicTo(63, 38, 62, 53, 50, 58)
  ..close();
