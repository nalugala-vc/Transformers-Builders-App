import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../../member/presentation/utils/member_formatters.dart';
import '../../domain/models/admin_recent_activity.dart';

class AdminRecentActivityCard extends StatelessWidget {
  const AdminRecentActivityCard({
    super.key,
    required this.activities,
    required this.onActivityTap,
    this.onSeeAll,
  });

  final List<AdminRecentActivity> activities;
  final ValueChanged<AdminRecentActivity> onActivityTap;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppPallete.tcWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPallete.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.recentActivity,
                    style: GoogleFonts.dmSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppPallete.textPrimary,
                    ),
                  ),
                ),
                if (onSeeAll != null)
                  InkWell(
                    onTap: onSeeAll,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 6,
                      ),
                      child: Text(
                        l10n.seeAll,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppPallete.tcBlueBright,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (activities.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Text(
                l10n.adminRecentActivityEmpty,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppPallete.textMuted,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                final isLast = index == activities.length - 1;
                return _ActivityTile(
                  activity: activity,
                  isLast: isLast,
                  onTap: () => onActivityTap(activity),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.activity,
    required this.isLast,
    required this.onTap,
  });

  final AdminRecentActivity activity;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _visualFor(activity.type);
    final amount = activity.amountKes;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 16, isLast ? 12 : 0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 20, color: color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppPallete.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${activity.subtitle} · ${formatActivityDate(activity.occurredAt)}',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppPallete.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (amount != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 4),
                      child: Text(
                        formatKes(amount),
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppPallete.textPrimary,
                        ),
                      ),
                    ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppPallete.textMuted.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
            if (!isLast)
              const Divider(height: 1, indent: 54, color: AppPallete.border),
          ],
        ),
      ),
    );
  }

  (IconData, Color) _visualFor(AdminRecentActivityType type) {
    return switch (type) {
      AdminRecentActivityType.memberContribution => (
          Icons.payments_outlined,
          AppPallete.tcBlueBright
        ),
      AdminRecentActivityType.adminRequest => (
          Icons.shield_outlined,
          AppPallete.warningAmber
        ),
      AdminRecentActivityType.announcement => (
          Icons.campaign_outlined,
          AppPallete.successGreen
        ),
    };
  }
}
