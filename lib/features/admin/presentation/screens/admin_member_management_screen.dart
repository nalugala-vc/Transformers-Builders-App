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
import '../../domain/models/admin_shell_view.dart';
import '../providers/admin_member_providers.dart';
import '../providers/admin_shell_providers.dart';
import '../widgets/admin_blue_title_bar.dart';
import '../widgets/admin_member_card.dart';
import '../widgets/admin_remove_member_dialog.dart';

class AdminMemberManagementScreen extends ConsumerStatefulWidget {
  const AdminMemberManagementScreen({super.key});

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

    return ColoredBox(
      color: AppPallete.scaffoldBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminBlueTitleBar(
            title: l10n.adminChurchMembers,
            onBack: () {
              ref.read(adminShellViewProvider.notifier).state =
                  AdminShellView.dashboard;
            },
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.responsivePagePadding,
              16,
              context.responsivePagePadding,
              8,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: l10n.adminSearchMembersHint,
                hintStyle: GoogleFonts.dmSans(color: AppPallete.textMuted),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppPallete.textMuted,
                ),
                filled: true,
                fillColor: AppPallete.tcWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppPallete.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppPallete.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppPallete.tcBlueLight),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          membersAsync.when(
            loading: () => const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(context.responsivePagePadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.adminMembersLoadError,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(color: AppPallete.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => refreshAdminMembers(ref),
                        child: Text(l10n.tryAgain),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            data: (members) {
              final filtered = _filter(members);
              return Expanded(
                child: RefreshIndicator(
                  onRefresh: () => refreshAdminMembers(ref),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12, top: 4),
                          child: Text(
                            l10n.adminMembersFoundCount(filtered.length),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: AppPallete.textMuted,
                            ),
                          ),
                        ),
                      ),
                      if (filtered.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(
                              l10n.adminMembersSearchEmpty,
                              style: GoogleFonts.dmSans(
                                color: AppPallete.textSecondary,
                              ),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            context.responsivePagePadding,
                            0,
                            context.responsivePagePadding,
                            24,
                          ),
                          sliver: SliverList.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final member = filtered[index];
                              return AdminMemberCard(
                                member: member,
                                onAction: (kind) => _handleAction(member, kind),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
