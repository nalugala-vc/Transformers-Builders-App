import 'package:flutter_riverpod/legacy.dart';

import '../../domain/models/admin_shell_view.dart';

final adminShellViewProvider = StateProvider<AdminShellView>(
  (ref) => AdminShellView.dashboard,
);
