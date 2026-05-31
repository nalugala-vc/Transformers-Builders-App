import '../../../../l10n/app_localizations.dart';

enum AdminTab {
  dashboard,
  management,
  updates,
  profile;

  String label(AppLocalizations l10n) => switch (this) {
        AdminTab.dashboard => l10n.adminTabDashboard,
        AdminTab.management => l10n.adminTabManagement,
        AdminTab.updates => l10n.adminTabUpdates,
        AdminTab.profile => l10n.adminTabProfile,
      };
}
