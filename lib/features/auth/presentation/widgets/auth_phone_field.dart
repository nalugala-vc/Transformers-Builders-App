import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/theme/app_pallete.dart';

/// Country dial picker + national number field.
class AuthPhoneField extends StatelessWidget {
  const AuthPhoneField({
    super.key,
    required this.controller,
    required this.countryCode,
    required this.onCountryChanged,
    this.errorText,
  });

  final TextEditingController controller;
  final CountryCode countryCode;
  final ValueChanged<CountryCode> onCountryChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bounded width: `alignLeft: true` + Row + ScrollView can give the picker
            // unbounded horizontal constraints and crash its internal `Expanded`.
            SizedBox(
              width: 118,
              child: Container(
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: AppPallete.inputFill,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppPallete.border),
                ),
                child: CountryCodePicker(
                  key: ValueKey(countryCode.code),
                  onChanged: onCountryChanged,
                  initialSelection: countryCode.code ?? 'KE',
                  favorite: const ['+254', '+255', '+256', '+250', '+1'],
                  showCountryOnly: false,
                  showOnlyCountryWhenClosed: false,
                  padding: EdgeInsets.zero,
                  dialogTextStyle: GoogleFonts.dmSans(
                    color: AppPallete.textPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                  dialogBackgroundColor: AppPallete.tcWhite,
                  barrierColor: Colors.black54,
                  // Custom closed UI avoids the package default `Flex` + `Flexible`,
                  // which throws under unbounded horizontal constraints.
                  builder: (cc) {
                    final d = cc ?? countryCode;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (d.flagUri != null)
                            Image.asset(
                              d.flagUri!,
                              package: 'country_code_picker',
                              width: 22,
                            ),
                          const SizedBox(width: 6),
                          Text(
                            d.dialCode ?? '',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppPallete.textPrimary,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down_rounded,
                            size: 22,
                            color: AppPallete.textMuted,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppPallete.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Phone number',
                  hintText: '712 345 678',
                  errorText: null,
                  labelStyle: GoogleFonts.dmSans(
                    color: AppPallete.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                  hintStyle: GoogleFonts.dmSans(
                    color: AppPallete.textMuted,
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
                    borderSide: const BorderSide(color: AppPallete.tcBlue, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorText!,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppPallete.errorRed,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
