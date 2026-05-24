import '../../../../core/l10n/l10n_extension.dart';
import '../../../../l10n/app_localizations.dart';

enum MemberTab {
  home,
  progress,
  profile;

  String label(AppLocalizations l10n) => switch (this) {
        MemberTab.home => l10n.tabHome,
        MemberTab.progress => l10n.tabProgress,
        MemberTab.profile => l10n.tabProfile,
      };
}
