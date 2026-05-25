/// Church-wide contribution totals stored in Firestore `churchProgress/current`.
///
/// **raised** totals (`totalKes`, `demographics`, `ministries`) sum *completed*
/// contributions across all members. **target** totals (`totalTargetKes`,
/// `demographicTargets`, `ministryTargets`) sum each member's personal
/// `contributionTargetKes`, grouped by the member's demographic and ministry.
class ChurchProgressData {
  const ChurchProgressData({
    required this.totalKes,
    required this.totalTargetKes,
    required this.demographics,
    required this.ministries,
    required this.demographicTargets,
    required this.ministryTargets,
  });

  static const empty = ChurchProgressData(
    totalKes: 0,
    totalTargetKes: 0,
    demographics: {},
    ministries: {},
    demographicTargets: {},
    ministryTargets: {},
  );

  final int totalKes;
  final int totalTargetKes;
  final Map<String, int> demographics;
  final Map<String, int> ministries;
  final Map<String, int> demographicTargets;
  final Map<String, int> ministryTargets;

  int amountForGroup(String groupId, {required bool ministry}) =>
      (ministry ? ministries : demographics)[groupId] ?? 0;

  int targetForGroup(String groupId, {required bool ministry}) =>
      (ministry ? ministryTargets : demographicTargets)[groupId] ?? 0;
}
