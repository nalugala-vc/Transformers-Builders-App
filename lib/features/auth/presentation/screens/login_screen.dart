import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/config/app_route_paths.dart';
import '../../../../core/navigation/auth_navigation.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../../../core/utils/theme/app_sizes.dart';
import '../../data/repositories/google_auth_repository.dart';
import '../auth_assets.dart';
import '../providers/google_auth_provider.dart';
import '../view_models/login_view_model.dart';
import '../widgets/auth_google_sign_in_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_or_divider.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _googleLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final vm = ref.read(loginViewModelProvider);
    final l10n = context.l10n;
    final ok = await vm.submit(l10n, _email.text.trim(), _password.text);
    if (!mounted) return;
    if (ok) await navigateToRoleHome(context, ref);
  }

  Future<void> _onGoogleSignIn() async {
    setState(() => _googleLoading = true);
    try {
      await ref.read(googleAuthRepositoryProvider).signInWithGoogle();
      if (!mounted) return;
      await navigateToRoleHome(context, ref);
    } on GoogleSignInUnavailableException catch (e) {
      if (!mounted) return;
      showAppErrorToast(context, e.toString());
    } on GoogleSignInException catch (e) {
      if (!mounted) return;
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      showAppErrorToast(context, e.description ?? context.l10n.errorGoogleSignInFailed);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      showAppErrorToast(context, e.message ?? context.l10n.errorGoogleSignInFailed);
    } catch (e) {
      if (!mounted) return;
      showAppErrorToast(context, context.l10n.errorGoogleSignInFailed);
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(loginViewModelProvider);
    final l10n = context.l10n;
    final maxContentWidth = 420.0;

    return Scaffold(
      backgroundColor: AppPallete.tcWhite,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
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
                  SizedBox(height: context.scaled.h20),
                  AuthHeader(
                    title: l10n.authWelcomeBack,
                    subtitle: l10n.authSignInSubtitle,
                  ),
                  SizedBox(height: context.scaled.h24),
                  AuthTextField(
                    controller: _email,
                    label: l10n.authEmail,
                    hint: 'you@example.com',
                    errorText: vm.emailError,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                  ),
                  SizedBox(height: context.scaled.h16),
                  AuthTextField(
                    controller: _password,
                    label: l10n.authPassword,
                    errorText: vm.passwordError,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    onSubmitted: (_) => _onLogin(),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: vm.isLoading || _googleLoading
                          ? null
                          : () {
                              final e = _email.text.trim();
                              final path = e.isEmpty
                                  ? AppRoutePaths.forgotPassword
                                  : '${AppRoutePaths.forgotPassword}?email=${Uri.encodeComponent(e)}';
                              context.push(path);
                            },
                      child: Text(
                        l10n.authForgotPassword,
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          color: AppPallete.tcBlueBright,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.scaled.h8),
                  AuthPrimaryButton(
                    label: l10n.authSignIn,
                    isLoading: vm.isLoading,
                    onPressed: _onLogin,
                  ),
                  SizedBox(height: context.scaled.h24),
                  AuthOrDivider(label: l10n.authOr),
                  SizedBox(height: context.scaled.h16),
                  AuthGoogleSignInButton(
                    label: l10n.authSignInGoogle,
                    isLoading: _googleLoading,
                    onPressed: _onGoogleSignIn,
                  ),
                  SizedBox(height: context.scaled.h24),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    children: [
                      Text(
                        l10n.authNoAccount,
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w400,
                          color: AppPallete.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                      TextButton(
                        onPressed: vm.isLoading || _googleLoading
                            ? null
                            : () => context.push(AppRoutePaths.register),
                        child: Text(
                          l10n.authCreateAccount,
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w700,
                            color: AppPallete.tcBlueBright,
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
