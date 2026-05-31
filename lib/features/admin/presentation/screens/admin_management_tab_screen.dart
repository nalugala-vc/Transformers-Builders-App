import 'package:flutter/material.dart';

import 'admin_member_management_screen.dart';

class AdminManagementTabScreen extends StatelessWidget {
  const AdminManagementTabScreen({
    super.key,
    required this.onOpenDrawer,
  });

  final VoidCallback onOpenDrawer;

  @override
  Widget build(BuildContext context) {
    return const AdminMemberManagementScreen();
  }
}
