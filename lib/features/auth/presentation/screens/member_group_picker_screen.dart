import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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
      setState(() => _formError = 'You are signed out. Please sign in again.');
      return;
    }

    final demographic = MemberGroups.findDemographicById(_demographicGroupId);
    final ministryId = _ministryGroupId?.trim();
    final ministry = ministryId == null || ministryId.isEmpty
        ? null
        : MemberGroups.findMinistryById(ministryId);

    setState(() {
      _demographicError =
          demographic == null ? 'Select your demographic group' : null;
      _ministryError = ministryId != null && ministryId.isNotEmpty && ministry == null
          ? 'Select a valid ministry'
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
      setState(() => _formError = 'Could not save your groups. Please try again.');
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
                  const AuthHeader(
                    title: 'Choose your groups',
                    subtitle:
                        'Select your demographic group (required). '
                        'Add a ministry if you serve on a team — for example Choir or Ushers.',
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
                    label: 'Continue',
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
