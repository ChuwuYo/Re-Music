import 'package:flutter/material.dart';

import '../../constants.dart';

/// 带图标的分区标题，副标题可选，并包含与下方内容的间距。
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: AppConstants.iconSizeNotice, color: color),
            const SizedBox(width: AppConstants.spacingSmall),
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        if (subtitle == null)
          const SizedBox(height: AppConstants.spacingSmall)
        else ...[
          const SizedBox(height: AppConstants.spacingTiny),
          Text(
            subtitle!,
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
        ],
      ],
    );
  }
}
