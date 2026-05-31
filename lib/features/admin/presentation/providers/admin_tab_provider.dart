import 'package:flutter_riverpod/legacy.dart';

import '../../domain/models/admin_tab.dart';

final adminTabProvider = StateProvider<AdminTab>((ref) => AdminTab.dashboard);
