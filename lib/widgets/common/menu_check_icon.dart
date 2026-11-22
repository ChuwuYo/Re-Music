import 'package:flutter/material.dart';

import '../../constants.dart';

/// 菜单项勾选指示：选中显示对勾，未选中保留等宽占位以对齐文字。
class MenuCheckIcon extends StatelessWidget {
  const MenuCheckIcon({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return selected
        ? const Icon(Icons.check)
        : const SizedBox(width: AppConstants.iconSizeDefault);
  }
}
