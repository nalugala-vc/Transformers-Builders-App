import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/navigation/auth_navigation.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../../../core/utils/theme/app_sizes.dart';
import '../../../member/domain/models/member_group.dart';
import '../auth_assets.dart';
import '../providers/user_profile_providers.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/member_group_fields.dart';

/// Shown after first sign-in (e.g. Google) when demographic and ministry
/// groups are not yet saved on the member profile.
class MemberGroupPickerScreen extends ConsumerStatefulWidget {
  const MemberGroupPickerScreen({super.key});

  @override
  ConsumerState<MemberGroupPickerScreen> createState() =>
      _MemberGroupPickerScreenState();
}

class _MemberGroupPickerScreenState extends ConsumerState<MemberGroupPickerScreen> {
  String? _demographicGroupId;
  String? _ministryGroupId;

  bool _saving = false;
  String? _demographicError;
  String? _ministryError;
  String? _formError;

  Future<void> _onContinue() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _formError = context.l10n.errorSomethingWrong);
      return;
    }

    final demographic = MemberGroups.findDemographicById(_demographicGroupId);
    final ministryId = _ministryGroupId?.trim();
    final ministry = ministryId == null || ministryId.isEmpty
        ? null
        : MemberGroups.findMinistryById(ministryId);

    setState(() {
      final l10n = context.l10n;
      _demographicError =
          demographic == null ? l10n.errorSelectDemographic : null;
      _ministryError = ministryId != null && ministryId.isNotEmpty && ministry == null
          ? l10n.errorValidMinistry
          : null;
      _formError = null;
    });

    if (demographic == null) return;

    setState(() => _saving = true);

    try {
      await ref.read(userProfileRepositoryProvider).setMemberGroups(
            uid: user.uid,
            demographicGroupId: demographic.id,
            ministryGroupId: ministry?.id,
          );
      if (!mounted) return;
      await navigateToRoleHome(context, ref);
    } catch (_) {
      if (!mounted) return;
      setState(() => _formError = context.l10n.errorCouldNotUpdateGroups);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const maxContentWidth = 420.0;

    return Scaffold(
      backgroundColor: AppPallete.tcWhite,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsivePagePadding,
                vertical: AppSizes.s24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset(
                      AuthAssets.tcLogo,
                      height: context.scaled.h72,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: context.scaled.h24),
                  AuthHeader(
                    title: context.l10n.authPickGroupsTitle,
                    subtitle: context.l10n.authPickGroupsSubtitle,
                  ),
                  SizedBox(height: context.scaled.h24),
                  MemberGroupFields(
                    demographicGroupId: _demographicGroupId,
                    ministryGroupId: _ministryGroupId,
                    demographicError: _demographicError,
                    ministryError: _ministryError,
                    enabled: !_saving,
                    onDemographicChanged: (id) =>
                        setState(() => _demographicGroupId = id),
                    onMinistryChanged: (id) => setState(() => _ministryGroupId = id),
                  ),
                  if (_formError != null) ...[
                    SizedBox(height: context.scaled.h16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppPallete.tcRed.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppPallete.tcRed.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        _formError!,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: AppPallete.tcRed,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: context.scaled.h24),
                  AuthPrimaryButton(
                    label: context.l10n.authContinue,
                    isLoading: _saving,
                    onPressed: _onContinue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
