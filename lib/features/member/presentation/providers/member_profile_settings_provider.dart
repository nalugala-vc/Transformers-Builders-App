import 'package:flutter_riverpod/legacy.dart';

final memberLanguageCodeProvider = StateProvider<String>((ref) => 'en');

final memberPushNotificationsProvider = StateProvider<bool>((ref) => true);
