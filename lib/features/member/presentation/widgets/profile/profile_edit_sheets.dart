import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/l10n/l10n_extension.dart';
import '../../../../../core/l10n/locale_provider.dart';
import '../../../../../core/utils/app_toast.dart';
import '../../../../../core/utils/phone_e164.dart';
import '../../../../../core/utils/theme/app_pallete.dart';
import '../../../../auth/presentation/widgets/auth_phone_field.dart';
import '../../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../../auth/presentation/widgets/member_group_fields.dart';
import '../../../domain/models/member_profile_settings.dart';
import '../../providers/member_profile_provider.dart';

Future<void> showEditTextProfileSheet({
  required BuildContext context,
  required String title,
  required String label,
  required String initialValue,
  String? hint,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
  required Future<String?> Function(String value) onSave,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppPallete.tcWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return _EditTextSheet(
        title: title,
        label: label,
        initialValue: initialValue,
        hint: hint,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onSave: onSave,
      );
    },
  );
}

class _EditTextSheet extends StatefulWidget {
  const _EditTextSheet({
    required this.title,
    required this.label,
    required this.initialValue,
    this.hint,
    required this.obscureText,
    required this.keyboardType,
    required this.onSave,
  });

  final String title;
  final String label;
  final String initialValue;
  final String? hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final Future<String?> Function(String value) onSave;

  @override
  State<_EditTextSheet> createState() => _EditTextSheetState();
}

class _EditTextSheetState extends State<_EditTextSheet> {
  late final TextEditingController _controller;
  var _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final err = await widget.onSave(_controller.text);
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _loading = false;
        _error = err;
      });
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppPallete.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.title,
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppPallete.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            autocorrect: !widget.obscureText,
            style: GoogleFonts.dmSans(fontSize: 16, color: AppPallete.textPrimary),
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              errorText: _error,
              filled: true,
              fillColor: AppPallete.inputFill,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppPallete.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppPallete.tcBlueBright, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppPallete.tcBlueBright,
                foregroundColor: AppPallete.tcWhite,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: AppPallete.tcWhite),
                    )
                  : Text(l10n.save, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Change password for email/password accounts (re-auth + [updatePassword]).
Future<bool?> showChangePasswordSheet({
  required BuildContext context,
  required String email,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppPallete.tcWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => _ChangePasswordSheet(email: email),
  );
}

/// Google-only (or no password provider): offer reset email to set a password.
Future<bool?> showPasswordManagedExternallySheet({
  required BuildContext context,
  required String email,
  required bool usesGoogleSignIn,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppPallete.tcWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => _PasswordManagedExternallySheet(
      email: email,
      usesGoogleSignIn: usesGoogleSignIn,
    ),
  );
}

class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet({required this.email});

  final String email;

  @override
  ConsumerState<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final _current = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirm = TextEditingController();
  var _loading = false;
  String? _formError;
  String? _currentError;
  String? _newError;
  String? _confirmError;

  @override
  void dispose() {
    _current.dispose();
    _newPassword.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _formError = null;
      _currentError = null;
      _newError = null;
      _confirmError = null;
    });

    final err = await updateMemberPassword(
      ref,
      context.l10n,
      email: widget.email,
      currentPassword: _current.text,
      newPassword: _newPassword.text,
      confirmPassword: _confirm.text,
    );

    if (!mounted) return;
    if (err != null) {
      setState(() {
        _loading = false;
        if (err.contains('current') || err.contains('incorrect')) {
          _currentError = err;
        } else if (err.contains('match')) {
          _confirmError = err;
        } else if (err.contains('8 characters') || err.contains('weak')) {
          _newError = err;
        } else {
          _formError = err;
        }
      });
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppPallete.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.changePassword,
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppPallete.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.passwordChangeHint,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppPallete.textSecondary,
              height: 1.4,
            ),
          ),
          if (_formError != null) ...[
            const SizedBox(height: 12),
            Text(
              _formError!,
              style: GoogleFonts.dmSans(fontSize: 13, color: AppPallete.errorRed),
            ),
          ],
          const SizedBox(height: 16),
          AuthTextField(
            controller: _current,
            label: l10n.currentPassword,
            obscureText: true,
            errorText: _currentError,
            textInputAction: TextInputAction.next,
            autocorrect: false,
          ),
          const SizedBox(height: 12),
          AuthTextField(
            controller: _newPassword,
            label: l10n.newPassword,
            hint: l10n.passwordHintEight,
            obscureText: true,
            errorText: _newError,
            textInputAction: TextInputAction.next,
            autocorrect: false,
          ),
          const SizedBox(height: 12),
          AuthTextField(
            controller: _confirm,
            label: l10n.confirmNewPassword,
            obscureText: true,
            errorText: _confirmError,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            onSubmitted: (_) {
              if (!_loading) _submit();
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppPallete.tcBlueBright,
                foregroundColor: AppPallete.tcWhite,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppPallete.tcWhite,
                      ),
                    )
                  : Text(
                      l10n.updatePassword,
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordManagedExternallySheet extends ConsumerStatefulWidget {
  const _PasswordManagedExternallySheet({
    required this.email,
    required this.usesGoogleSignIn,
  });

  final String email;
  final bool usesGoogleSignIn;

  @override
  ConsumerState<_PasswordManagedExternallySheet> createState() =>
      _PasswordManagedExternallySheetState();
}

class _PasswordManagedExternallySheetState
    extends ConsumerState<_PasswordManagedExternallySheet> {
  var _loading = false;
  String? _error;
  var _sent = false;

  Future<void> _sendLink() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final err = await sendPasswordSetupEmail(ref, widget.email);
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _loading = false;
        _error = err;
      });
      return;
    }
    setState(() {
      _loading = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final title =
        widget.usesGoogleSignIn ? l10n.passwordGoogleTitle : l10n.setPasswordTitle;
    final body = widget.usesGoogleSignIn
        ? l10n.passwordGoogleBody(widget.email)
        : l10n.setPasswordBody(widget.email);

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppPallete.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppPallete.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _sent ? l10n.checkInboxPassword : body,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppPallete.textSecondary,
              height: 1.45,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: GoogleFonts.dmSans(fontSize: 13, color: AppPallete.errorRed),
            ),
          ],
          const SizedBox(height: 20),
          if (!_sent)
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _loading ? null : _sendLink,
                style: FilledButton.styleFrom(
                  backgroundColor: AppPallete.tcBlueBright,
                  foregroundColor: AppPallete.tcWhite,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppPallete.tcWhite,
                        ),
                      )
                    : Text(
                        l10n.emailSetupLink,
                        style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                      ),
              ),
            )
          else
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppPallete.tcBlueBright,
                  foregroundColor: AppPallete.tcWhite,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(l10n.done, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
              ),
            ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                color: AppPallete.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool?> showEditEmailSheet({
  required BuildContext context,
  required String currentEmail,
  required bool requiresPasswordReauth,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppPallete.tcWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => _EditEmailSheet(
      currentEmail: currentEmail,
      requiresPasswordReauth: requiresPasswordReauth,
    ),
  );
}

