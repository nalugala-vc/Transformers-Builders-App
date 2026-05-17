import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/utils/theme/app_pallete.dart';
import '../../../domain/models/member_profile_settings.dart';

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
                  : Text('Save', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showLanguagePickerSheet({
  required BuildContext context,
  required String currentCode,
  required ValueChanged<String> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppPallete.tcWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + MediaQuery.paddingOf(context).bottom),
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
              'Language',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppPallete.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ...MemberLanguageOptions.all.map((option) {
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
                onTap: () {
                  onSelected(option.code);
                  Navigator.of(context).pop();
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
    builder: (context) => AlertDialog(
      backgroundColor: AppPallete.tcWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Log out?',
        style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, color: AppPallete.textPrimary),
      ),
      content: Text(
        'You will need to sign in again to access your account.',
        style: GoogleFonts.dmSans(color: AppPallete.textSecondary, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: GoogleFonts.dmSans(color: AppPallete.textSecondary, fontWeight: FontWeight.w600),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: AppPallete.tcRed,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('Log out', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );
}
