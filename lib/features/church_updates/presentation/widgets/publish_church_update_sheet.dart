import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../../auth/presentation/providers/user_profile_providers.dart';
import '../providers/church_updates_providers.dart';

Future<void> showPublishChurchUpdateSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppPallete.tcWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const _PublishChurchUpdateSheet(),
  );
}

class _PublishChurchUpdateSheet extends ConsumerStatefulWidget {
  const _PublishChurchUpdateSheet();

  @override
  ConsumerState<_PublishChurchUpdateSheet> createState() =>
      _PublishChurchUpdateSheetState();
}

class _PublishChurchUpdateSheetState
    extends ConsumerState<_PublishChurchUpdateSheet> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  var _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    final l10n = context.l10n;
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty) {
      showAppErrorToast(context, l10n.churchUpdateTitleRequired);
      return;
    }
    if (body.isEmpty) {
      showAppErrorToast(context, l10n.churchUpdateBodyRequired);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showAppErrorToast(context, l10n.errorSomethingWrong);
      return;
    }

    setState(() => _saving = true);

    try {
      final profile =
          await ref.read(userProfileRepositoryProvider).getUser(user.uid);
      await ref.read(churchUpdatesRepositoryProvider).publishUpdate(
            title: title,
            body: body,
            createdByUid: user.uid,
            createdByName: profile?.fullName,
          );
      await refreshChurchUpdates(ref);
      if (!mounted) return;
      Navigator.of(context).pop();
      showAppSuccessToast(context, l10n.churchUpdatePublished);
    } catch (_) {
      if (!mounted) return;
      showAppErrorToast(context, l10n.churchUpdatePublishFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
            l10n.adminPublishUpdate,
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppPallete.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.adminPublishUpdateHint,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppPallete.textMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.churchUpdateTitle,
              hintText: l10n.churchUpdateTitleHint,
              filled: true,
              fillColor: AppPallete.inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyController,
            textCapitalization: TextCapitalization.sentences,
            minLines: 4,
            maxLines: 8,
            decoration: InputDecoration(
              labelText: l10n.churchUpdateBody,
              hintText: l10n.churchUpdateBodyHint,
              alignLabelWithHint: true,
              filled: true,
              fillColor: AppPallete.inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _saving ? null : _publish,
              style: FilledButton.styleFrom(
                backgroundColor: AppPallete.tcBlueBright,
                foregroundColor: AppPallete.tcWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                      l10n.adminPublishUpdateAction,
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
