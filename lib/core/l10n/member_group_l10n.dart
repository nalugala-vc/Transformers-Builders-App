import '../../features/member/domain/models/contribution_segment.dart';
import '../../features/member/domain/models/member_group.dart';
import '../../l10n/app_localizations.dart';

/// Localized display name for a church group id (`women`, `choir`, …).
String localizedMemberGroupLabel(AppLocalizations l10n, String id) {
  return switch (id) {
    'women' => l10n.groupWomen,
    'men' => l10n.groupMen,
    'youth' => l10n.groupYouth,
    'choir' => l10n.groupChoir,
    'deacons' => l10n.groupDeacons,
    'elders' => l10n.groupElders,
    'sanctuary' => l10n.groupSanctuary,
    'ushers' => l10n.groupUshers,
    'media' => l10n.groupMedia,
    _ => MemberGroups.findById(id)?.label ?? id,
  };
}

extension MemberGroupL10n on MemberGroup {
  String localizedLabel(AppLocalizations l10n) => localizedMemberGroupLabel(l10n, id);
}

extension ContributionSegmentL10n on ContributionSegment {
  String localizedLabel(AppLocalizations l10n) => localizedMemberGroupLabel(l10n, id);
}
