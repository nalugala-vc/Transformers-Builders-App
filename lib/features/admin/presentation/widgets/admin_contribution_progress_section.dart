import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../../member/domain/models/church_progress_data.dart';
import '../../../member/domain/models/progress_breakdown_mode.dart';
import '../../../member/presentation/providers/member_progress_provider.dart';
import '../../../member/presentation/utils/church_progress_builder.dart';
import '../../../member/presentation/widgets/progress/progress_mode_switcher.dart';
import '../../../member/presentation/widgets/progress/progress_overview_card.dart';

/// Admin variant of the member Progress overview — same donut + segments
/// but always rendered with the *exact* per-group amounts so the admin can
/// scan totals without taps.
class AdminContributionProgressSection extends ConsumerWidget {
  const AdminContributionProgressSection({super.key, required this.data});

  final ChurchProgressData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final mode = ref.watch(progressBreakdownModeProvider);
    final snapshot = buildChurchProgressSnapshot(
      data: data,
      mode: mode,
      summaryTitle: mode == ProgressBreakdownMode.demographics
          ? l10n.totalsByDemographic
          : l10n.totalsByMinistry,
      summarySubtitle: '',
    );

    final selectedId = ref.watch(progressSelectedSegmentIdProvider);
    final effectiveSelectedId = selectedId ??
        (snapshot.segments.isNotEmpty ? snapshot.segments.first.id : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            l10n.adminContributionProgress,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppPallete.textPrimary,
            ),
          ),
        ),
        ProgressModeSwitcher(
          mode: mode,
          onModeChanged: (next) {
            ref.read(progressBreakdownModeProvider.notifier).state = next;
            ref.read(progressSelectedSegmentIdProvider.notifier).state = null;
          },
        ),
        const SizedBox(height: 12),
        ProgressOverviewCard(
          totalKes: snapshot.totalKes,
          monthlyChangeKes: snapshot.monthlyChangeKes,
          monthlyChangePercent: snapshot.monthlyChangePercent,
          segments: snapshot.segments,
          selectedSegmentId: effectiveSelectedId,
          onSegmentSelected: (id) {
            ref.read(progressSelectedSegmentIdProvider.notifier).state = id;
          },
        ),
      ],
    );
  }
}
