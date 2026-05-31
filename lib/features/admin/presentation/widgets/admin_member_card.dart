import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../domain/models/admin_member_list_item.dart';
import '../../../member/presentation/utils/member_formatters.dart';

typedef AdminMemberCardAction = void Function(AdminMemberCardActionKind kind);

enum AdminMemberCardActionKind { profile, message, remove }

class AdminMemberCard extends StatelessWidget {
  const AdminMemberCard({
    super.key,
    required this.member,
    required this.onAction,
  });

  final AdminMemberListItem member;
  final AdminMemberCardAction onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Material(
      color: AppPallete.tcWhite,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onAction(AdminMemberCardActionKind.profile),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppPallete.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MemberAvatar(initials: member.initials),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.fullName,
                            style: GoogleFonts.dmSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppPallete.textPrimary,
                            ),
                          ),
                          if (member.email.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            _ContactRow(
                              icon: Icons.mail_outline_rounded,
                              text: member.email,
                            ),
                          ],
                          if (member.phoneE164 != null &&
                              member.phoneE164!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            _ContactRow(
                              icon: Icons.phone_outlined,
                              text: member.phoneE164!,
                            ),
                          ],
                        ],
                      ),
                    ),
                    PopupMenuButton<AdminMemberCardActionKind>(
                      icon: Icon(
                        Icons.more_horiz_rounded,
                        color: AppPallete.textMuted.withValues(alpha: 0.8),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: onAction,
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: AdminMemberCardActionKind.profile,
                          child: Text(l10n.adminMemberActionProfile),
                        ),
                        PopupMenuItem(
                          value: AdminMemberCardActionKind.message,
                          child: Text(l10n.adminMemberActionMessage),
                        ),
                        PopupMenuItem(
                          value: AdminMemberCardActionKind.remove,
                          child: Text(
                            l10n.adminMemberActionRemove,
                            style: const TextStyle(color: AppPallete.tcRed),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppPallete.cardBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Text(
                            l10n.adminContributionProgress,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppPallete.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppPallete.tcBlueBright.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${member.progressPercent}%',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppPallete.tcBlueBright,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: member.progressFraction,
                          minHeight: 8,
                          backgroundColor: AppPallete.progressTrack,
                          color: AppPallete.tcBlueBright,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            formatKes(member.raisedKes),
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppPallete.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            l10n.adminMemberTargetLabel(
                              formatKes(member.targetKes),
                            ),
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: AppPallete.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Divider(height: 1, color: AppPallete.border),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.person_outline_rounded,
                        label: l10n.adminMemberActionProfile,
                        color: AppPallete.tcBlueBright,
                        onTap: () =>
                            onAction(AdminMemberCardActionKind.profile),
                      ),
                    ),
                    const VerticalDivider(width: 1, color: AppPallete.border),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: l10n.adminMemberActionMessage,
                        color: AppPallete.tcBlueBright,
                        onTap: () =>
                            onAction(AdminMemberCardActionKind.message),
                      ),
                    ),
                    const VerticalDivider(width: 1, color: AppPallete.border),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.delete_outline_rounded,
                        label: l10n.adminMemberActionRemove,
                        color: AppPallete.tcRed,
                        onTap: () =>
                            onAction(AdminMemberCardActionKind.remove),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppPallete.tcBlueBright, AppPallete.tcBlueBrightDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppPallete.tcBlueBright.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.dmSans(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppPallete.tcWhite,
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppPallete.textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppPallete.textMuted,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
