/// Demographics vs ministry breakdown — matches the Progress tab switcher.
enum MemberGroupCategory {
  demographics,
  ministry,
}

extension MemberGroupCategoryLabel on MemberGroupCategory {
  String get label => switch (this) {
        MemberGroupCategory.demographics => 'Demographics',
        MemberGroupCategory.ministry => 'Ministry',
      };
}

/// A selectable church group (demographic or ministry team).
class MemberGroup {
  const MemberGroup({
    required this.id,
    required this.label,
    required this.category,
  });

  final String id;
  final String label;
  final MemberGroupCategory category;
}

/// Canonical group lists used on registration and the Progress tab.
abstract final class MemberGroups {
  MemberGroups._();

  static const demographics = [
    MemberGroup(id: 'women', label: 'Women', category: MemberGroupCategory.demographics),
    MemberGroup(id: 'men', label: 'Men', category: MemberGroupCategory.demographics),
    MemberGroup(id: 'youth', label: 'Youth', category: MemberGroupCategory.demographics),
  ];

  /// UI-only option when ministry is optional (not stored in Firestore).
  static const noMinistry = MemberGroup(
    id: '',
    label: 'None',
    category: MemberGroupCategory.ministry,
  );

  static const ministries = [
    MemberGroup(id: 'choir', label: 'Choir', category: MemberGroupCategory.ministry),
    MemberGroup(
      id: 'deacons',
      label: 'Deacon board',
      category: MemberGroupCategory.ministry,
    ),
    MemberGroup(id: 'elders', label: 'Elders', category: MemberGroupCategory.ministry),
    MemberGroup(
      id: 'sanctuary',
      label: 'Sanctuary keepers',
      category: MemberGroupCategory.ministry,
    ),
    MemberGroup(id: 'ushers', label: 'Ushers', category: MemberGroupCategory.ministry),
    MemberGroup(
      id: 'media',
      label: 'Media team',
      category: MemberGroupCategory.ministry,
    ),
  ];

  static List<MemberGroup> forCategory(MemberGroupCategory category) => switch (category) {
        MemberGroupCategory.demographics => demographics,
        MemberGroupCategory.ministry => ministries,
      };

  static MemberGroup? findById(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final group in [...demographics, ...ministries]) {
      if (group.id == id) return group;
    }
    return null;
  }

  static MemberGroup? findDemographicById(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final group in demographics) {
      if (group.id == id) return group;
    }
    return null;
  }

  static MemberGroup? findMinistryById(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final group in ministries) {
      if (group.id == id) return group;
    }
    return null;
  }
}
