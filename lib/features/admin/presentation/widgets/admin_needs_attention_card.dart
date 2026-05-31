import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../domain/models/admin_attention_item.dart';

class AdminNeedsAttentionCard extends StatelessWidget {
  const AdminNeedsAttentionCard({
    super.key,
    required this.items,
    required this.onItemTap,
  });

  final List<AdminAttentionItem> items;
  final ValueChanged<AdminAttentionItem> onItemTap;

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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.priority_high_rounded,
                  size: 18,
                  color: AppPallete.warningAmber,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.adminNeedsAttention,
                  style: GoogleFonts.dmSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppPallete.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppPallete.successGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                      color: AppPallete.successGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.adminAttentionEmpty,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppPallete.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    _AttentionTile(
                      item: items[i],
                      onTap: () => onItemTap(items[i]),
                    ),
                    if (i != items.length - 1)
                      const Divider(height: 1, color: AppPallete.border),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _AttentionTile extends StatelessWidget {
  const _AttentionTile({required this.item, required this.onTap});

  final AdminAttentionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _visualFor(item.kind);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppPallete.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppPallete.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppPallete.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  (IconData, Color) _visualFor(AdminAttentionKind kind) {
    return switch (kind) {
      AdminAttentionKind.pendingAdminRequest => (
          Icons.shield_outlined,
          AppPallete.warningAmber
        ),
      AdminAttentionKind.pendingMemberApproval => (
          Icons.person_add_outlined,
          AppPallete.tcBlueBright
        ),
      AdminAttentionKind.announcementDraft => (
          Icons.campaign_outlined,
          AppPallete.tcBlueLight
        ),
    };
  }
}
