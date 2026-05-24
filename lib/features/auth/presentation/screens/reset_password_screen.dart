import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/app_route_paths.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../../../core/utils/theme/app_sizes.dart';
import '../auth_assets.dart';
import '../view_models/reset_password_view_model.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';

/// Complete password reset using the action [initialCode] from the Firebase email.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({
    super.key,
    this.initialEmail,
    this.initialCode,
  });

  final String? initialEmail;
  final String? initialCode;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    final presetCode = widget.initialCode?.trim();
    if (presetCode != null && presetCode.isNotEmpty) {
      _code.text = presetCode;
    }
  }

  @override
  void dispose() {
    _code.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    FocusScope.of(context).unfocus();
    final vm = ref.read(resetPasswordViewModelProvider);
    final ok = await vm.submit(
      code: _code.text,
      password: _password.text,
      confirmPassword: _confirmPassword.text,
    );
    if (!mounted) return;
    if (ok) {
      showAppSuccessToast(
        context,
        'Password updated. You can sign in with your new password.',
      );
      context.go(AppRoutePaths.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    const maxContentWidth = 420.0;
    final vm = ref.watch(resetPasswordViewModelProvider);
    final emailHint = widget.initialEmail?.trim();

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
                      AuthAssets.passwordIcon,
                      height: context.scaled.h80,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: context.scaled.h24),
                  AuthHeader(
                    title: 'Set new password',
                    subtitle: emailHint != null && emailHint.isNotEmpty
                        ? 'Enter the reset code from the email sent to $emailHint, then choose a new password.'
                        : 'Enter the reset code from your email, then choose a new password.',
                  ),
                  SizedBox(height: context.scaled.h12),
                  Text(
                    'Open the reset email and tap the link to open this screen with the code filled in. '
                    'You can also copy the long code from the link and paste it below.',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppPallete.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  if (vm.formError != null) ...[
                    SizedBox(height: context.scaled.h16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppPallete.tcRed.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppPallete.tcRed.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        vm.formError!,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: AppPallete.tcRed,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: context.scaled.h24),
                  AuthTextField(
                    controller: _code,
                    label: 'Reset code',
                    hint: 'Paste code from email link',
                    errorText: vm.codeError,
                    autocorrect: false,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: context.scaled.h16),
                  AuthTextField(
                    controller: _password,
                    label: 'New password',
                    hint: 'At least 8 characters',
                    errorText: vm.passwordError,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                  ),
                  SizedBox(height: context.scaled.h16),
                  AuthTextField(
                    controller: _confirmPassword,
                    label: 'Confirm password',
                    obscureText: true,
                    errorText: vm.confirmPasswordError,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    onSubmitted: (_) => _onSubmit(),
                  ),
                  SizedBox(height: context.scaled.h24),
                  AuthPrimaryButton(
                    label: 'Update password',
                    isLoading: vm.isLoading,
                    onPressed: _onSubmit,
                  ),
                  SizedBox(height: context.scaled.h16),
                  TextButton(
                    onPressed: vm.isLoading
                        ? null
                        : () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppRoutePaths.forgotPassword);
                            }
                          },
                    child: Text(
                      'Request a new code',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        color: AppPallete.tcBlueBright,
                        fontSize: 15,
                      ),
                    ),
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
