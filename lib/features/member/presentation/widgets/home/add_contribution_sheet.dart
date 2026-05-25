import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/l10n/l10n_extension.dart';
import '../../../../../core/utils/app_toast.dart';
import '../../../../../core/utils/theme/app_pallete.dart';
import '../../../domain/models/contribution_activity.dart';
import '../../providers/member_contribution_providers.dart';
import '../../providers/member_home_provider.dart';
import 'set_contribution_goal_sheet.dart';

const contributionPaymentMethods = ['Manual', 'Cash', 'M-Pesa'];

Future<bool?> showAddContributionSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppPallete.tcWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const _ContributionFormSheet(),
  );
}

Future<bool?> showEditContributionSheet(
  BuildContext context,
  ContributionActivity activity,
) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppPallete.tcWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _ContributionFormSheet(activity: activity),
  );
}

Future<void> openContributeFlow(BuildContext context, WidgetRef ref) async {
  final home = ref.read(memberHomeUiProvider).maybeWhen(
        data: (state) => state,
        orElse: () => null,
      );
  if (home == null || !home.hasContributionGoal) {
    await showSetContributionGoalSheet(context);
    return;
  }

  final success = await showAddContributionSheet(context);
  if (success == true && context.mounted) {
    showAppSuccessToast(context, context.l10n.contributionAdded);
  }
}

class _ContributionFormSheet extends ConsumerStatefulWidget {
  const _ContributionFormSheet({this.activity});

  final ContributionActivity? activity;

  bool get isEditing => activity != null;

  @override
  ConsumerState<_ContributionFormSheet> createState() =>
      _ContributionFormSheetState();
}

class _ContributionFormSheetState extends ConsumerState<_ContributionFormSheet> {
  late final TextEditingController _amount;
  late final TextEditingController _reference;
  late final TextEditingController _notes;
  late String _paymentMethod;
  late ContributionPaymentStatus _status;

  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final activity = widget.activity;
    _amount = TextEditingController(
      text: activity != null ? '${activity.amountKes}' : '',
    );
    _reference = TextEditingController(text: activity?.reference ?? '');
    _notes = TextEditingController(text: activity?.notes ?? '');
    _paymentMethod = activity?.paymentMethod ?? contributionPaymentMethods.first;
    if (activity != null &&
        !contributionPaymentMethods.contains(_paymentMethod)) {
      _paymentMethod = contributionPaymentMethods.first;
    }
    _status = activity?.status ?? ContributionPaymentStatus.completed;
  }

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    _notes.dispose();
    super.dispose();
  }

  int? _parsedAmount() {
    final raw = _amount.text.replaceAll(RegExp(r'[^\d]'), '');
    if (raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final amount = _parsedAmount();
    if (amount == null || amount <= 0) {
      setState(() => _error = l10n.errorContributionAmount);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final String? err;
    if (widget.isEditing) {
      err = await updateMemberContribution(
        ref,
        contributionId: widget.activity!.id,
        amountKes: amount,
        paymentMethod: _paymentMethod,
        reference: _reference.text.trim(),
        notes: _notes.text.trim(),
        status: _status,
      );
    } else {
      err = await createMemberContribution(
        ref,
        amountKes: amount,
        paymentMethod: _paymentMethod,
        reference: _reference.text.trim().isEmpty ? null : _reference.text.trim(),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        status: _status,
      );
    }

    if (!mounted) return;
    if (err != null) {
      setState(() {
        _saving = false;
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
              widget.isEditing ? l10n.editContribution : l10n.addContribution,
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppPallete.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.contributionFormHint,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppPallete.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: GoogleFonts.dmSans(fontSize: 16, color: AppPallete.textPrimary),
              decoration: InputDecoration(
                labelText: l10n.contributionAmount,
                prefixText: 'KES ',
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
            const SizedBox(height: 16),
            DropdownMenuFormField<String>(
              initialSelection: _paymentMethod,
              label: Text(l10n.paymentMethod),
              dropdownMenuEntries: [
                for (final method in contributionPaymentMethods)
                  DropdownMenuEntry(value: method, label: method),
              ],
              onSelected: (value) {
                if (value != null) setState(() => _paymentMethod = value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reference,
              style: GoogleFonts.dmSans(fontSize: 16, color: AppPallete.textPrimary),
              decoration: InputDecoration(
                labelText: l10n.contributionReference,
                hintText: l10n.contributionReferenceHint,
                filled: true,
                fillColor: AppPallete.inputFill,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppPallete.border),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notes,
              maxLines: 2,
              style: GoogleFonts.dmSans(fontSize: 16, color: AppPallete.textPrimary),
              decoration: InputDecoration(
                labelText: l10n.contributionNotes,
                filled: true,
                fillColor: AppPallete.inputFill,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppPallete.border),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownMenuFormField<ContributionPaymentStatus>(
              initialSelection: _status,
              label: Text(l10n.contributionStatus),
              dropdownMenuEntries: [
                DropdownMenuEntry(
                  value: ContributionPaymentStatus.completed,
                  label: l10n.statusCompleted,
                ),
                DropdownMenuEntry(
                  value: ContributionPaymentStatus.pending,
                  label: l10n.statusPending,
                ),
                DropdownMenuEntry(
                  value: ContributionPaymentStatus.failed,
                  label: l10n.statusFailed,
                ),
              ],
              onSelected: (value) {
                if (value != null) setState(() => _status = value);
              },
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
                        widget.isEditing ? l10n.save : l10n.addContribution,
                        style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
