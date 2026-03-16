import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wheel_segment.dart';

class WheelPainter extends CustomPainter {
  final List<WheelSegment> segments;
  final double rotationAngle; // current rotation in radians

  WheelPainter({required this.segments, this.rotationAngle = 0});

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final count = segments.length;
    final sweepAngle = 2 * pi / count;

    // --- Drop shadow ---
    final shadowPath = Path()
      ..addOval(Rect.fromCircle(center: center + const Offset(0, 6), radius: radius));
    canvas.drawShadow(shadowPath, Colors.black.withValues(alpha: 0.6), 12, false);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);

    for (int i = 0; i < count; i++) {
      final startAngle = -pi / 2 + i * sweepAngle;
      final paint = Paint()
        ..color = segments[i].color
        ..style = PaintingStyle.fill;

      // Segment fill
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // White divider line
      final linePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      final lineEnd = Offset(
        center.dx + radius * cos(startAngle),
        center.dy + radius * sin(startAngle),
      );
      canvas.drawLine(center, lineEnd, linePaint);

      // --- Segment label ---
      _drawLabel(canvas, center, radius, startAngle, sweepAngle, segments[i].label, i, count);
    }

    // White outer ring
    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, ringPaint);

    // Center white circle
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.12, centerPaint);

    // Center shadow ring
    final centerRingPaint = Paint()
      ..color = Colors.black26
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius * 0.12, centerRingPaint);

    canvas.restore();
  }

  void _drawLabel(Canvas canvas, Offset center, double radius, double startAngle,
      double sweepAngle, String label, int index, int count) {
    final midAngle = startAngle + sweepAngle / 2;
    // Place label at ~65% of the radius from center
    final labelRadius = radius * 0.62;
    final labelCenter = Offset(
      center.dx + labelRadius * cos(midAngle),
      center.dy + labelRadius * sin(midAngle),
    );

    canvas.save();
    canvas.translate(labelCenter.dx, labelCenter.dy);
    canvas.rotate(midAngle + pi / 2);

    // Available width for text ≈ chord at labelRadius
    final chordWidth = 2 * labelRadius * sin(sweepAngle / 2) * 0.85;
    const maxFontSize = 16.0;
    const minFontSize = 8.0;

    // Try to fit the text, shrink if needed
    double fontSize = maxFontSize;
    TextPainter? tp;
    while (fontSize >= minFontSize) {
      final style = GoogleFonts.righteous(
        fontSize: fontSize,
        color: Colors.white,
        shadows: [Shadow(color: Colors.black45, blurRadius: 3)],
      );
      tp = TextPainter(
        text: TextSpan(text: label, style: style),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        maxLines: 2,
      );
      tp.layout(maxWidth: chordWidth);
      if (tp.width <= chordWidth) break;
      fontSize -= 1;
    }

    tp!.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(WheelPainter oldDelegate) {
    return oldDelegate.rotationAngle != rotationAngle ||
        oldDelegate.segments != segments;
  }
}
