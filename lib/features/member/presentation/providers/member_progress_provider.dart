import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/models/contribution_segment.dart';
import '../../domain/models/progress_breakdown_mode.dart';
import '../utils/church_progress_builder.dart';
import 'member_contribution_providers.dart';

export '../../domain/models/contribution_segment.dart' show ChurchProgressSnapshot;

final progressBreakdownModeProvider = StateProvider<ProgressBreakdownMode>(
  (ref) => ProgressBreakdownMode.demographics,
);

final progressSelectedSegmentIdProvider = StateProvider<String?>((ref) => null);

final churchProgressSnapshotProvider = FutureProvider<ChurchProgressSnapshot>((ref) async {
  final mode = ref.watch(progressBreakdownModeProvider);
  final data =
      await ref.read(memberContributionRepositoryProvider).getChurchProgressData();

  return buildChurchProgressSnapshot(
    data: data,
    mode: mode,
    summaryTitle: mode == ProgressBreakdownMode.demographics
        ? 'Church-wide summary'
        : 'Ministry summary',
    summarySubtitle: mode == ProgressBreakdownMode.demographics
        ? 'Totals by Women, Men, and Youth across the church.'
        : 'Totals by ministry teams across the church.',
  );
});

final progressSelectedSegmentProvider = Provider<ContributionSegment?>((ref) {
  final snapshotAsync = ref.watch(churchProgressSnapshotProvider);
  final snapshot = snapshotAsync.maybeWhen(data: (v) => v, orElse: () => null);
  if (snapshot == null || snapshot.segments.isEmpty) return null;

  final selectedId = ref.watch(progressSelectedSegmentIdProvider);
  if (selectedId != null) {
    for (final segment in snapshot.segments) {
      if (segment.id == selectedId) return segment;
    }
  }
  return snapshot.segments.first;
});
