import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/utils/theme/app_pallete.dart';
import '../../domain/models/contribution_segment.dart';
import '../../domain/models/member_group.dart';
import '../../domain/models/progress_breakdown_mode.dart';

export '../../domain/models/contribution_segment.dart' show ChurchProgressSnapshot;

final progressBreakdownModeProvider = StateProvider<ProgressBreakdownMode>(
  (ref) => ProgressBreakdownMode.demographics,
);

final progressSelectedSegmentIdProvider = StateProvider<String?>((ref) => null);

final churchProgressSnapshotProvider = Provider<ChurchProgressSnapshot>((ref) {
  final mode = ref.watch(progressBreakdownModeProvider);
  return mode == ProgressBreakdownMode.demographics
      ? _emptyDemographicsSnapshot
      : _emptyMinistriesSnapshot;
});

final progressSelectedSegmentProvider = Provider<ContributionSegment?>((ref) {
  final snapshot = ref.watch(churchProgressSnapshotProvider);
  final selectedId = ref.watch(progressSelectedSegmentIdProvider);
  if (snapshot.segments.isEmpty) return null;

  if (selectedId != null) {
    for (final segment in snapshot.segments) {
      if (segment.id == selectedId) return segment;
    }
  }
  return snapshot.segments.first;
});

ContributionSegment _segment({
  required String id,
  required String label,
  required int amount,
  required Color color,
  required int target,
}) {
  return ContributionSegment(
    id: id,
    label: label,
    amountKes: amount,
    color: color,
    targetKes: target,
  );
}

class _GroupProgressMeta {
  const _GroupProgressMeta({
    required this.group,
    required this.color,
    required this.target,
  });

  final MemberGroup group;
  final Color color;
  final int target;
}

ContributionSegment _emptySegmentFromMeta(_GroupProgressMeta meta) => _segment(
      id: meta.group.id,
      label: meta.group.label,
      amount: 0,
      color: meta.color,
      target: meta.target,
    );

final _emptyDemographicsSnapshot = ChurchProgressSnapshot(
  totalKes: 0,
  monthlyChangeKes: 0,
  monthlyChangePercent: 0,
  summaryTitle: 'Church-wide summary',
  summarySubtitle:
      'Contributions will appear here as members set goals and start giving.',
  segments: [
    for (final meta in _demographicProgressMeta) _emptySegmentFromMeta(meta),
  ],
);

final _emptyMinistriesSnapshot = ChurchProgressSnapshot(
  totalKes: 0,
  monthlyChangeKes: 0,
  monthlyChangePercent: 0,
  summaryTitle: 'Ministry summary',
  summarySubtitle:
      'Ministry totals will update once teams begin contributing toward the church target.',
  segments: [
    for (final meta in _ministryProgressMeta) _emptySegmentFromMeta(meta),
  ],
);

final _demographicProgressMeta = [
  _GroupProgressMeta(
    group: MemberGroups.demographics[0],
    color: AppPallete.tcBlueBright,
    target: 280000,
  ),
  _GroupProgressMeta(
    group: MemberGroups.demographics[1],
    color: AppPallete.successGreen,
    target: 220000,
  ),
  _GroupProgressMeta(
    group: MemberGroups.demographics[2],
    color: AppPallete.warningAmber,
    target: 120000,
  ),
];

final _ministryProgressMeta = [
  _GroupProgressMeta(
    group: MemberGroups.ministries[0],
    color: AppPallete.tcBlueBright,
    target: 100000,
  ),
  _GroupProgressMeta(
    group: MemberGroups.ministries[1],
    color: const Color(0xFF8B5CF6),
    target: 90000,
  ),
  _GroupProgressMeta(
    group: MemberGroups.ministries[2],
    color: AppPallete.successGreen,
    target: 130000,
  ),
  _GroupProgressMeta(
    group: MemberGroups.ministries[3],
    color: const Color(0xFF14B8A6),
    target: 60000,
  ),
  _GroupProgressMeta(
    group: MemberGroups.ministries[4],
    color: AppPallete.warningAmber,
    target: 70000,
  ),
  _GroupProgressMeta(
    group: MemberGroups.ministries[5],
    color: const Color(0xFFEC4899),
    target: 125000,
  ),
];
