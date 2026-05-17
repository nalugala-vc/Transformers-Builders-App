import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/app_route_paths.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../../../core/utils/theme/app_sizes.dart';
import '../auth_assets.dart';
import '../view_models/forgot_password_view_model.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';

/// Request a password reset email for the account tied to [initialEmail] (optional).
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    this.initialEmail,
  });

  final String? initialEmail;

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();

  @override
  void initState() {
    super.initState();
    final preset = widget.initialEmail?.trim();
    if (preset != null && preset.isNotEmpty) {
      _email.text = preset;
    }
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _onSendLink() async {
    FocusScope.of(context).unfocus();
    final vm = ref.read(forgotPasswordViewModelProvider);
    final ok = await vm.submit(_email.text);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'If an account exists for that email, you will receive reset instructions shortly.',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w400),
          ),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    const maxContentWidth = 420.0;
    final vm = ref.watch(forgotPasswordViewModelProvider);

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
                  const AuthHeader(
                    title: 'Forgot password?',
                    subtitle:
                        'Enter the email for your account. We will send you a link to reset your password.',
                  ),
                  SizedBox(height: context.scaled.h28),
                  AuthTextField(
                    controller: _email,
                    label: 'Email',
                    hint: 'you@example.com',
                    errorText: vm.emailError,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    onSubmitted: (_) => _onSendLink(),
                  ),
                  SizedBox(height: context.scaled.h24),
                  AuthPrimaryButton(
                    label: 'Send reset link',
                    isLoading: vm.isLoading,
                    onPressed: _onSendLink,
                  ),
                  SizedBox(height: context.scaled.h16),
                  TextButton(
                    onPressed: vm.isLoading
                        ? null
                        : () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppRoutePaths.login);
                            }
                          },
                    child: Text(
                      'Back to sign in',
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
