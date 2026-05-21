import 'package:flutter/material.dart';

class ContributionSegment {
  const ContributionSegment({
    required this.id,
    required this.label,
    required this.amountKes,
    required this.color,
    this.recentTitle,
    this.recentSubtitle,
    this.recentAmountKes,
    this.targetKes,
  });

  final String id;
  final String label;
  final int amountKes;
  final Color color;
  final String? recentTitle;
  final String? recentSubtitle;
  final int? recentAmountKes;
  final int? targetKes;

  double shareOf(int totalKes) => totalKes <= 0 ? 0 : amountKes / totalKes;
}

class ChurchProgressSnapshot {
  const ChurchProgressSnapshot({
    required this.totalKes,
    required this.monthlyChangeKes,
    required this.monthlyChangePercent,
    required this.segments,
    required this.summaryTitle,
    required this.summarySubtitle,
  });

  final int totalKes;
  final int monthlyChangeKes;
  final double monthlyChangePercent;
  final List<ContributionSegment> segments;
  final String summaryTitle;
  final String summarySubtitle;

  bool get hasContributions => totalKes > 0;
}
