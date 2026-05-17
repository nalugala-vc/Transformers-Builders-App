import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/app_route_paths.dart';
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
    final profileAsync = ref.watch(memberProfileUiProvider);

    return ColoredBox(
      color: AppPallete.scaffoldBg,
      child: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(child: Text('Could not load profile')),
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
    final languageCode = ref.watch(memberLanguageCodeProvider);
    final notificationsOn = ref.watch(memberPushNotificationsProvider);
    final languageLabel = MemberLanguageOptions.fromCode(languageCode).label;

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
              title: 'ACCOUNT',
              children: [
                ProfileMenuTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Name',
                  subtitle: p.fullName,
                  onTap: () => _editName(context, ref, p.fullName),
                ),
                const ProfileTileDivider(),
                ProfileMenuTile(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: p.email,
                  onTap: () => _editEmail(context, p.email),
                ),
                const ProfileTileDivider(),
                ProfileMenuTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Password',
                  subtitle: '••••••••',
                  onTap: () => _editPassword(context),
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
              title: 'PREFERENCES',
              children: [
                ProfileMenuTile(
                  icon: Icons.language_rounded,
                  title: 'Language',
                  subtitle: languageLabel,
                  onTap: () => showLanguagePickerSheet(
                    context: context,
                    currentCode: languageCode,
                    onSelected: (code) {
                      ref.read(memberLanguageCodeProvider.notifier).state = code;
                      ref.invalidate(memberProfileUiProvider);
                    },
                  ),
                ),
                const ProfileTileDivider(),
                ProfileMenuTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: notificationsOn ? 'Enabled' : 'Disabled',
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
              title: 'SUPPORT',
              children: [
                ProfileMenuTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  subtitle: 'FAQs, contact us',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help & Support coming soon')),
                    );
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
              title: 'ABOUT',
              children: [
                ProfileMenuTile(
                  icon: Icons.info_outline_rounded,
                  title: 'App version',
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
              onPressed: () => _logout(context, ref),
            ),
          ),
        ),
      ],
    );
  }

  void _editName(BuildContext context, WidgetRef ref, String current) {
    showEditTextProfileSheet(
      context: context,
      title: 'Edit name',
      label: 'Full name',
      initialValue: current,
      hint: 'Your full name',
      onSave: (value) => updateMemberFullName(ref, value),
    );
  }

  void _editEmail(BuildContext context, String current) {
    showEditTextProfileSheet(
      context: context,
      title: 'Edit email',
      label: 'Email address',
      initialValue: current,
      keyboardType: TextInputType.emailAddress,
      onSave: (_) async {
        return 'Email updates will be available in a future release';
      },
    );
  }

  void _editPassword(BuildContext context) {
    showEditTextProfileSheet(
      context: context,
      title: 'Change password',
      label: 'New password',
      initialValue: '',
      hint: 'At least 8 characters',
      obscureText: true,
      onSave: (_) async {
        return 'Password updates will be available in a future release';
      },
    );
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
  const _LogoutButton({required this.onPressed});

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
          'Log out',
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
