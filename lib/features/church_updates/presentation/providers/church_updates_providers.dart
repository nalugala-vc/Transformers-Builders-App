import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/church_updates_repository.dart';
import '../../domain/models/church_update.dart';

final churchUpdatesRepositoryProvider = Provider<ChurchUpdatesRepository>(
  (ref) => ChurchUpdatesRepository(),
);

/// Published church updates for members (Updates tab in notifications).
final publishedChurchUpdatesProvider =
    FutureProvider<List<ChurchUpdate>>((ref) async {
  return ref.read(churchUpdatesRepositoryProvider).listPublished();
});

/// Same feed for the admin Updates tab (compose + history).
final adminChurchUpdatesProvider = FutureProvider<List<ChurchUpdate>>((ref) async {
  return ref.read(churchUpdatesRepositoryProvider).listForAdmin();
});

Future<void> refreshChurchUpdates(WidgetRef ref) async {
  ref.invalidate(publishedChurchUpdatesProvider);
  ref.invalidate(adminChurchUpdatesProvider);
  await ref.read(publishedChurchUpdatesProvider.future);
}
