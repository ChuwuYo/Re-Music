import 'dart:math' as math;
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import '../../constants.dart';

/// A robust MenuAnchor wrapper that handles positioning logic intelligently.
/// Ensures the menu is centered below the anchor button and stays within the viewport.
class SmartMenuAnchor extends StatefulWidget {
  final Widget icon;
  final String tooltip;
  final List<Widget> menuChildren;
  final double? estimatedMenuWidth;
  final VoidCallback? onBeforeOpen;

  /// If provided, used to calculate the menu width dynamically based on labels.
  final List<String>? widthEstimationLabels;
  final bool useFilledButton;
  final ButtonStyle? buttonStyle;

  const SmartMenuAnchor({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.menuChildren,
    this.estimatedMenuWidth,
    this.onBeforeOpen,
    this.widthEstimationLabels,
    this.useFilledButton = true,
    this.buttonStyle,
  });

  @override
  State<SmartMenuAnchor> createState() => _SmartMenuAnchorState();
}

class _SmartMenuAnchorState extends State<SmartMenuAnchor> {
  final MenuController _controller = MenuController();
  final GlobalKey _buttonKey = GlobalKey();
  double? _calculatedMenuWidth;
  List<String>? _lastWidthLabels;
  Locale? _lastLocale;

  @override
  Widget build(BuildContext context) {
    if (widget.widthEstimationLabels != null) {
      // 仅在标签内容或语言环境变化时重新计算，避免每次 build 都运行 TextPainter
      final currentLocale = Localizations.localeOf(context);
      if (_calculatedMenuWidth == null ||
          !listEquals(widget.widthEstimationLabels, _lastWidthLabels) ||
          currentLocale != _lastLocale) {
        _calculatedMenuWidth = _estimateMenuWidthFromLabels(
          context,
          widget.widthEstimationLabels!,
        );
        _lastWidthLabels = List.of(widget.widthEstimationLabels!);
        _lastLocale = currentLocale;
      }
    } else {
      _calculatedMenuWidth = widget.estimatedMenuWidth;
    }

    return MenuAnchor(
      controller: _controller,
      menuChildren: widget.menuChildren,
      style: MenuStyle(
        minimumSize: _calculatedMenuWidth != null
            ? WidgetStatePropertyAll(Size(_calculatedMenuWidth!, 0))
            : null,
        maximumSize: _calculatedMenuWidth != null
            ? WidgetStatePropertyAll(
                Size(_calculatedMenuWidth!, double.infinity),
              )
            : null,
      ),
      builder: (context, controller, child) {
        if (widget.useFilledButton) {
          return IconButton.filledTonal(
            key: _buttonKey,
            onPressed: () => _handlePressed(context),
            icon: widget.icon,
            tooltip: widget.tooltip,
            style: widget.buttonStyle,
          );
        } else {
          return IconButton(
            key: _buttonKey,
            onPressed: () => _handlePressed(context),
            icon: widget.icon,
            tooltip: widget.tooltip,
            style: widget.buttonStyle,
          );
        }
      },
    );
  }

  void _handlePressed(BuildContext context) {
    widget.onBeforeOpen?.call();

    if (_controller.isOpen) {
      _controller.close();
      return;
    }

    final renderBox = _buttonKey.currentContext?.findRenderObject();
    if (renderBox is! RenderBox || !renderBox.hasSize) {
      _controller.open();
      return;
    }

    final windowWidth = MediaQuery.sizeOf(context).width;
    final menuWidth =
        _calculatedMenuWidth ??
        (widget.widthEstimationLabels != null
            ? _estimateMenuWidthFromLabels(
                context,
                widget.widthEstimationLabels!,
              )
            : widget.estimatedMenuWidth ?? AppConstants.defaultMenuWidth);

    final buttonTopLeft = renderBox.localToGlobal(Offset.zero);
    final buttonWidth = renderBox.size.width;
    final buttonHeight = renderBox.size.height;

    // 理想 anchor 相对 X：菜单中心对齐按钮中心
    final idealRelX = (buttonWidth - menuWidth) / 2;

    // 转换到全局做越界检查，再转回相对坐标
    const margin = 8.0;
    final idealScreenX = buttonTopLeft.dx + idealRelX;
    final clampMax = math.max(margin, windowWidth - menuWidth - margin);
    final clampedScreenX = idealScreenX.clamp(margin, clampMax);
    final relativeX = clampedScreenX - buttonTopLeft.dx;

    // 一次性打开菜单
    _controller.open(position: Offset(relativeX, buttonHeight));
  }

  double _estimateMenuWidthFromLabels(
    BuildContext context,
    List<String> labels, {
    double minWidth = AppConstants.menuMinWidth,
    double maxWidth = AppConstants.menuMaxWidth,
  }) {
    final style =
        Theme.of(context).textTheme.labelLarge ??
        DefaultTextStyle.of(context).style;
    final direction = Directionality.of(context);
    double maxLabelWidth = 0;
    for (final label in labels) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: style),
        maxLines: 1,
        textDirection: direction,
      )..layout();
      if (painter.width > maxLabelWidth) {
        maxLabelWidth = painter.width;
      }
      painter.dispose();
    }

    final estimated = maxLabelWidth + AppConstants.menuPaddingAndIconSpace;
    if (estimated < minWidth) return minWidth;
    if (estimated > maxWidth) return maxWidth;
    return estimated;
  }
}
