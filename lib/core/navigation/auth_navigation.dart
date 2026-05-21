import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/models/user_role.dart';
import '../../features/auth/presentation/providers/user_profile_providers.dart';
import '../config/app_route_paths.dart';

/// Resolves the signed-in user's role and navigates to the correct home route.
///
/// Members without a saved group are routed to [AppRoutePaths.pickGroup] first
/// (e.g. after Google sign-in, where the registration form was skipped).
Future<void> navigateToRoleHome(BuildContext context, WidgetRef ref) async {
  final profiles = ref.read(userProfileRepositoryProvider);
  final user = await profiles.ensureProfileForCurrentUser();
  if (!context.mounted) return;

  if (user.role == UserRole.member && !user.hasCompleteMemberGroups) {
    context.go(AppRoutePaths.pickGroup);
    return;
  }

  context.go(user.role.homePath);
}

extension UserRoleNavigation on UserRole {
  String get homePath => switch (this) {
        UserRole.member => AppRoutePaths.memberHome,
        UserRole.admin => AppRoutePaths.adminHome,
      };
}
