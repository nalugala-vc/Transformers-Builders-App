/// Church-wide contribution totals stored in Firestore `churchProgress/current`.
class ChurchProgressData {
  const ChurchProgressData({
    required this.totalKes,
    required this.demographics,
    required this.ministries,
  });

  static const empty = ChurchProgressData(
    totalKes: 0,
    demographics: {},
    ministries: {},
  );

  final int totalKes;
  final Map<String, int> demographics;
  final Map<String, int> ministries;

  int amountForGroup(String groupId, {required bool ministry}) {
    final map = ministry ? ministries : demographics;
    return map[groupId] ?? 0;
  }
}
