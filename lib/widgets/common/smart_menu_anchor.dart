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

  @override
  Widget build(BuildContext context) {
    // Pre-calculate width if possible to apply to MenuStyle
    if (widget.widthEstimationLabels != null) {
      _calculatedMenuWidth = _estimateMenuWidthFromLabels(
        context,
        widget.widthEstimationLabels!,
      );
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

    // 理想位置：菜单中心对齐按钮中心
    double menuScreenX = buttonTopLeft.dx + (buttonWidth - menuWidth) / 2;

    // 限制在屏幕范围内（留 8px 边距）
    const margin = 8.0;
    menuScreenX = menuScreenX.clamp(margin, windowWidth - menuWidth - margin);

    // 转换为 MenuAnchor 本地坐标（open(position:) 坐标系以 MenuAnchor 左上角为原点）
    final relativeX = menuScreenX - buttonTopLeft.dx;

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
