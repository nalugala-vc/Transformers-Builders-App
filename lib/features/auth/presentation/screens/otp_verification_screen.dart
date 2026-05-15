import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/app_route_paths.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../../../core/utils/theme/app_sizes.dart';
import '../auth_assets.dart';
import '../models/otp_route_extra.dart';
import '../view_models/otp_view_model.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_primary_button.dart';

/// Phone SMS verification after registration ([extra]) or legacy query-only [destination].
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({
    super.key,
    this.extra,
    this.destination,
  });

  /// Firebase phone verification session (from registration).
  final OtpRouteExtra? extra;

  /// Optional display hint when [extra] is null (e.g. deep link `?to=`).
  final String? destination;

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  static const int _codeLength = 6;

  List<TextEditingController?>? _otpControllers;
  bool _otpListenersBound = false;
  int _resendSeconds = 60;
  bool _otpFieldKey = false;

  String get _destinationLabel {
    final extra = widget.extra;
    if (extra != null) return extra.maskedDestination;
    final raw = widget.destination?.trim();
    if (raw == null || raw.isEmpty) return 'your phone';
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
    final extra = widget.extra;
    if (extra == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Open this screen from Create account to verify your phone.'),
        ),
      );
      return;
    }

    final vm = ref.read(otpViewModelProvider(extra));
    final ok = await vm.verifySms(code);
    if (!mounted) return;
    if (ok) {
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.go(AppRoutePaths.home);
      }
      return;
    }
    if (vm.verifyError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.verifyError!)),
      );
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

  Future<void> _onResend() async {
    if (_resendSeconds > 0) return;
    final extra = widget.extra;
    if (extra == null) return;

    final vm = ref.read(otpViewModelProvider(extra));
    final ok = await vm.resendSms();
    if (!mounted) return;
    if (!ok && vm.resendError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.resendError!)),
      );
      return;
    }

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
    final extra = widget.extra;
    final vm = extra != null ? ref.watch(otpViewModelProvider(extra)) : null;
    final otpComplete = _currentOtp.length == _codeLength;
    final busy = vm?.isLoading == true || vm?.isResending == true;

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
                  if (extra == null) ...[
                    SizedBox(height: context.scaled.h12),
                    Text(
                      'This step is used after you create an account so we can confirm your phone number.',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppPallete.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                  SizedBox(height: context.scaled.h28),
                  KeyedSubtree(
                    key: ValueKey(_otpFieldKey),
                    child: OtpTextField(
                      numberOfFields: _codeLength,
                      autoFocus: extra != null,
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
                      onSubmit: extra != null ? _submitCode : (_) {},
                    ),
                  ),
                  SizedBox(height: context.scaled.h24),
                  AuthPrimaryButton(
                    label: 'Verify',
                    isLoading: vm?.isLoading == true,
                    onPressed: extra != null && otpComplete && !busy ? _onVerifyPressed : null,
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
                        onPressed: extra == null || _resendSeconds > 0 || vm?.isResending == true
                            ? null
                            : _onResend,
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
