import 'package:flutter/material.dart';

class VentoSafeIcon extends StatelessWidget {
  final Color color;
  final double size;

  const VentoSafeIcon({super.key, required this.color, this.size = 30});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SafePainter(color: color),
      ),
    );
  }
}

class _SafePainter extends CustomPainter {
  final Color color;
  _SafePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Draw main box (3D Isometric-ish)
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.1); // Top peak
    path.lineTo(size.width * 0.9, size.height * 0.3); // Right top
    path.lineTo(size.width * 0.9, size.height * 0.7); // Right bottom
    path.lineTo(size.width * 0.5, size.height * 0.9); // Bottom peak
    path.lineTo(size.width * 0.1, size.height * 0.7); // Left bottom
    path.lineTo(size.width * 0.1, size.height * 0.3); // Left top
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);

    // Draw dividers for drawers
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.3),
      Offset(size.width * 0.5, size.height * 0.9),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.5),
      Offset(size.width * 0.9, size.height * 0.5),
      paint,
    );

    // Draw handles
    final handlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05;

    _drawHandle(canvas, Offset(size.width * 0.3, size.height * 0.4), size.width * 0.1, handlePaint);
    _drawHandle(canvas, Offset(size.width * 0.7, size.height * 0.4), size.width * 0.1, handlePaint);
    _drawHandle(canvas, Offset(size.width * 0.3, size.height * 0.7), size.width * 0.1, handlePaint);
    _drawHandle(canvas, Offset(size.width * 0.7, size.height * 0.7), size.width * 0.1, handlePaint);
  }

  void _drawHandle(Canvas canvas, Offset center, double width, Paint paint) {
    canvas.drawArc(
      Rect.fromCenter(center: center, width: width, height: width * 0.6),
      0,
      3.14,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
