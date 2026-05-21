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
      ? _demographicsSnapshot
      : _ministriesSnapshot;
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
  required String recentTitle,
  required String recentSubtitle,
  required int recentAmount,
}) {
  return ContributionSegment(
    id: id,
    label: label,
    amountKes: amount,
    color: color,
    targetKes: target,
    recentTitle: recentTitle,
    recentSubtitle: recentSubtitle,
    recentAmountKes: recentAmount,
  );
}

final _demographicsSnapshot = ChurchProgressSnapshot(
  totalKes: 485000,
  monthlyChangeKes: 32500,
  monthlyChangePercent: 7.2,
  summaryTitle: 'Church-wide summary',
  summarySubtitle: 'Track how each group is contributing toward this season’s goals.',
  segments: [
    for (final data in _demographicProgressData) _segmentFromData(data),
  ],
);

final _ministriesSnapshot = ChurchProgressSnapshot(
  totalKes: 485000,
  monthlyChangeKes: 32500,
  monthlyChangePercent: 7.2,
  summaryTitle: 'Ministry summary',
  summarySubtitle: 'See how each ministry team is giving toward the church target.',
  segments: [
    for (final data in _ministryProgressData) _segmentFromData(data),
  ],
);

class _GroupProgressData {
  const _GroupProgressData({
    required this.group,
    required this.amount,
    required this.color,
    required this.target,
    required this.recentTitle,
    required this.recentSubtitle,
    required this.recentAmount,
  });

  final MemberGroup group;
  final int amount;
  final Color color;
  final int target;
  final String recentTitle;
  final String recentSubtitle;
  final int recentAmount;
}

ContributionSegment _segmentFromData(_GroupProgressData data) => _segment(
      id: data.group.id,
      label: data.group.label,
      amount: data.amount,
      color: data.color,
      target: data.target,
      recentTitle: data.recentTitle,
      recentSubtitle: data.recentSubtitle,
      recentAmount: data.recentAmount,
    );

final _demographicProgressData = [
  _GroupProgressData(
    group: MemberGroups.demographics[0],
    amount: 228000,
    color: AppPallete.tcBlueBright,
    target: 280000,
    recentTitle: 'Women’s fellowship',
    recentSubtitle: '3 days ago',
    recentAmount: 15000,
  ),
  _GroupProgressData(
    group: MemberGroups.demographics[1],
    amount: 182000,
    color: AppPallete.successGreen,
    target: 220000,
    recentTitle: 'Men’s breakfast',
    recentSubtitle: '1 week ago',
    recentAmount: 12000,
  ),
  _GroupProgressData(
    group: MemberGroups.demographics[2],
    amount: 75000,
    color: AppPallete.warningAmber,
    target: 120000,
    recentTitle: 'Youth outreach',
    recentSubtitle: '2 days ago',
    recentAmount: 5500,
  ),
];

final _ministryProgressData = [
  _GroupProgressData(
    group: MemberGroups.ministries[0],
    amount: 92000,
    color: AppPallete.tcBlueBright,
    target: 100000,
    recentTitle: 'Choir rehearsal offering',
    recentSubtitle: 'Yesterday',
    recentAmount: 8000,
  ),
  _GroupProgressData(
    group: MemberGroups.ministries[1],
    amount: 68000,
    color: const Color(0xFF8B5CF6),
    target: 90000,
    recentTitle: 'Deacon board pledge',
    recentSubtitle: '4 days ago',
    recentAmount: 10000,
  ),
  _GroupProgressData(
    group: MemberGroups.ministries[2],
    amount: 115000,
    color: AppPallete.successGreen,
    target: 130000,
    recentTitle: 'Elders support fund',
    recentSubtitle: '1 week ago',
    recentAmount: 20000,
  ),
  _GroupProgressData(
    group: MemberGroups.ministries[3],
    amount: 42000,
    color: const Color(0xFF14B8A6),
    target: 60000,
    recentTitle: 'Sanctuary upkeep',
    recentSubtitle: '5 days ago',
    recentAmount: 4500,
  ),
  _GroupProgressData(
    group: MemberGroups.ministries[4],
    amount: 58000,
    color: AppPallete.warningAmber,
    target: 70000,
    recentTitle: 'Usher team gift',
    recentSubtitle: '2 days ago',
    recentAmount: 6000,
  ),
  _GroupProgressData(
    group: MemberGroups.ministries[5],
    amount: 110000,
    color: const Color(0xFFEC4899),
    target: 125000,
    recentTitle: 'Media equipment fund',
    recentSubtitle: '3 days ago',
    recentAmount: 12500,
  ),
];
