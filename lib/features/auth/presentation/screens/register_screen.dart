import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/config/app_route_paths.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../../../core/utils/theme/app_sizes.dart';
import '../../data/google_auth_repository.dart';
import '../auth_assets.dart';
import '../providers/google_auth_provider.dart';
import '../view_models/register_view_model.dart';
import '../widgets/auth_google_sign_in_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_or_divider.dart';
import '../widgets/auth_phone_field.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/terms_acceptance_row.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  late CountryCode _countryCode;
  bool _agreeToTerms = false;
  bool _googleLoading = false;

  @override
  void initState() {
    super.initState();
    _countryCode =
        CountryCode.tryFromCountryCode('KE') ?? CountryCode.fromCountryCode('US');
  }

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _onCreateAccount() async {
    final vm = ref.read(registerViewModelProvider);
    final ok = await vm.submit(
      fullName: _fullName.text,
      email: _email.text.trim(),
      nationalPhoneDigits: _phone.text,
      plainPassword: _password.text,
      confirmPassword: _confirmPassword.text,
      agreeToTerms: _agreeToTerms,
    );
    if (!mounted) return;
    if (ok) context.go(AppRoutePaths.home);
  }

  Future<void> _onGoogleSignUp() async {
    setState(() => _googleLoading = true);
    try {
      await ref.read(googleAuthRepositoryProvider).signInWithGoogle();
      if (!mounted) return;
      context.go(AppRoutePaths.home);
    } on GoogleSignInUnavailableException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } on GoogleSignInException catch (e) {
      if (!mounted) return;
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.description ?? 'Google sign-up failed')),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Google sign-up failed')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-up failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(registerViewModelProvider);
    const maxContentWidth = 420.0;

    return Scaffold(
      backgroundColor: AppPallete.tcWhite,
      appBar: AppBar(
        backgroundColor: AppPallete.tcWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppPallete.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutePaths.login);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                context.responsivePagePadding,
                0,
                context.responsivePagePadding,
                context.responsivePagePadding + AppSizes.s24,
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
                  SizedBox(height: context.scaled.h20),
                  const AuthHeader(
                    title: 'Create account',
                    subtitle: 'Join Transformers Chapel — fill in your details below.',
                  ),
                  SizedBox(height: context.scaled.h24),
                  AuthTextField(
                    controller: _fullName,
                    label: 'Full name',
                    hint: 'Jane Doe',
                    errorText: vm.fullNameError,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(height: context.scaled.h16),
                  AuthTextField(
                    controller: _email,
                    label: 'Email',
                    hint: 'you@example.com',
                    errorText: vm.emailError,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                  ),
                  SizedBox(height: context.scaled.h16),
                  AuthPhoneField(
                    controller: _phone,
                    countryCode: _countryCode,
                    onCountryChanged: (code) => setState(() => _countryCode = code),
                    errorText: vm.phoneError,
                  ),
                  SizedBox(height: context.scaled.h16),
                  AuthTextField(
                    controller: _password,
                    label: 'Password',
                    errorText: vm.passwordError,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                  ),
                  SizedBox(height: context.scaled.h16),
                  AuthTextField(
                    controller: _confirmPassword,
                    label: 'Confirm password',
                    errorText: vm.confirmPasswordError,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    onSubmitted: (_) => _onCreateAccount(),
                  ),
                  SizedBox(height: context.scaled.h20),
                  TermsAcceptanceRow(
                    value: _agreeToTerms,
                    onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
                    errorText: vm.termsError,
                  ),
                  SizedBox(height: context.scaled.h24),
                  AuthPrimaryButton(
                    label: 'Create account',
                    isLoading: vm.isLoading,
                    onPressed: _onCreateAccount,
                  ),
                  SizedBox(height: context.scaled.h24),
                  const AuthOrDivider(label: 'or'),
                  SizedBox(height: context.scaled.h16),
                  AuthGoogleSignInButton(
                    label: 'Sign up with Google',
                    isLoading: _googleLoading,
                    onPressed: _onGoogleSignUp,
                  ),
                  SizedBox(height: context.scaled.h16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    children: [
                      Text(
                        'Already have an account?',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w400,
                          color: AppPallete.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                      TextButton(
                        onPressed: vm.isLoading || _googleLoading
                            ? null
                            : () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go(AppRoutePaths.login);
                                }
                              },
                        child: Text(
                          'Sign in',
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w400,
                            color: AppPallete.tcBlue,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
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
