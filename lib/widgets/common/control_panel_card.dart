import 'package:flutter/material.dart';

import '../../constants.dart';

/// 控制面板统一的 Card 外壳：固定 margin/padding，内容由调用方提供。
class ControlPanelCard extends StatelessWidget {
  const ControlPanelCard({super.key, required this.child, this.elevation});

  final Widget child;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppConstants.spacingMedium),
      elevation: elevation,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: child,
      ),
    );
  }
}
