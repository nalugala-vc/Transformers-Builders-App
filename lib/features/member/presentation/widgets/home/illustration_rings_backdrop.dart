import 'package:flutter/material.dart';

import '../../../../../core/utils/theme/app_pallete.dart';

/// Soft concentric rings behind member illustration assets.
class IllustrationRingsBackdrop extends StatelessWidget {
  const IllustrationRingsBackdrop({
    super.key,
    required this.child,
    this.canvasSize = 152,
    this.ringColor = AppPallete.tcBlueBright,
    this.accentColor = AppPallete.tcBlueLight,
  });

  final Widget child;
  final double canvasSize;
  final Color ringColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: canvasSize,
      height: canvasSize,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: Size(canvasSize, canvasSize),
            painter: _RingsPainter(ringColor: ringColor, accentColor: accentColor),
          ),
          child,
        ],
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  const _RingsPainter({required this.ringColor, required this.accentColor});

  final Color ringColor;
  final Color accentColor;

  static const _rings = <({double scale, double opacity, double stroke})>[
    (scale: 1.0, opacity: 0.07, stroke: 1.0),
    (scale: 0.82, opacity: 0.11, stroke: 1.25),
    (scale: 0.64, opacity: 0.15, stroke: 1.5),
    (scale: 0.46, opacity: 0.10, stroke: 1.25),
    (scale: 0.30, opacity: 0.06, stroke: 1.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          ringColor.withValues(alpha: 0.14),
          ringColor.withValues(alpha: 0.04),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius * 0.55));
    canvas.drawCircle(center, maxRadius * 0.55, glow);

    for (final ring in _rings) {
      final paint = Paint()
        ..color = ringColor.withValues(alpha: ring.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ring.stroke;
      canvas.drawCircle(center, maxRadius * ring.scale, paint);
    }

    final accent = Paint()
      ..color = accentColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, maxRadius * 0.73, accent);
  }

  @override
  bool shouldRepaint(covariant _RingsPainter oldDelegate) =>
      oldDelegate.ringColor != ringColor || oldDelegate.accentColor != accentColor;
}
