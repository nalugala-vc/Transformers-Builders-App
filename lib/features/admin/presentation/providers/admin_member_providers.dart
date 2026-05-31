import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/admin_member_repository.dart';
import '../../domain/models/admin_member_detail.dart';
import '../../domain/models/admin_member_list_item.dart';

final adminMemberRepositoryProvider = Provider<AdminMemberRepository>(
  (ref) => AdminMemberRepository(),
);

final adminMembersProvider = FutureProvider<List<AdminMemberListItem>>((ref) async {
  return ref.read(adminMemberRepositoryProvider).listActiveMembers();
});

final adminMemberDetailProvider =
    FutureProvider.family<AdminMemberDetail, String>((ref, uid) async {
  return ref.read(adminMemberRepositoryProvider).getMemberDetail(uid);
});

Future<void> refreshAdminMembers(WidgetRef ref) async {
  ref.invalidate(adminMembersProvider);
  await ref.read(adminMembersProvider.future);
}

Future<void> refreshAdminMemberDetail(WidgetRef ref, String uid) async {
  ref.invalidate(adminMemberDetailProvider(uid));
  await ref.read(adminMemberDetailProvider(uid).future);
}

Future<String?> deactivateAdminMember(WidgetRef ref, {required String uid}) async {
  try {
    await ref.read(adminMemberRepositoryProvider).deactivateMember(uid);
    ref.invalidate(adminMembersProvider);
    ref.invalidate(adminMemberDetailProvider(uid));
    return null;
  } catch (e) {
    return e.toString();
  }
}
