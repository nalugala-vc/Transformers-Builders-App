import 'admin_tab.dart';

/// Primary content shown in the admin shell (bottom nav + sidebar).
enum AdminShellView {
  dashboard,
  management,
  updates,
  profile,
  myContributions;

  static AdminShellView fromTab(AdminTab tab) => AdminShellView.values[tab.index];

  /// Maps back to bottom-nav selection; null when a sidebar-only view is active.
  AdminTab? get bottomNavTab {
    if (index <= AdminTab.profile.index) {
      return AdminTab.values[index];
    }
    return null;
  }
}
