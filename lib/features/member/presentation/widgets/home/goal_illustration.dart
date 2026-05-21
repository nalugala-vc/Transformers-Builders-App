import 'package:flutter/material.dart';

import '../../../../../core/utils/theme/app_pallete.dart';
import '../../../../../core/utils/theme/app_sizes.dart';
import '../../member_assets.dart';

/// Goal asset with soft concentric blue rings behind it.
class GoalIllustration extends StatelessWidget {
  const GoalIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    const canvasSize = 152.0;
    final imageHeight = context.scaled.h(88);

    return SizedBox(
      width: canvasSize,
      height: canvasSize,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          const CustomPaint(
            size: Size(canvasSize, canvasSize),
            painter: _GoalRingsPainter(),
          ),
          Image.asset(
            MemberAssets.goal,
            height: imageHeight,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class _GoalRingsPainter extends CustomPainter {
  const _GoalRingsPainter();

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
          AppPallete.tcBlueBright.withValues(alpha: 0.14),
          AppPallete.tcBlueBright.withValues(alpha: 0.04),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius * 0.55));
    canvas.drawCircle(center, maxRadius * 0.55, glow);

    for (final ring in _rings) {
      final paint = Paint()
        ..color = AppPallete.tcBlueBright.withValues(alpha: ring.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ring.stroke;
      canvas.drawCircle(center, maxRadius * ring.scale, paint);
    }

    // Accent ring with a slightly lighter blue for depth.
    final accent = Paint()
      ..color = AppPallete.tcBlueLight.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, maxRadius * 0.73, accent);
  }

  @override
  bool shouldRepaint(covariant _GoalRingsPainter oldDelegate) => false;
}
