import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';

enum AppToastKind { info, success, error, warning }

/// User feedback via [toastification] (see [ToastificationWrapper] in [main.dart]).
void showAppToast(
  BuildContext context, {
  required String message,
  AppToastKind kind = AppToastKind.info,
  Duration autoCloseDuration = const Duration(seconds: 3),
}) {
  final type = switch (kind) {
    AppToastKind.success => ToastificationType.success,
    AppToastKind.error => ToastificationType.error,
    AppToastKind.warning => ToastificationType.warning,
    AppToastKind.info => ToastificationType.info,
  };

  toastification.show(
    context: context,
    type: type,
    style: ToastificationStyle.flatColored,
    alignment: Alignment.topCenter,
    autoCloseDuration: autoCloseDuration,
    showProgressBar: false,
    title: Text(
      message,
      style: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

void showAppSuccessToast(BuildContext context, String message) {
  showAppToast(context, message: message, kind: AppToastKind.success);
}

void showAppErrorToast(BuildContext context, String message) {
  showAppToast(context, message: message, kind: AppToastKind.error);
}

void showAppInfoToast(BuildContext context, String message) {
  showAppToast(context, message: message, kind: AppToastKind.info);
}
