import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/app_route_paths.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../../../core/utils/theme/app_sizes.dart';
import '../auth_assets.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_primary_button.dart';

/// One-time code entry. Open with
/// `context.push('${AppRoutePaths.otpVerification}?to=${Uri.encodeComponent(emailOrPhone)}')`.
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    this.destination,
  });

  /// Where the code was sent (email or phone). Prefer passing via route query `to`.
  final String? destination;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const int _codeLength = 6;

  List<TextEditingController?>? _otpControllers;
  bool _otpListenersBound = false;
  bool _loading = false;
  int _resendSeconds = 60;
  bool _otpFieldKey = false;

  String get _destinationLabel {
    final raw = widget.destination?.trim();
    if (raw == null || raw.isEmpty) return 'your phone or email';
    return _maskDestination(raw);
  }

  String get _currentOtp =>
      (_otpControllers ?? const <TextEditingController?>[])
          .map((c) => c?.text ?? '')
          .join();

  @override
  void initState() {
    super.initState();
    _tickResend();
  }

  @override
  void dispose() {
    _detachOtpListeners();
    super.dispose();
  }

  void _detachOtpListeners() {
    final list = _otpControllers;
    if (list == null || !_otpListenersBound) return;
    for (final c in list) {
      c?.removeListener(_onOtpControllersChanged);
    }
    _otpListenersBound = false;
  }

  void _onOtpControllersChanged() {
    if (mounted) setState(() {});
  }

  void _bindOtpListenersIfReady(List<TextEditingController?> controllers) {
    if (_otpListenersBound) return;
    if (!controllers.every((c) => c != null)) return;
    for (final c in controllers) {
      c!.addListener(_onOtpControllersChanged);
    }
    _otpListenersBound = true;
  }

  void _tickResend() {
    if (_resendSeconds <= 0 || !mounted) return;
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _resendSeconds -= 1);
      _tickResend();
    });
  }

  Future<void> _submitCode(String code) async {
    if (code.length != _codeLength) return;
    setState(() => _loading = true);
    // Replace with Firebase / backend verification.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _loading = false);
    if (context.canPop()) {
      context.pop(code);
    } else {
      context.go(AppRoutePaths.home);
    }
  }

  void _onVerifyPressed() {
    final code = _currentOtp;
    if (code.length != _codeLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter all 6 digits.')),
      );
      return;
    }
    _submitCode(code);
  }

  void _onResend() {
    if (_resendSeconds > 0) return;
    _detachOtpListeners();
    _otpControllers = null;
    setState(() {
      _resendSeconds = 60;
      _otpFieldKey = !_otpFieldKey;
    });
    _tickResend();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('A new code has been sent.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const maxContentWidth = 420.0;
    final fieldWidth = context.layoutSizeClass == AppLayoutSizeClass.compact ? 46.0 : 52.0;
    final otpComplete = _currentOtp.length == _codeLength;

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
                      AuthAssets.messageIcon,
                      height: context.scaled.h80,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: context.scaled.h24),
                  AuthHeader(
                    title: 'Verification code',
                    subtitle:
                        'Enter the $_codeLength-digit code we sent to $_destinationLabel.',
                  ),
                  SizedBox(height: context.scaled.h28),
                  KeyedSubtree(
                    key: ValueKey(_otpFieldKey),
                    child: OtpTextField(
                      numberOfFields: _codeLength,
                      autoFocus: true,
                      showFieldAsBox: true,
                      filled: true,
                      fillColor: AppPallete.inputFill,
                      borderWidth: 1.5,
                      borderRadius: BorderRadius.circular(12),
                      fieldWidth: fieldWidth,
                      fieldHeight: 52,
                      margin: const EdgeInsets.only(right: 8),
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      keyboardType: TextInputType.number,
                      cursorColor: AppPallete.tcBlue,
                      enabledBorderColor: AppPallete.border,
                      borderColor: AppPallete.border,
                      focusedBorderColor: AppPallete.tcBlue,
                      disabledBorderColor: AppPallete.border,
                      textStyle: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppPallete.textPrimary,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      handleControllers: (controllers) {
                        _otpControllers = controllers;
                        _bindOtpListenersIfReady(controllers);
                      },
                      onSubmit: _submitCode,
                    ),
                  ),
                  SizedBox(height: context.scaled.h24),
                  AuthPrimaryButton(
                    label: 'Verify',
                    isLoading: _loading,
                    onPressed: otpComplete && !_loading ? _onVerifyPressed : null,
                  ),
                  SizedBox(height: context.scaled.h20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive a code? ",
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppPallete.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: _resendSeconds > 0 ? null : _onResend,
                        child: Text(
                          _resendSeconds > 0 ? 'Resend in ${_resendSeconds}s' : 'Resend',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _resendSeconds > 0 ? AppPallete.textMuted : AppPallete.tcBlue,
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

String _maskDestination(String trimmed) {
  if (trimmed.contains('@')) {
    final at = trimmed.indexOf('@');
    if (at <= 0) return trimmed;
    final local = trimmed.substring(0, at);
    final domain = trimmed.substring(at + 1);
    if (local.length <= 2) return '***@$domain';
    final stars = '*' * (local.length - 2).clamp(1, 5);
    return '${local.substring(0, 2)}$stars@$domain';
  }
  if (trimmed.length <= 4) return '***';
  return '${trimmed.substring(0, 3)} ••• ${trimmed.substring(trimmed.length - 2)}';
}
