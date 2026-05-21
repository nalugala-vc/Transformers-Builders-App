import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/theme/app_pallete.dart';
import '../../../../core/utils/theme/app_sizes.dart';
import '../providers/member_home_provider.dart';
import '../providers/member_progress_provider.dart';
import '../widgets/home/set_contribution_goal_sheet.dart';
import '../widgets/progress/church_progress_empty_state.dart';
import '../widgets/progress/progress_mode_switcher.dart';
import '../widgets/progress/progress_overview_card.dart';
import '../widgets/progress/progress_segment_detail_card.dart';
import '../widgets/progress/progress_summary_card.dart';

class MemberProgressTabScreen extends ConsumerWidget {
  const MemberProgressTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(progressBreakdownModeProvider);
    final snapshot = ref.watch(churchProgressSnapshotProvider);
    final selected = ref.watch(progressSelectedSegmentProvider);
    final selectedId = ref.watch(progressSelectedSegmentIdProvider);

    final effectiveSelectedId = selectedId ??
        (snapshot.segments.isNotEmpty ? snapshot.segments.first.id : null);
    final showEmptyState = !snapshot.hasContributions;

    return ColoredBox(
      color: AppPallete.scaffoldBg,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  context.responsivePagePadding,
                  16,
                  context.responsivePagePadding,
                  0,
                ),
                child: ProgressModeSwitcher(
                  mode: mode,
                  onModeChanged: (next) {
                    ref.read(progressBreakdownModeProvider.notifier).state = next;
                    final segments = ref.read(churchProgressSnapshotProvider).segments;
                    ref.read(progressSelectedSegmentIdProvider.notifier).state =
                        segments.isEmpty ? null : segments.first.id;
                  },
                ),
              ),
            ),
            if (showEmptyState)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.responsivePagePadding,
                    16,
                    context.responsivePagePadding,
                    32,
                  ),
                  child: ChurchProgressEmptyState(
                    mode: mode,
                    onStartContributing: () => _onStartContributing(context, ref),
                  ),
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.responsivePagePadding,
                    16,
                    context.responsivePagePadding,
                    0,
                  ),
                  child: ProgressOverviewCard(
                    totalKes: snapshot.totalKes,
                    monthlyChangeKes: snapshot.monthlyChangeKes,
                    monthlyChangePercent: snapshot.monthlyChangePercent,
                    segments: snapshot.segments,
                    selectedSegmentId: effectiveSelectedId,
                    onSegmentSelected: (id) {
                      ref.read(progressSelectedSegmentIdProvider.notifier).state = id;
                    },
                  ),
                ),
              ),
              if (selected != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.responsivePagePadding,
                      16,
                      context.responsivePagePadding,
                      0,
                    ),
                    child: ProgressSegmentDetailCard(
                      segment: selected,
                      monthlyChangePercent: snapshot.monthlyChangePercent,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.responsivePagePadding,
                    16,
                    context.responsivePagePadding,
                    32,
                  ),
                  child: ProgressSummaryCard(
                    title: snapshot.summaryTitle,
                    subtitle: snapshot.summarySubtitle,
                    segments: snapshot.segments,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onStartContributing(BuildContext context, WidgetRef ref) {
    final home = ref.read(memberHomeUiProvider).maybeWhen(
          data: (state) => state,
          orElse: () => null,
        );
    if (home == null || !home.hasContributionGoal) {
      showSetContributionGoalSheet(context);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contribution page coming soon')),
    );
  }
}
