import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/admin_dashboard_repository.dart';
import '../../domain/models/admin_dashboard_data.dart';

final adminDashboardRepositoryProvider = Provider<AdminDashboardRepository>(
  (ref) => AdminDashboardRepository(),
);

final adminDashboardProvider = FutureProvider<AdminDashboardData>((ref) async {
  return ref.read(adminDashboardRepositoryProvider).loadDashboard();
});

/// Re-fetch the admin dashboard (used by pull-to-refresh + after admin actions).
Future<void> refreshAdminDashboard(WidgetRef ref) async {
  ref.invalidate(adminDashboardProvider);
  await ref.read(adminDashboardProvider.future);
}
