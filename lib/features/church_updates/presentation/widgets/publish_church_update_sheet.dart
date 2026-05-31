import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../../auth/presentation/providers/user_profile_providers.dart';
import '../../data/repositories/church_updates_repository.dart';
import '../providers/church_updates_providers.dart';
import 'church_update_attachment_picker.dart';

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
  final _attachments = <PlatformFile>[];
  var _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachments() async {
    final l10n = context.l10n;
    final remaining =
        ChurchUpdatesRepository.maxAttachments - _attachments.length;

    try {
      final picked = await pickChurchUpdateAttachments(
        context,
        remainingSlots: remaining,
      );
      if (picked == null || picked.isEmpty || !mounted) return;

      for (final file in picked) {
        if (file.size > ChurchUpdatesRepository.maxAttachmentBytes) {
          showAppErrorToast(context, l10n.churchUpdateAttachmentTooLarge);
          return;
        }
      }

      setState(() {
        _attachments.addAll(picked);
        if (_attachments.length > ChurchUpdatesRepository.maxAttachments) {
          _attachments.removeRange(
            ChurchUpdatesRepository.maxAttachments,
            _attachments.length,
          );
          showAppInfoToast(context, l10n.churchUpdateAttachmentLimit);
        }
      });
    } catch (_) {
      if (mounted) {
        showAppErrorToast(context, l10n.churchUpdateAttachmentPickFailed);
      }
    }
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
            attachments: List.unmodifiable(_attachments),
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
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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
                enabled: !_saving,
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
                enabled: !_saving,
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
              ChurchUpdateAttachmentPicker(
                files: _attachments,
                enabled: !_saving,
                onAdd: _pickAttachments,
                onRemove: (index) => setState(() => _attachments.removeAt(index)),
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
        ),
      ),
    );
  }
}
