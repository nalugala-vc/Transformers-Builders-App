import 'package:flutter/material.dart';

import '../../../../core/utils/theme/app_pallete.dart';
import '../../domain/models/church_progress_data.dart';
import '../../domain/models/contribution_segment.dart';
import '../../domain/models/member_group.dart';
import '../../domain/models/progress_breakdown_mode.dart';

class _GroupProgressMeta {
  const _GroupProgressMeta({required this.group, required this.color});

  final MemberGroup group;
  final Color color;
}

final _demographicProgressMeta = [
  _GroupProgressMeta(
    group: MemberGroups.demographics[0],
    color: AppPallete.tcBlueBright,
  ),
  _GroupProgressMeta(
    group: MemberGroups.demographics[1],
    color: AppPallete.successGreen,
  ),
  _GroupProgressMeta(
    group: MemberGroups.demographics[2],
    color: AppPallete.warningAmber,
  ),
];

final _ministryProgressMeta = [
  _GroupProgressMeta(
    group: MemberGroups.ministries[0],
    color: AppPallete.tcBlueBright,
  ),
  _GroupProgressMeta(
    group: MemberGroups.ministries[1],
    color: Color(0xFF8B5CF6),
  ),
  _GroupProgressMeta(
    group: MemberGroups.ministries[2],
    color: AppPallete.successGreen,
  ),
  _GroupProgressMeta(
    group: MemberGroups.ministries[3],
    color: Color(0xFF14B8A6),
  ),
  _GroupProgressMeta(
    group: MemberGroups.ministries[4],
    color: AppPallete.warningAmber,
  ),
  _GroupProgressMeta(
    group: MemberGroups.ministries[5],
    color: Color(0xFFEC4899),
  ),
];

/// Builds the [ChurchProgressSnapshot] for the Progress tab using live
/// per-group targets (sum of members' personal goals) from Firestore.
ChurchProgressSnapshot buildChurchProgressSnapshot({
  required ChurchProgressData data,
  required ProgressBreakdownMode mode,
  required String summaryTitle,
  required String summarySubtitle,
}) {
  final meta = mode == ProgressBreakdownMode.demographics
      ? _demographicProgressMeta
      : _ministryProgressMeta;
  final ministry = mode == ProgressBreakdownMode.ministries;

  final segments = meta
      .map(
        (entry) => ContributionSegment(
          id: entry.group.id,
          label: entry.group.label,
          amountKes: data.amountForGroup(entry.group.id, ministry: ministry),
          color: entry.color,
          targetKes: data.targetForGroup(entry.group.id, ministry: ministry),
        ),
      )
      .toList();

  return ChurchProgressSnapshot(
    totalKes: data.totalKes,
    monthlyChangeKes: 0,
    monthlyChangePercent: 0,
    summaryTitle: summaryTitle,
    summarySubtitle: summarySubtitle,
    segments: segments,
  );
}
