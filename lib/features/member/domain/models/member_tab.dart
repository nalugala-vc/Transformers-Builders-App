enum MemberTab {
  home,
  progress,
  profile;

  String get label => switch (this) {
        MemberTab.home => 'Home',
        MemberTab.progress => 'Progress',
        MemberTab.profile => 'Profile',
      };
}
