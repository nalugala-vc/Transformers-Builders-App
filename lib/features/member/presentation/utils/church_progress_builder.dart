import 'package:flutter/material.dart';

import '../../../../core/utils/theme/app_pallete.dart';
import '../../domain/models/church_progress_data.dart';
import '../../domain/models/contribution_segment.dart';
import '../../domain/models/member_group.dart';
import '../../domain/models/progress_breakdown_mode.dart';

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
    color: Color(0xFF8B5CF6),
    target: 90000,
  ),
  _GroupProgressMeta(
    group: MemberGroups.ministries[2],
    color: AppPallete.successGreen,
    target: 130000,
  ),
  _GroupProgressMeta(
    group: MemberGroups.ministries[3],
    color: Color(0xFF14B8A6),
    target: 60000,
  ),
  _GroupProgressMeta(
    group: MemberGroups.ministries[4],
    color: AppPallete.warningAmber,
    target: 70000,
  ),
  _GroupProgressMeta(
    group: MemberGroups.ministries[5],
    color: Color(0xFFEC4899),
    target: 125000,
  ),
];

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
          targetKes: entry.target,
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
