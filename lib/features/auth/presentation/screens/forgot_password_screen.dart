import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/app_route_paths.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../../../core/utils/theme/app_sizes.dart';
import '../auth_assets.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';

/// Request a password reset email for the account tied to [initialEmail] (optional).
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    this.initialEmail,
  });

  final String? initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  String? _emailError;
  bool _loading = false;

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

  bool _validateEmail() {
    final raw = _email.text.trim();
    if (raw.isEmpty) {
      setState(() => _emailError = 'Enter your email address.');
      return false;
    }
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(raw);
    if (!ok) {
      setState(() => _emailError = 'Enter a valid email address.');
      return false;
    }
    setState(() => _emailError = null);
    return true;
  }

  Future<void> _onSendLink() async {
    FocusScope.of(context).unfocus();
    if (!_validateEmail()) return;

    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'If an account exists for that email, you will receive reset instructions shortly.',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w400),
          ),
        ),
      );
      context.pop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _emailError = e.message ?? 'Could not send reset email. Try again.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _emailError = 'Something went wrong. Please try again.';
      });
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
                    errorText: _emailError,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    onSubmitted: (_) => _onSendLink(),
                  ),
                  SizedBox(height: context.scaled.h24),
                  AuthPrimaryButton(
                    label: 'Send reset link',
                    isLoading: _loading,
                    onPressed: _onSendLink,
                  ),
                  SizedBox(height: context.scaled.h16),
                  TextButton(
                    onPressed: _loading
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
                        color: AppPallete.tcBlue,
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
