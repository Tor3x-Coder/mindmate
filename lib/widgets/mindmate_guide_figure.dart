import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Lightweight 2D MindMate guide drawn entirely with Flutter.
///
/// It adds no image asset weight and remains crisp at every screen density.
class MindMateGuideFigure extends StatelessWidget {
  final double size;

  const MindMateGuideFigure({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'MindMate guide',
      child: SizedBox.square(
        dimension: size,
        child: const CustomPaint(
          painter: _MindMateGuidePainter(),
        ),
      ),
    );
  }
}

class _MindMateGuidePainter extends CustomPainter {
  const _MindMateGuidePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide * 0.42;

    final shadowPaint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center.translate(0, 4), radius, shadowPaint);

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppTheme.seaGlass, AppTheme.secondary],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bodyPaint);

    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.62)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.055
      ..strokeCap = StrokeCap.round;
    final wave = Path()
      ..moveTo(size.width * 0.22, size.height * 0.61)
      ..cubicTo(
        size.width * 0.34,
        size.height * 0.53,
        size.width * 0.42,
        size.height * 0.69,
        size.width * 0.54,
        size.height * 0.61,
      )
      ..cubicTo(
        size.width * 0.66,
        size.height * 0.53,
        size.width * 0.72,
        size.height * 0.65,
        size.width * 0.79,
        size.height * 0.60,
      );
    canvas.drawPath(wave, wavePaint);

    final facePaint = Paint()..color = AppTheme.textDark;
    canvas.drawCircle(
      Offset(size.width * 0.39, size.height * 0.43),
      size.width * 0.035,
      facePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.61, size.height * 0.43),
      size.width * 0.035,
      facePaint,
    );

    final smilePaint = Paint()
      ..color = AppTheme.textDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.032
      ..strokeCap = StrokeCap.round;
    final smileRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.47),
      width: size.width * 0.22,
      height: size.height * 0.18,
    );
    canvas.drawArc(smileRect, 0.2, 2.74, false, smilePaint);

    final sparklePaint = Paint()..color = AppTheme.sand;
    final sparkleCenter = Offset(size.width * 0.79, size.height * 0.21);
    final sparkle = Path()
      ..moveTo(sparkleCenter.dx, sparkleCenter.dy - size.height * 0.08)
      ..lineTo(sparkleCenter.dx + size.width * 0.025, sparkleCenter.dy)
      ..lineTo(sparkleCenter.dx, sparkleCenter.dy + size.height * 0.08)
      ..lineTo(sparkleCenter.dx - size.width * 0.025, sparkleCenter.dy)
      ..close();
    canvas.drawPath(sparkle, sparklePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
