import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/app_route_paths.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../../../core/utils/theme/app_sizes.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/models/member_profile_settings.dart';
import '../../domain/models/member_profile_ui_state.dart';
import '../providers/member_profile_provider.dart';
import '../providers/member_profile_settings_provider.dart';
import '../widgets/profile/profile_edit_sheets.dart';
import '../widgets/profile/profile_header_card.dart';
import '../widgets/profile/profile_section_card.dart';

class MemberProfileTabScreen extends ConsumerWidget {
  const MemberProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final profileAsync = ref.watch(memberProfileUiProvider);

    return ColoredBox(
      color: AppPallete.scaffoldBg,
      child: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(child: Text(context.l10n.couldNotLoadProfile)),
          data: (profile) => _ProfileBody(profile: profile),
        ),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile});

  final MemberProfileUiState profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = profile;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final languageCode = locale.languageCode;
    final notificationsOn = ref.watch(memberPushNotificationsProvider);
    final languageLabel = MemberLanguageOptions.fromCode(languageCode, l10n).label;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              context.responsivePagePadding,
              20,
              context.responsivePagePadding,
              0,
            ),
            child: ProfileHeaderCard(
              initials: p.initials,
              fullName: p.fullName,
              email: p.email,
              phoneE164: p.phoneE164,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              context.responsivePagePadding,
              16,
              context.responsivePagePadding,
              0,
            ),
            child: ProfileSectionCard(
              title: l10n.sectionAccount,
              children: [
                ProfileMenuTile(
                  icon: Icons.person_outline_rounded,
                  title: l10n.name,
                  subtitle: p.fullName,
                  onTap: () => _editName(context, ref, p.fullName),
                ),
                const ProfileTileDivider(),
                ProfileMenuTile(
                  icon: Icons.email_outlined,
                  title: l10n.email,
                  subtitle: p.email,
                  onTap: () => _editEmail(context, ref, p),
                ),
                const ProfileTileDivider(),
                ProfileMenuTile(
                  icon: Icons.phone_outlined,
                  title: l10n.phone,
                  subtitle: p.phoneSubtitle(l10n),
                  onTap: () => _editPhone(context, ref, p.phoneE164),
                ),
                const ProfileTileDivider(),
                ProfileMenuTile(
                  icon: Icons.lock_outline_rounded,
                  title: l10n.password,
                  subtitle: p.passwordSubtitleLocalized(l10n),
                  onTap: () => _editPassword(context, ref, p),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              context.responsivePagePadding,
              16,
              context.responsivePagePadding,
              0,
            ),
            child: ProfileSectionCard(
              title: l10n.sectionChurchGroups,
              children: [
                ProfileMenuTile(
                  icon: Icons.groups_outlined,
                  title: l10n.demographic,
                  subtitle: p.demographicSubtitle(l10n),
                  onTap: () => _editGroups(context, ref, p),
                ),
                const ProfileTileDivider(),
                ProfileMenuTile(
                  icon: Icons.church_outlined,
                  title: l10n.ministry,
                  subtitle: p.ministrySubtitle(l10n),
                  onTap: () => _editGroups(context, ref, p),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              context.responsivePagePadding,
              16,
              context.responsivePagePadding,
              0,
            ),
            child: ProfileSectionCard(
              title: l10n.sectionPreferences,
              children: [
                ProfileMenuTile(
                  icon: Icons.language_rounded,
                  title: l10n.language,
                  subtitle: languageLabel,
                  onTap: () => showLanguagePickerSheet(
                    context: context,
                    ref: ref,
                    currentCode: languageCode,
                  ),
                ),
                const ProfileTileDivider(),
                ProfileMenuTile(
                  icon: Icons.notifications_outlined,
                  title: l10n.notifications,
                  subtitle: notificationsOn ? l10n.notificationsEnabled : l10n.notificationsDisabled,
                  showChevron: false,
                  trailing: Transform.scale(
                    scale: 0.9,
                    child: CupertinoSwitch(
                      value: notificationsOn,
                      activeTrackColor: AppPallete.tcBlueBright,
                      onChanged: (value) {
                        ref.read(memberPushNotificationsProvider.notifier).state = value;
                        ref.invalidate(memberProfileUiProvider);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              context.responsivePagePadding,
              16,
              context.responsivePagePadding,
              0,
            ),
            child: ProfileSectionCard(
              title: l10n.sectionSupport,
              children: [
                ProfileMenuTile(
                  icon: Icons.help_outline_rounded,
                  title: l10n.helpSupport,
                  subtitle: l10n.helpSupportSubtitle,
                  onTap: () {
                    showAppInfoToast(context, l10n.comingSoon(l10n.helpSupport));
                  },
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              context.responsivePagePadding,
              16,
              context.responsivePagePadding,
              0,
            ),
            child: ProfileSectionCard(
              title: l10n.sectionAbout,
              children: [
                ProfileMenuTile(
                  icon: Icons.info_outline_rounded,
                  title: l10n.appVersion,
                  subtitle: p.appVersionLabel,
                  showChevron: false,
                  onTap: null,
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              context.responsivePagePadding,
              20,
              context.responsivePagePadding,
              32,
            ),
            child: _LogoutButton(
              label: l10n.logOut,
              onPressed: () => _logout(context, ref),
            ),
          ),
        ),
      ],
    );
  }

  void _editName(BuildContext context, WidgetRef ref, String current) {
    final l10n = context.l10n;
    showEditTextProfileSheet(
      context: context,
      title: l10n.editName,
      label: l10n.fullName,
      initialValue: current,
      hint: l10n.yourFullName,
      onSave: (value) => updateMemberFullName(ref, l10n, value),
    );
  }

  Future<void> _editEmail(
    BuildContext context,
    WidgetRef ref,
    MemberProfileUiState profile,
  ) async {
    final success = await showEditEmailSheet(
      context: context,
      currentEmail: profile.email,
      requiresPasswordReauth: profile.canChangePassword,
    );
    if (success == true && context.mounted) {
      showAppSuccessToast(context, context.l10n.emailConfirmationSent);
    }
  }

  Future<void> _editPhone(
    BuildContext context,
    WidgetRef ref,
    String? phoneE164,
  ) async {
    final success = await showEditPhoneSheet(
      context: context,
      phoneE164: phoneE164,
    );
    if (success == true && context.mounted) {
      showAppSuccessToast(context, context.l10n.phoneUpdated);
    }
  }

  Future<void> _editGroups(
    BuildContext context,
    WidgetRef ref,
    MemberProfileUiState profile,
  ) async {
    final success = await showEditMemberGroupsSheet(
      context: context,
      demographicGroupId: profile.demographicGroupId,
      ministryGroupId: profile.ministryGroupId,
    );
    if (success == true && context.mounted) {
      showAppSuccessToast(context, context.l10n.groupsUpdated);
    }
  }

  Future<void> _editPassword(
    BuildContext context,
    WidgetRef ref,
    MemberProfileUiState profile,
  ) async {
    final bool? success;
    if (profile.canChangePassword) {
      success = await showChangePasswordSheet(
        context: context,
        email: profile.email,
      );
    } else {
      success = await showPasswordManagedExternallySheet(
        context: context,
        email: profile.email,
        usesGoogleSignIn: profile.usesGoogleSignIn,
      );
    }
    if (success == true && context.mounted) {
      showAppSuccessToast(
        context,
        profile.canChangePassword
            ? context.l10n.passwordUpdated
            : context.l10n.passwordLinkSent,
      );
    }
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showLogoutConfirmDialog(context);
    if (confirmed != true || !context.mounted) return;
    await ref.read(authRepositoryProvider).signOut();
    if (!context.mounted) return;
    context.go(AppRoutePaths.login);
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: Text(
          label,
          style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppPallete.tcRed,
          side: const BorderSide(color: AppPallete.tcRed),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
