import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../../../core/utils/theme/app_sizes.dart';
import '../../../church_updates/presentation/providers/church_updates_providers.dart';
import '../../../church_updates/presentation/widgets/church_update_detail_sheet.dart';
import '../../../church_updates/presentation/widgets/church_update_tile.dart';
import '../../../church_updates/presentation/widgets/publish_church_update_sheet.dart';

class AdminUpdatesTabScreen extends ConsumerWidget {
  const AdminUpdatesTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final updatesAsync = ref.watch(adminChurchUpdatesProvider);

    return ColoredBox(
      color: AppPallete.scaffoldBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.responsivePagePadding,
                20,
                context.responsivePagePadding,
                8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.adminTabUpdates,
                    style: GoogleFonts.dmSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppPallete.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.adminUpdatesManageSubtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppPallete.textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: updatesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Padding(
                    padding: EdgeInsets.all(context.responsivePagePadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.churchUpdatesLoadError,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () =>
                              ref.invalidate(adminChurchUpdatesProvider),
                          child: Text(l10n.tryAgain),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (updates) {
                  if (updates.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(context.responsivePagePadding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppPallete.tcBlueLight.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.campaign_rounded,
                                color: AppPallete.tcBlueLight,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.adminUpdatesEmpty,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: AppPallete.textMuted,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppPallete.tcBlueBright,
                    onRefresh: () => refreshChurchUpdates(ref),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        context.responsivePagePadding,
                        8,
                        context.responsivePagePadding,
                        88,
                      ),
                      children: [
                        for (final update in updates)
                          ChurchUpdateTile(
                            update: update,
                            onTap: () =>
                                showChurchUpdateDetailSheet(context, update),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// FAB shown on the admin Updates tab (wired from [AdminShellScreen]).
class AdminPublishUpdateFab extends StatelessWidget {
  const AdminPublishUpdateFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => showPublishChurchUpdateSheet(context),
      backgroundColor: AppPallete.tcBlueBright,
      foregroundColor: AppPallete.tcWhite,
      icon: const Icon(Icons.add_rounded),
      label: Text(
        context.l10n.adminPublishUpdateAction,
        style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
      ),
    );
  }
}
