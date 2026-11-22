import 'package:flutter/material.dart';

import '../../constants.dart';

/// 悬浮面板的统一材质、圆角、描边和阴影。
class FloatingPanelSurface extends StatelessWidget {
  const FloatingPanelSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final radius = BorderRadius.circular(AppConstants.borderRadiusLarge);
    final shadow = scheme.shadow.withValues(
      alpha: brightness == Brightness.dark
          ? AppConstants.floatingPanelShadowDarkAlpha
          : AppConstants.floatingPanelShadowLightAlpha,
    );
    final highlight = Colors.white.withValues(
      alpha: AppConstants.floatingPanelHighlightAlpha,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: shadow,
            blurRadius: AppConstants.shadowBlurRadius,
            offset: Offset(0, AppConstants.shadowOffsetY),
          ),
          if (brightness != Brightness.dark)
            BoxShadow(
              color: highlight,
              blurRadius: AppConstants.highlightBlurRadius,
              offset: Offset(0, AppConstants.highlightOffsetY),
            ),
        ],
      ),
      child: Material(
        type: MaterialType.card,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: scheme.outlineVariant.withValues(
              alpha: AppConstants.floatingPanelBorderAlpha,
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}
