import '../../../../l10n/app_localizations.dart';

enum ProgressBreakdownMode {
  demographics,
  ministries;

  String label(AppLocalizations l10n) => switch (this) {
        ProgressBreakdownMode.demographics => l10n.progressDemographics,
        ProgressBreakdownMode.ministries => l10n.progressMinistries,
      };
}
