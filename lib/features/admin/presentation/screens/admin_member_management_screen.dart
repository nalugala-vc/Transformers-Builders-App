import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/app_route_paths.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../../../core/utils/theme/app_sizes.dart';
import '../../domain/models/admin_member_list_item.dart';
import '../providers/admin_member_providers.dart';
import '../widgets/admin_member_card.dart';
import '../widgets/admin_remove_member_dialog.dart';
import '../widgets/admin_shell_menu_bar.dart';

class AdminMemberManagementScreen extends ConsumerStatefulWidget {
  const AdminMemberManagementScreen({
    super.key,
    required this.onOpenDrawer,
  });

  final VoidCallback onOpenDrawer;

  @override
  ConsumerState<AdminMemberManagementScreen> createState() =>
      _AdminMemberManagementScreenState();
}

class _AdminMemberManagementScreenState
    extends ConsumerState<AdminMemberManagementScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AdminMemberListItem> _filter(List<AdminMemberListItem> members) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return members;
    return members.where((member) {
      return member.fullName.toLowerCase().contains(q) ||
          member.email.toLowerCase().contains(q) ||
          (member.phoneE164?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  Future<void> _handleAction(
    AdminMemberListItem member,
    AdminMemberCardActionKind kind,
  ) async {
    switch (kind) {
      case AdminMemberCardActionKind.profile:
        context.push('${AppRoutePaths.adminHome}/members/${member.uid}');
      case AdminMemberCardActionKind.message:
        showAppInfoToast(context, context.l10n.adminMemberMessageComingSoon);
      case AdminMemberCardActionKind.remove:
        await _confirmRemove(member);
    }
  }

  Future<void> _confirmRemove(AdminMemberListItem member) async {
    final confirmed = await showAdminRemoveMemberDialog(
      context,
      memberName: member.fullName,
    );
    if (confirmed != true || !mounted) return;

    final err = await deactivateAdminMember(ref, uid: member.uid);
    if (!mounted) return;
    if (err != null) {
      showAppErrorToast(context, context.l10n.adminRemoveMemberFailed);
    } else {
      showAppSuccessToast(
        context,
        context.l10n.adminMemberRemoved(member.fullName),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final membersAsync = ref.watch(adminMembersProvider);
    final pagePadding = context.responsivePagePadding;

    return ColoredBox(
      color: AppPallete.scaffoldBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminShellMenuBar(
            onOpenDrawer: widget.onOpenDrawer,
            title: l10n.adminChurchMembers,
            subtitle: l10n.adminMembersManageSubtitle,
          ),
          Expanded(
            child: membersAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppPallete.tcBlueBright),
              ),
              error: (error, stackTrace) => _ErrorState(
                message: l10n.adminMembersLoadError,
                onRetry: () => refreshAdminMembers(ref),
              ),
              data: (members) {
                final filtered = _filter(members);

                return RefreshIndicator(
                  color: AppPallete.tcBlueBright,
                  onRefresh: () => refreshAdminMembers(ref),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            pagePadding,
                            16,
                            pagePadding,
                            8,
                          ),
                          child: _SearchField(
                            controller: _searchController,
                            hint: l10n.adminSearchMembersHint,
                            onChanged: (value) => setState(() => _query = value),
                            onClear: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            showClear: _query.isNotEmpty,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            pagePadding,
                            4,
                            pagePadding,
                            16,
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppPallete.tcWhite,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppPallete.border),
                              ),
                              child: Text(
                                l10n.adminMembersFoundCount(filtered.length),
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppPallete.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (filtered.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptyState(
                            isSearching: _query.trim().isNotEmpty,
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            pagePadding,
                            0,
                            pagePadding,
                            24,
                          ),
                          sliver: SliverList.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final member = filtered[index];
                              return AdminMemberCard(
                                member: member,
                                onAction: (kind) =>
                                    _handleAction(member, kind),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onClear,
    required this.showClear,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool showClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPallete.tcWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPallete.border),
        boxShadow: [
          BoxShadow(
            color: AppPallete.textPrimary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.dmSans(
          fontSize: 15,
          color: AppPallete.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(
            fontSize: 15,
            color: AppPallete.textMuted,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppPallete.textMuted,
            size: 22,
          ),
          suffixIcon: showClear
              ? IconButton(
                  onPressed: onClear,
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: AppPallete.textMuted,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isSearching});

  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.responsivePagePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppPallete.tcBlueBright.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isSearching ? Icons.search_off_rounded : Icons.groups_outlined,
                color: AppPallete.tcBlueBright,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? l10n.adminMembersSearchEmpty
                  : l10n.adminMembersFoundCount(0),
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppPallete.textPrimary,
              ),
            ),
            if (!isSearching) ...[
              const SizedBox(height: 6),
              Text(
                l10n.adminMembersManageSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppPallete.textMuted,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.responsivePagePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppPallete.errorRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppPallete.errorRed,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                color: AppPallete.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppPallete.tcBlueBright,
                foregroundColor: AppPallete.tcWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
