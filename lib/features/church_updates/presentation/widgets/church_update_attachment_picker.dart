import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../data/repositories/church_updates_repository.dart';
import '../../domain/models/church_update_attachment.dart';

/// Pick images, PDFs, and office documents for a church update.
Future<List<PlatformFile>?> pickChurchUpdateAttachments(
  BuildContext context, {
  required int remainingSlots,
}) async {
  if (remainingSlots <= 0) return null;

  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowMultiple: true,
    allowedExtensions: const [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'txt',
    ],
    withData: true,
  );

  if (result == null || result.files.isEmpty) return null;
  return result.files.take(remainingSlots).toList();
}

IconData iconForAttachmentKind(ChurchUpdateAttachmentKind kind) {
  return switch (kind) {
    ChurchUpdateAttachmentKind.image => Icons.image_outlined,
    ChurchUpdateAttachmentKind.pdf => Icons.picture_as_pdf_outlined,
    ChurchUpdateAttachmentKind.document => Icons.description_outlined,
  };
}

class ChurchUpdateAttachmentPicker extends StatelessWidget {
  const ChurchUpdateAttachmentPicker({
    super.key,
    required this.files,
    required this.onAdd,
    required this.onRemove,
    this.enabled = true,
  });

  final List<PlatformFile> files;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canAdd =
        enabled && files.length < ChurchUpdatesRepository.maxAttachments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              l10n.churchUpdateAttachments,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppPallete.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              l10n.churchUpdateAttachmentCount(
                files.length,
                ChurchUpdatesRepository.maxAttachments,
              ),
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppPallete.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (files.isNotEmpty) ...[
          ...List.generate(files.length, (index) {
            final file = files[index];
            final kind = ChurchUpdateAttachment.fromMap({
              'name': file.name,
            }).kind;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _PendingAttachmentTile(
                name: file.name,
                sizeLabel: formatAttachmentSize(file.size),
                icon: iconForAttachmentKind(kind),
                onRemove: enabled ? () => onRemove(index) : null,
              ),
            );
          }),
          const SizedBox(height: 4),
        ],
        OutlinedButton.icon(
          onPressed: canAdd ? onAdd : null,
          icon: const Icon(Icons.attach_file_rounded, size: 20),
          label: Text(l10n.churchUpdateAddAttachment),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppPallete.tcBlueBright,
            side: const BorderSide(color: AppPallete.tcBlueBright),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.churchUpdateAttachmentHint,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: AppPallete.textMuted,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _PendingAttachmentTile extends StatelessWidget {
  const _PendingAttachmentTile({
    required this.name,
    required this.sizeLabel,
    required this.icon,
    this.onRemove,
  });

  final String name;
  final String sizeLabel;
  final IconData icon;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppPallete.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPallete.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppPallete.tcBlueBright.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppPallete.tcBlueBright),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppPallete.textPrimary,
                  ),
                ),
                Text(
                  sizeLabel,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppPallete.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded, size: 18),
              color: AppPallete.textMuted,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

class ChurchUpdateAttachmentsList extends StatelessWidget {
  const ChurchUpdateAttachmentsList({
    super.key,
    required this.attachments,
    required this.onOpen,
  });

  final List<ChurchUpdateAttachment> attachments;
  final ValueChanged<ChurchUpdateAttachment> onOpen;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.churchUpdateAttachments,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppPallete.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        ...attachments.map(
          (attachment) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _PublishedAttachmentTile(
              attachment: attachment,
              onTap: () => onOpen(attachment),
            ),
          ),
        ),
      ],
    );
  }
}

class _PublishedAttachmentTile extends StatelessWidget {
  const _PublishedAttachmentTile({
    required this.attachment,
    required this.onTap,
  });

  final ChurchUpdateAttachment attachment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isImage = attachment.kind == ChurchUpdateAttachmentKind.image;

    return Material(
      color: AppPallete.cardBg,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppPallete.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isImage)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    attachment.url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppPallete.inputFill,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: AppPallete.textMuted,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    if (!isImage) ...[
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppPallete.tcBlueBright.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          iconForAttachmentKind(attachment.kind),
                          size: 18,
                          color: AppPallete.tcBlueBright,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            attachment.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppPallete.textPrimary,
                            ),
                          ),
                          Text(
                            formatAttachmentSize(attachment.sizeBytes),
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: AppPallete.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.open_in_new_rounded,
                      size: 18,
                      color: AppPallete.tcBlueBright,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> openChurchUpdateAttachment(
  BuildContext context,
  ChurchUpdateAttachment attachment,
) async {
  final uri = Uri.tryParse(attachment.url);
  if (uri == null) {
    showAppErrorToast(context, context.l10n.churchUpdateOpenAttachmentFailed);
    return;
  }

  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    showAppErrorToast(context, context.l10n.churchUpdateOpenAttachmentFailed);
  }
}
