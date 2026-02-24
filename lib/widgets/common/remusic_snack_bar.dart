import 'package:flutter/material.dart';

import '../../constants.dart';

class ReMusicSnackBar {
  ReMusicSnackBar._();

  static void showFloating(
    BuildContext context, {
    required String message,
    Duration duration = AppConstants.snackBarDefaultDuration,
    bool showCloseIcon = true,
    double horizontalMargin = AppConstants.snackBarDefaultHorizontalMargin,
    double bottomMargin = AppConstants.snackBarDefaultBottomMargin,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: showCloseIcon,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        margin: EdgeInsets.only(
          left: horizontalMargin,
          right: horizontalMargin,
          bottom: bottomMargin,
        ),
      ),
    );
  }
}
