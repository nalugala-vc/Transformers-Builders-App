import 'package:flutter_riverpod/legacy.dart';

import '../../domain/models/member_tab.dart';

final memberTabProvider = StateProvider<MemberTab>((ref) => MemberTab.home);

final pendingAdminBannerDismissedProvider = StateProvider<bool>((ref) => false);
