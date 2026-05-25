import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/utils/theme/app_pallete.dart';
import '../../providers/contribution_refresh.dart';
import '../../providers/member_contribution_providers.dart';
import '../../providers/member_home_provider.dart';
import '../../utils/member_formatters.dart';

Future<bool?> showSetContributionGoalSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppPallete.tcWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const _SetContributionGoalSheet(),
  );
}

class _SetContributionGoalSheet extends ConsumerStatefulWidget {
  const _SetContributionGoalSheet();

  @override
  ConsumerState<_SetContributionGoalSheet> createState() =>
      _SetContributionGoalSheetState();
}

class _SetContributionGoalSheetState extends ConsumerState<_SetContributionGoalSheet> {
  final _amountController = TextEditingController();
  static const _presets = [5000, 10000, 25000, 50000];

  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int? _parsedAmount() {
    final raw = _amountController.text.replaceAll(RegExp(r'[^\d]'), '');
    if (raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  Future<void> _save() async {
    final amount = _parsedAmount();
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid target amount in KES');
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _error = 'You are signed out. Please sign in again.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref.read(memberContributionRepositoryProvider).setContributionTarget(
            uid: uid,
            targetKes: amount,
          );
      ref.invalidate(memberHomeUiProvider);
      invalidateContributionData(ref);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not save your goal. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

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
            'Set contribution goal',
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppPallete.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how much you want to raise for Transformers Chapel this season.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppPallete.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.dmSans(fontSize: 16, color: AppPallete.textPrimary),
            decoration: InputDecoration(
              labelText: 'Target amount (KES)',
              hintText: 'e.g. 5000',
              errorText: _error,
              prefixText: 'KES ',
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
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presets.map((amount) {
              return ActionChip(
                label: Text(formatKes(amount)),
                onPressed: _saving
                    ? null
                    : () => setState(() => _amountController.text = '$amount'),
                labelStyle: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  color: AppPallete.tcBlueBright,
                ),
                side: const BorderSide(color: AppPallete.border),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppPallete.tcBlueBright,
                foregroundColor: AppPallete.tcWhite,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppPallete.tcWhite,
                      ),
                    )
                  : Text(
                      'Save goal',
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
