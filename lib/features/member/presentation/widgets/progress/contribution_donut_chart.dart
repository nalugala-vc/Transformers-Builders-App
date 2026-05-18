import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/models/contribution_segment.dart';

class ContributionDonutChart extends StatelessWidget {
  const ContributionDonutChart({
    super.key,
    required this.segments,
    required this.totalKes,
    this.size = 200,
    this.strokeWidth = 22,
  });

  final List<ContributionSegment> segments;
  final int totalKes;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(
          segments: segments,
          totalKes: totalKes,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.segments,
    required this.totalKes,
    required this.strokeWidth,
  });

  final List<ContributionSegment> segments;
  final int totalKes;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);

    if (totalKes <= 0 || segments.isEmpty) return;

    var startAngle = -math.pi / 2;
    for (final segment in segments) {
      final sweep = math.pi * 2 * segment.shareOf(totalKes);
      if (sweep <= 0) continue;

      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.totalKes != totalKes || oldDelegate.segments != segments;
  }
}