class _EditEmailSheet extends ConsumerStatefulWidget {
  const _EditEmailSheet({
    required this.currentEmail,
    required this.requiresPasswordReauth,
  });

  final String currentEmail;
  final bool requiresPasswordReauth;

  @override
  ConsumerState<_EditEmailSheet> createState() => _EditEmailSheetState();
}

class _EditEmailSheetState extends ConsumerState<_EditEmailSheet> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _loading = false;
  String? _formError;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _formError = null;
      _emailError = null;
      _passwordError = null;
    });

    final err = await updateMemberEmail(
      ref,
      context.l10n,
      currentEmail: widget.currentEmail,
      newEmail: _email.text,
      requiresPasswordReauth: widget.requiresPasswordReauth,
      currentPassword: widget.requiresPasswordReauth ? _password.text : null,
    );

    if (!mounted) return;
    if (err != null) {
      setState(() {
        _loading = false;
        if (err.contains('password')) {
          _passwordError = err;
        } else if (err.contains('email')) {
          _emailError = err;
        } else {
          _formError = err;
        }
      });
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppPallete.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.editEmail,
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppPallete.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.emailUpdateHint,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppPallete.textSecondary,
              height: 1.4,
            ),
          ),
          if (_formError != null) ...[
            const SizedBox(height: 12),
            Text(
              _formError!,
              style: GoogleFonts.dmSans(fontSize: 13, color: AppPallete.errorRed),
            ),
          ],
          const SizedBox(height: 16),
          AuthTextField(
            controller: _email,
            label: l10n.newEmailAddress,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
            textInputAction: TextInputAction.next,
            autocorrect: false,
          ),
          if (widget.requiresPasswordReauth) ...[
            const SizedBox(height: 12),
            AuthTextField(
              controller: _password,
              label: l10n.currentPassword,
              obscureText: true,
              errorText: _passwordError,
              autocorrect: false,
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppPallete.tcBlueBright,
                foregroundColor: AppPallete.tcWhite,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppPallete.tcWhite,
                      ),
                    )
                  : Text(l10n.save, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool?> showEditPhoneSheet({
  required BuildContext context,
  required String? phoneE164,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppPallete.tcWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => _EditPhoneSheet(phoneE164: phoneE164),
  );
}

class _EditPhoneSheet extends ConsumerStatefulWidget {
  const _EditPhoneSheet({required this.phoneE164});

  final String? phoneE164;

  @override
  ConsumerState<_EditPhoneSheet> createState() => _EditPhoneSheetState();
}

class _EditPhoneSheetState extends ConsumerState<_EditPhoneSheet> {
  late final TextEditingController _phone;
  late CountryCode _countryCode;
  var _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final parsed = parseE164Phone(widget.phoneE164);
    _countryCode = parsed.countryCode;
    _phone = TextEditingController(text: parsed.nationalDigits);
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final e164 = buildE164Phone(
      countryCode: _countryCode,
      nationalDigits: _phone.text,
    );
    final err = await updateMemberPhone(ref, context.l10n, phoneE164: e164);
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _loading = false;
        _error = err;
      });
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppPallete.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.editPhone,
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppPallete.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          AuthPhoneField(
            controller: _phone,
            countryCode: _countryCode,
            onCountryChanged: (c) => setState(() => _countryCode = c),
            errorText: _error,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppPallete.tcBlueBright,
                foregroundColor: AppPallete.tcWhite,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppPallete.tcWhite,
                      ),
                    )
                  : Text(l10n.save, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool?> showEditMemberGroupsSheet({
  required BuildContext context,
  required String? demographicGroupId,
  required String? ministryGroupId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppPallete.tcWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => _EditMemberGroupsSheet(
      demographicGroupId: demographicGroupId,
      ministryGroupId: ministryGroupId,
    ),
  );
}

class _EditMemberGroupsSheet extends ConsumerStatefulWidget {
  const _EditMemberGroupsSheet({
    required this.demographicGroupId,
    required this.ministryGroupId,
  });

  final String? demographicGroupId;
  final String? ministryGroupId;

  @override
  ConsumerState<_EditMemberGroupsSheet> createState() => _EditMemberGroupsSheetState();
}

class _EditMemberGroupsSheetState extends ConsumerState<_EditMemberGroupsSheet> {
  late String? _demographicGroupId;
  late String? _ministryGroupId;
  var _loading = false;
  String? _demographicError;
  String? _ministryError;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _demographicGroupId = widget.demographicGroupId;
    _ministryGroupId = widget.ministryGroupId;
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _demographicError = null;
      _ministryError = null;
      _formError = null;
    });

    final err = await updateMemberGroups(
      ref,
      context.l10n,
      demographicGroupId: _demographicGroupId,
      ministryGroupId: _ministryGroupId,
    );

    if (!mounted) return;
    if (err != null) {
      setState(() {
        _loading = false;
        if (err.contains('demographic') || err.contains('Select your')) {
          _demographicError = err;
        } else if (err.contains('ministry') || err.contains('Ministry')) {
          _ministryError = err;
        } else {
          _formError = err;
        }
      });
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppPallete.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.churchGroups,
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppPallete.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.churchGroupsHint,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppPallete.textSecondary,
                height: 1.4,
              ),
            ),
            if (_formError != null) ...[
              const SizedBox(height: 12),
              Text(
                _formError!,
                style: GoogleFonts.dmSans(fontSize: 13, color: AppPallete.errorRed),
              ),
            ],
            const SizedBox(height: 16),
            MemberGroupFields(
              demographicGroupId: _demographicGroupId,
              ministryGroupId: _ministryGroupId,
              demographicError: _demographicError,
              ministryError: _ministryError,
              enabled: !_loading,
              onDemographicChanged: (id) => setState(() => _demographicGroupId = id),
              onMinistryChanged: (id) => setState(() => _ministryGroupId = id),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _loading ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppPallete.tcBlueBright,
                  foregroundColor: AppPallete.tcWhite,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppPallete.tcWhite,
                        ),
                      )
                    : Text(l10n.save, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showLanguagePickerSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String currentCode,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppPallete.tcWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      final l10n = sheetContext.l10n;
      return Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + MediaQuery.paddingOf(sheetContext).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppPallete.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.language,
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppPallete.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ...MemberLanguageOptions.all(l10n).map((option) {
              final selected = option.code == currentCode;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  option.label,
                  style: GoogleFonts.dmSans(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: AppPallete.textPrimary,
                  ),
                ),
                trailing: selected
                    ? const Icon(Icons.check_circle_rounded, color: AppPallete.tcBlueBright)
                    : null,
                onTap: () async {
                  await ref.read(localeProvider.notifier).setLanguageCode(option.code);
                  ref.invalidate(memberProfileUiProvider);
                  if (sheetContext.mounted) {
                    showAppSuccessToast(sheetContext, sheetContext.l10n.languageUpdated);
                    Navigator.of(sheetContext).pop();
                  }
                },
              );
            }),
          ],
        ),
      );
    },
  );
}

Future<bool?> showLogoutConfirmDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final dialogL10n = dialogContext.l10n;
      return AlertDialog(
        backgroundColor: AppPallete.tcWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          dialogL10n.logoutConfirmTitle,
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, color: AppPallete.textPrimary),
        ),
        content: Text(
          dialogL10n.logoutConfirmBody,
          style: GoogleFonts.dmSans(color: AppPallete.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              dialogL10n.cancel,
              style: GoogleFonts.dmSans(color: AppPallete.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppPallete.tcRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(dialogL10n.logOut, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
          ),
        ],
      );
    },
  );
}
