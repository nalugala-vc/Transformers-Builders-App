import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/models/user_role.dart';
import '../../features/auth/presentation/providers/user_profile_providers.dart';
import '../config/app_route_paths.dart';

/// Resolves the signed-in user's role and navigates to the correct home route.
Future<void> navigateToRoleHome(BuildContext context, WidgetRef ref) async {
  final role = await ref.read(userProfileRepositoryProvider).getRoleForCurrentUser();
  if (!context.mounted) return;
  context.go(role.homePath);
}

extension UserRoleNavigation on UserRole {
  String get homePath => switch (this) {
        UserRole.member => AppRoutePaths.memberHome,
        UserRole.admin => AppRoutePaths.adminHome,
      };
}
