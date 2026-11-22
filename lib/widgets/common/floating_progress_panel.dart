import 'package:flutter/material.dart';

import '../../constants.dart';
import 'floating_panel_surface.dart';

/// 悬浮进度面板：文案由调用方给，进度为 null 时显示 indeterminate。
class FloatingProgressPanel extends StatelessWidget {
  const FloatingProgressPanel({
    super.key,
    required this.label,
    required this.progress,
  });

  final String label;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return FloatingPanelSurface(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMedium,
          vertical: AppConstants.spacingMediumSmall,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.progressPanelMaxWidth,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: AppConstants.spacingSmall),
              LinearProgressIndicator(
                value: progress,
                borderRadius: BorderRadius.circular(
                  AppConstants.progressBorderRadius,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
