import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/theme/app_pallete.dart';

class AuthDropdownField<T> extends StatelessWidget {
  const AuthDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.hint,
    this.errorText,
    this.enabled = true,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      key: ValueKey(value),
      initialValue: value,
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel(item),
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppPallete.textPrimary,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
      hint: hint != null
          ? Text(
              hint!,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppPallete.textMuted,
              ),
            )
          : null,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppPallete.textMuted),
      style: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppPallete.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        labelStyle: GoogleFonts.dmSans(
          color: AppPallete.textSecondary,
          fontWeight: FontWeight.w400,
        ),
        errorStyle: GoogleFonts.dmSans(
          color: AppPallete.errorRed,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: AppPallete.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPallete.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPallete.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPallete.tcBlueBright, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPallete.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPallete.errorRed),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
