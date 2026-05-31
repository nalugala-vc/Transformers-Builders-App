import '../../../../core/utils/user_initials.dart';
import '../../../auth/domain/models/app_user.dart';

class AdminMemberListItem {
  const AdminMemberListItem({
    required this.user,
    required this.raisedKes,
    required this.targetKes,
  });

  final AppUser user;
  final int raisedKes;
  final int targetKes;

  String get uid => user.uid;
  String get fullName => user.fullName;
  String get email => user.email;
  String? get phoneE164 => user.phoneE164;
  String get initials => initialsForName(fullName);

  double get progressFraction =>
      targetKes <= 0 ? 0 : (raisedKes / targetKes).clamp(0.0, 1.0);

  int get progressPercent => (progressFraction * 100).round();
}
