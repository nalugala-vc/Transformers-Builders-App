import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../member/presentation/screens/member_home_tab_screen.dart';

/// Admin view of their own giving — same home experience as members.
class AdminPersonalContributionsScreen extends ConsumerWidget {
  const AdminPersonalContributionsScreen({
    super.key,
    required this.onOpenDrawer,
  });

  final VoidCallback onOpenDrawer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MemberHomeTabScreen(onOpenDrawer: onOpenDrawer);
  }
}
