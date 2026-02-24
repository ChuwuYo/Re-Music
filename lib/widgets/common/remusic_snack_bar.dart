import 'package:flutter/material.dart';

import '../../constants.dart';

class ReMusicSnackBar {
  ReMusicSnackBar._();

  static void showFloating(
    BuildContext context, {
    required String message,
    Duration duration = AppConstants.snackBarDefaultDuration,
    bool showCloseIcon = true,
    bool clearPrevious = true,
    bool adaptiveHorizontalMargin = false,
    double horizontalMargin = AppConstants.snackBarDefaultHorizontalMargin,
    double bottomMargin = AppConstants.snackBarDefaultBottomMargin,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    final effectiveHorizontalMargin = adaptiveHorizontalMargin
        ? _calculateAdaptiveHorizontalMargin(
            context,
            message: message,
            showCloseIcon: showCloseIcon,
            fallbackMargin: horizontalMargin,
          )
        : horizontalMargin;

    if (clearPrevious) {
      messenger.removeCurrentSnackBar();
    }

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
          left: effectiveHorizontalMargin,
          right: effectiveHorizontalMargin,
          bottom: bottomMargin,
        ),
      ),
    );
  }

  static double _calculateAdaptiveHorizontalMargin(
    BuildContext context, {
    required String message,
    required bool showCloseIcon,
    required double fallbackMargin,
  }) {
    final mediaWidth = MediaQuery.sizeOf(context).width;
    final maxWidth = mediaWidth - fallbackMargin * 2;

    final textStyle =
        Theme.of(context).snackBarTheme.contentTextStyle ??
        Theme.of(context).textTheme.bodyMedium;
    final textPainter = TextPainter(
      text: TextSpan(text: message, style: textStyle),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();

    final estimatedWidth =
        textPainter.width +
        AppConstants.snackBarContentHorizontalPadding +
        (showCloseIcon ? AppConstants.snackBarCloseIconReserveWidth : 0);

    final targetWidth = estimatedWidth
        .clamp(
          AppConstants.snackBarAdaptiveMinWidth,
          AppConstants.snackBarAdaptiveMaxWidth,
        )
        .clamp(0.0, maxWidth);

    final adaptiveMargin = (mediaWidth - targetWidth) / 2;
    return adaptiveMargin < fallbackMargin ? fallbackMargin : adaptiveMargin;
  }
}
